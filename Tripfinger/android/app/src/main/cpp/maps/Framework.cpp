#include "Framework.hpp"
#include "UserMarkHelper.hpp"
#include "../core/jni_helper.hpp"
#include "../opengl/androidoglcontextfactory.hpp"
#include "../platform/Platform.hpp"

#include "map/user_mark.hpp"

#include "storage/storage_helpers.hpp"

#include "drape_frontend/visual_params.hpp"
#include "drape_frontend/user_event_stream.hpp"
#include "drape/pointers.hpp"
#include "drape/visual_scale.hpp"

#include "coding/file_container.hpp"
#include "coding/file_name_utils.hpp"

#include "geometry/angles.hpp"

#include "platform/country_file.hpp"
#include "platform/local_country_file.hpp"
#include "platform/local_country_file_utils.hpp"
#include "platform/location.hpp"
#include "platform/measurement_utils.hpp"
#include "platform/platform.hpp"
#include "platform/preferred_languages.hpp"
#include "platform/settings.hpp"

#include "base/math.hpp"
#include "base/logging.hpp"
#include "base/sunrise_sunset.hpp"

android::Framework * g_framework = 0;

using namespace storage;
using platform::CountryFile;
using platform::LocalCountryFile;

namespace
{
    ::Framework * frm()
    {
        return g_framework->NativeFramework();
    }

    jobject g_mapObjectListener;
    jobject g_poiSupplier;
}  // namespace

namespace android
{

    enum MultiTouchAction
    {
        MULTITOUCH_UP    =   0x00000001,
        MULTITOUCH_DOWN  =   0x00000002,
        MULTITOUCH_MOVE  =   0x00000003,
        MULTITOUCH_CANCEL =  0x00000004
    };

    Framework::Framework()
            : m_lastCompass(0.0)
            , m_currentMode(location::MODE_UNKNOWN_POSITION)
            , m_isCurrentModeInitialized(false)
            , m_isChoosePositionMode(false)
    {
        ASSERT_EQUAL ( g_framework, 0, () );
        g_framework = this;
    }

    void Framework::OnLocationError(int errorCode)
    {
        m_work.OnLocationError(static_cast<location::TLocationError>(errorCode));
    }

    void Framework::OnLocationUpdated(location::GpsInfo const & info)
    {
        m_work.OnLocationUpdate(info);
    }

    void Framework::OnCompassUpdated(location::CompassInfo const & info, bool forceRedraw)
    {
        static double const COMPASS_THRESHOLD = my::DegToRad(1.0);

        /// @todo Do not emit compass bearing too often.
        /// Need to make more experiments in future.
        if (forceRedraw || fabs(ang::GetShortestDistance(m_lastCompass, info.m_bearing)) >= COMPASS_THRESHOLD)
        {
            m_lastCompass = info.m_bearing;
            m_work.OnCompassUpdate(info);
        }
    }

    void Framework::UpdateCompassSensor(int ind, float * arr)
    {
        m_sensors[ind].Next(arr);
    }

    void Framework::MyPositionModeChanged(location::EMyPositionMode mode)
    {
        if (m_myPositionModeSignal != nullptr)
            m_myPositionModeSignal(mode);
    }

