#include "indexer/feature_cache.hpp"
#include "base/logging.hpp"
#include <boost/algorithm/string.hpp>

void FeatureCache::SetFeatures(vector<SelfBakedFeatureType> && features) {
  for (auto const & feature : features) {
    featureMap.insert(make_pair(feature.GetID().m_tripfingerId, feature));
  }
}

vector<SelfBakedFeatureType> FeatureCache::GetFeatures(TripfingerMarkParams const & params) const {
  vector<SelfBakedFeatureType> results;
  for (auto& kv : featureMap) {
    SelfBakedFeatureType const & feature = kv.second;
    if (!feature.hiddenFromMap && (params.category == 0 || params.category == feature.m_category)
        && feature.GetCenter().x > params.topLeft.x && feature.GetCenter().x < params.botRight.x
        && feature.GetCenter().y > params.botRight.y && feature.GetCenter().y < params.topLeft.y) {
      results.push_back(feature);
    }
  }
  return results;
}

SelfBakedFeatureType FeatureCache::GetFeatureById(string const & id) const {
  string idCopy = id;
  return featureMap.at(idCopy);
}

vector<SelfBakedFeatureType> FeatureCache::Search(string const & query, bool includeHidden) const {
  vector<SelfBakedFeatureType> results;
  string name;
  for (auto& kv : featureMap) {
    SelfBakedFeatureType const & feature = kv.second;
    if (includeHidden || !feature.hiddenFromMap) {
      feature.GetReadableName(name);
      if (name.find(query) != string::npos) {
        results.push_back(feature);
      }
    }
  }
  return results;
}

void FeatureCache::SetCategories(map<string, int> && categories) {
  categoryMap = categories;
  LOG(LINFO, ("Set mapped categories: ", categoryMap.size()));
}

int FeatureCache::GetCategory(string const & category) {
  string lowerCaseCategory = category;
  boost::algorithm::to_lower(lowerCaseCategory);
  boost::replace_all(lowerCaseCategory, " ", "");
  if (categoryMap.count(lowerCaseCategory) > 0) {
    return categoryMap.at(lowerCaseCategory);
  } else {
    return 0;
  }
}