    bool Framework::CreateDrapeEngine(JNIEnv * env, jobject jSurface, int densityDpi)
    {
        m_contextFactory = make_unique_dp<dp::ThreadSafeFactory>(new AndroidOGLContextFactory(env, jSurface));
        AndroidOGLContextFactory const * factory = m_contextFactory->CastFactory<AndroidOGLContextFactory>();
        if (!factory->IsValid())
            return false;

        ::Framework::DrapeCreationParams p;
        p.m_surfaceWidth = factory->GetWidth();
        p.m_surfaceHeight = factory->GetHeight();
        p.m_visualScale = dp::VisualScale(densityDpi);
        p.m_hasMyPositionState = m_isCurrentModeInitialized;
        p.m_initialMyPositionState = m_currentMode;
        p.m_isChoosePositionMode = m_isChoosePositionMode;
        ASSERT(!m_guiPositions.empty(), ("GUI elements must be set-up before engine is created"));
        p.m_widgetsInitInfo = m_guiPositions;

        m_work.LoadBookmarks();
        m_work.SetMyPositionModeListener(bind(&Framework::MyPositionModeChanged, this, _1));

        m_work.CreateDrapeEngine(make_ref(m_contextFactory), move(p));
        m_work.EnterForeground();

        // Execute drape tasks which set up custom state.
        {
            lock_guard<mutex> lock(m_drapeQueueMutex);
            if (!m_drapeTasksQueue.empty())
                ExecuteDrapeTasks();
        }

        return true;
    }

    void Framework::DeleteDrapeEngine()
    {
        m_work.EnterBackground();

        m_work.DestroyDrapeEngine();
    }

    bool Framework::IsDrapeEngineCreated()
    {
        return m_work.GetDrapeEngine() != nullptr;
    }

    void Framework::Resize(int w, int h)
    {
        m_contextFactory->CastFactory<AndroidOGLContextFactory>()->UpdateSurfaceSize();
        m_work.OnSize(w, h);
    }

    void Framework::DetachSurface()
    {
        m_work.SetRenderingEnabled(false);

        ASSERT(m_contextFactory != nullptr, ());
        AndroidOGLContextFactory * factory = m_contextFactory->CastFactory<AndroidOGLContextFactory>();
        factory->ResetSurface();
    }

    void Framework::AttachSurface(JNIEnv * env, jobject jSurface)
    {
        ASSERT(m_contextFactory != nullptr, ());
        AndroidOGLContextFactory * factory = m_contextFactory->CastFactory<AndroidOGLContextFactory>();
        factory->SetSurface(env, jSurface);

        m_work.SetRenderingEnabled(true);
    }

    void Framework::SetMapStyle(MapStyle mapStyle)
    {
        m_work.SetMapStyle(mapStyle);
    }

    void Framework::MarkMapStyle(MapStyle mapStyle)
    {
        m_work.MarkMapStyle(mapStyle);
    }

    MapStyle Framework::GetMapStyle() const
    {
        return m_work.GetMapStyle();
    }

    void Framework::Save3dMode(bool allow3d, bool allow3dBuildings)
    {
        m_work.Save3dMode(allow3d, allow3dBuildings);
    }

    void Framework::Set3dMode(bool allow3d, bool allow3dBuildings)
    {
        m_work.Allow3dMode(allow3d, allow3dBuildings);
    }

    void Framework::Get3dMode(bool & allow3d, bool & allow3dBuildings)
    {
        m_work.Load3dMode(allow3d, allow3dBuildings);
    }

    void Framework::SetChoosePositionMode(bool isChoosePositionMode)
    {
        m_isChoosePositionMode = isChoosePositionMode;
        m_work.BlockTapEvents(isChoosePositionMode);
        m_work.EnableChoosePositionMode(isChoosePositionMode);
    }

    Storage & Framework::Storage()
    {
        return m_work.Storage();
    }

    void Framework::ShowNode(TCountryId const & idx, bool zoomToDownloadButton)
    {
        if (zoomToDownloadButton)
        {
            m2::RectD const rect = CalcLimitRect(idx, m_work.Storage(), m_work.CountryInfoGetter());
            m_work.SetViewportCenter(rect.Center(), 10);
        }
        else
        {
            m_work.ShowNode(idx);
        }
    }

    void Framework::Touch(int action, Finger const & f1, Finger const & f2, uint8_t maskedPointer)
    {
        MultiTouchAction eventType = static_cast<MultiTouchAction>(action);
        df::TouchEvent event;

        switch(eventType)
        {
            case MULTITOUCH_DOWN:
                event.m_type = df::TouchEvent::TOUCH_DOWN;
                break;
            case MULTITOUCH_MOVE:
                event.m_type = df::TouchEvent::TOUCH_MOVE;
                break;
            case MULTITOUCH_UP:
                event.m_type = df::TouchEvent::TOUCH_UP;
                break;
            case MULTITOUCH_CANCEL:
                event.m_type = df::TouchEvent::TOUCH_CANCEL;
                break;
            default:
                return;
        }

        event.m_touches[0].m_location = m2::PointD(f1.m_x, f1.m_y);
        event.m_touches[0].m_id = f1.m_id;
        event.m_touches[1].m_location = m2::PointD(f2.m_x, f2.m_y);
        event.m_touches[1].m_id = f2.m_id;

        event.SetFirstMaskedPointer(maskedPointer);
        m_work.TouchEvent(event);
    }

    m2::PointD Framework::GetViewportCenter() const
    {
        return m_work.GetViewportCenter();
    }

    void Framework::AddString(string const & name, string const & value)
    {
        m_work.AddString(name, value);
    }

    void Framework::Scale(::Framework::EScaleMode mode)
    {
        m_work.Scale(mode, true);
    }

    void Framework::Scale(m2::PointD const & centerPt, int targetZoom, bool animate)
    {
        ref_ptr<df::DrapeEngine> engine = m_work.GetDrapeEngine();
        if (engine)
            engine->SetModelViewCenter(centerPt, targetZoom, animate);
    }

    ::Framework * Framework::NativeFramework()
    {
        return &m_work;
    }

    bool Framework::Search(search::SearchParams const & params)
    {
        m_searchQuery = params.m_query;
        return m_work.Search(params);
    }

    void Framework::AddLocalMaps()
    {
        m_work.RegisterAllMaps();
    }

    void Framework::RemoveLocalMaps()
    {
        m_work.DeregisterAllMaps();
    }

    void Framework::ReplaceBookmark(BookmarkAndCategory const & ind, BookmarkData & bm)
    {
        m_work.ReplaceBookmark(ind.first, ind.second, bm);
    }

    size_t Framework::ChangeBookmarkCategory(BookmarkAndCategory const & ind, size_t newCat)
    {
        return m_work.MoveBookmark(ind.second, ind.first, newCat);
    }

    bool Framework::ShowMapForURL(string const & url)
    {
        return m_work.ShowMapForURL(url);
    }

    void Framework::DeactivatePopup()
    {
        m_work.DeactivateMapSelection(false);
    }

    string Framework::GetOutdatedCountriesString()
    {
        vector<Country const *> countries;
        class Storage const & storage = Storage();
        storage.GetOutdatedCountries(countries);

        string res;
        NodeAttrs attrs;

        for (size_t i = 0; i < countries.size(); ++i)
        {
            storage.GetNodeAttrs(countries[i]->Name(), attrs);

            if (i > 0)
                res += ", ";

            res += attrs.m_nodeLocalName;
        }

        return res;
    }

    void Framework::ShowTrack(int category, int track)
    {
        Track const * nTrack = NativeFramework()->GetBmCategory(category)->GetTrack(track);
        NativeFramework()->ShowTrack(*nTrack);
    }

    void Framework::SetMyPositionModeListener(location::TMyPositionModeChanged const & fn)
    {
        m_myPositionModeSignal = fn;
    }

    location::EMyPositionMode Framework::GetMyPositionMode() const
    {
        if (!m_isCurrentModeInitialized)
            return location::MODE_UNKNOWN_POSITION;

        return m_currentMode;
    }

    void Framework::SetMyPositionMode(location::EMyPositionMode mode)
    {
        m_currentMode = mode;
        m_isCurrentModeInitialized = true;
    }

    void Framework::SetupWidget(gui::EWidget widget, float x, float y, dp::Anchor anchor)
    {
        m_guiPositions[widget] = gui::Position(m2::PointF(x, y), anchor);
    }

    void Framework::ApplyWidgets()
    {
        gui::TWidgetsLayoutInfo layout;
        for (auto const & widget : m_guiPositions)
            layout[widget.first] = widget.second.m_pixelPivot;

        m_work.SetWidgetLayout(move(layout));
    }

    void Framework::CleanWidgets()
    {
        m_guiPositions.clear();
    }

    void Framework::SetupMeasurementSystem()
    {
        m_work.SetupMeasurementSystem();
    }

    void Framework::PostDrapeTask(TDrapeTask && task)
    {
        ASSERT(task != nullptr, ());
        lock_guard<mutex> lock(m_drapeQueueMutex);
        if (IsDrapeEngineCreated())
            task();
        else
            m_drapeTasksQueue.push_back(move(task));
    }

    void Framework::ExecuteDrapeTasks()
    {
        for (auto & task : m_drapeTasksQueue)
            task();
        m_drapeTasksQueue.clear();
    }

    void Framework::SetPlacePageInfo(place_page::Info const & info)
    {
        m_info = info;
    }

    place_page::Info & Framework::GetPlacePageInfo()
    {
        return m_info;
    }

    bool Framework::HasSpaceForMigration()
    {
        return m_work.IsEnoughSpaceForMigrate();
    }

    void Framework::Migrate(bool keepOldMaps)
    {
        m_work.Migrate(keepOldMaps);
    }

    storage::TCountryId Framework::PreMigrate(ms::LatLon const & position, Storage::TChangeCountryFunction const & statusChangeListener,
                                              Storage::TProgressFunction const & progressListener)
    {
        return m_work.PreMigrate(position, statusChangeListener, progressListener);
    }

}  // namespace android

//============ GLUE CODE for com.mapswithme.maps.Framework class =============//
/*            ____
 *          _ |||| _
 *          \\    //
 *           \\  //
 *            \\//
 *             \/
 */

extern "C"
{
void CallRoutingListener(shared_ptr<jobject> listener, int errorCode, vector<storage::TCountryId> const & absentMaps)
{
    JNIEnv * env = jni::GetEnv();
    jmethodID const method = jni::GetMethodID(env, *listener, "onRoutingEvent", "(I[Ljava/lang/String;)V");
    ASSERT(method, ());

    jni::TScopedLocalObjectArrayRef const countries(env, env->NewObjectArray(absentMaps.size(), jni::GetStringClass(env), 0));
    for (size_t i = 0; i < absentMaps.size(); i++)
    {
        jni::TScopedLocalRef id(env, jni::ToJavaString(env, absentMaps[i]));
        env->SetObjectArrayElement(countries.get(), i, id.get());
    }

    env->CallVoidMethod(*listener, method, errorCode, countries.get());
}

void CallRouteProgressListener(shared_ptr<jobject> listener, float progress)
{
    JNIEnv * env = jni::GetEnv();
    jmethodID const methodId = jni::GetMethodID(env, *listener, "onRouteBuildingProgress", "(F)V");
    env->CallVoidMethod(*listener, methodId, progress);
}

/// @name JNI EXPORTS
//@{

JNIEXPORT void JNICALL
Java_com_tripfinger_map_Framework_nativeSetPoiSupplier(JNIEnv * env, jclass clazz, jobject jSupplier)
{
    LOG(LINFO, ("Setting tha poiSupplierz", ""));
    g_poiSupplier = env->NewGlobalRef(jSupplier);
    // void poiSupplier();
    jmethodID const supplierId = jni::GetMethodID(env, g_poiSupplier, "poiSupplier", "()V");
    frm()->SetPoiSupplierFunction([supplierId](TripfingerMarkParams& params) {
        JNIEnv * env = jni::GetEnv();
        env->CallVoidMethod(g_poiSupplier, supplierId);

        vector<TripfingerMark> tripfingerVector;
        return tripfingerVector;
    });
    frm()->SetCoordinateCheckerFunction([](ms::LatLon latlon) {
        return false;
    });
}

} // extern "C"
