#import "RCTBridgeModule.h"
#import "Reachability.h"
#import "AppDelegate.h"
@import Firebase;

@interface BookmarkService : NSObject <RCTBridgeModule>
@end

@implementation BookmarkService {
  BOOL initialized ;
  NSString * userId;
  NSString * listId;
}

static NSString * KEY_MWM_BOOKMARKS_MIGRATED = @"MWM_BOOKMARKS_MIGRATED";
static NSString * KEY_FIREBASE_USER_ID = @"FIR_USER_ID";
static NSString * DB_BOOKMARK_LISTS = @"bookmarkLists";
static NSString * DB_BOOKMARK_ITEMS = @"bookmarkItems";

+ (instancetype)sharedInstance
{
  static BookmarkService *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[BookmarkService alloc] init];
  });
  return sharedInstance;
}

- (id)init
{
  self = [super init];
  initialized = NO;
  return self;
}

+ (void)delay:(int)seconds block:(void(^)())block
{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (UInt64)(seconds * (double)(NSEC_PER_SEC))),
                 dispatch_get_main_queue(), block);

}

- (void)initializeFirebase
{
  if (initialized) {
    NSLog(@"Firebase already initialized.");
    return;
  }
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
  dispatch_async(queue, ^{
    NSLog(@"Initializing firebase");
    initialized = YES;
    [FIRApp configure];
    [FIRDatabase database].persistenceEnabled = YES;
    [self populateUserId];
    //  FIRDatabaseReference * ref = [db reference];
  });
}

- (void)populateUserId
{
  NSString * storeId = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_FIREBASE_USER_ID];
  if (storeId != nil) {
    userId = storeId;
    [self populateListId];
  } else {
    [self createNewUserId];
  }
}

- (void)createNewUserId
{
  if ([Reachability isOnline]) {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
      if (error != nil) {
        NSLog(@"req errored: %@", error);
        [BookmarkService delay:3 block:^{
          [self createNewUserId];
        }];
      } else {
        userId = user.uid;
        [[NSUserDefaults standardUserDefaults] setValue:user.uid forKey:KEY_FIREBASE_USER_ID];
        [self populateListId];
      }
    }];
  } else {
    [BookmarkService delay:3 block:^{
      [self createNewUserId];
    }];
  }
}

- (void)syncUserData {
  [[[[[FIRDatabase database] reference] child:DB_BOOKMARK_LISTS] child:userId] keepSynced:YES];
  [[[[[FIRDatabase database] reference] child:DB_BOOKMARK_ITEMS] child:listId] keepSynced:YES];
}

- (void)populateListId {
  FIRDatabaseReference * userListRef = [[[[FIRDatabase database] reference] child:DB_BOOKMARK_LISTS] child:userId];
  [userListRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    if (![snapshot exists]) {
      NSLog(@"No lists. Creating one.");
      [self createNewListId];
      return;
    }
    NSEnumerator * children = snapshot.children;
    for (FIRDataSnapshot * childSnapshot in children) {
      listId = childSnapshot.key;
      NSLog(@"Got list key: %@", childSnapshot.key);
    }
    [self createItemListener];
  }];
}

- (void)createNewListId
{
  NSDictionary * bookmarkList = @{@"name": @"My Places"};
  FIRDatabaseReference * listRef = [[[[[FIRDatabase database] reference] child:DB_BOOKMARK_LISTS] child:userId] childByAutoId];
  [listRef setValue:bookmarkList];
}

- (void)createItemListener
{
  [self syncUserData];
  FIRDatabaseReference * itemsRef = [[[[FIRDatabase database] reference] child:DB_BOOKMARK_ITEMS] child:listId];
  [itemsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    NSEnumerator * children = snapshot.children;
    NSMutableArray<NSDictionary*> * bookmarks = [[NSMutableArray alloc] init];
    for (FIRDataSnapshot * childSnapshot in children) {
      NSMutableDictionary * bookmarkDict = [[NSMutableDictionary alloc] initWithDictionary:childSnapshot.value];
      bookmarkDict[@"databaseKey"] = childSnapshot.key;
      [bookmarks addObject:bookmarkDict];
    }
    NSLog(@"Fetched %lu bookmarks.", bookmarks.count);
    [AppDelegate setBookmarks:bookmarks];
  }];  
}
  
- (NSString*)addBookmark:(NSDictionary*)bookmark {
  if (listId == nil) {
    return nil;
  }
  FIRDatabaseReference * itemRef = [[[[[FIRDatabase database] reference] child:DB_BOOKMARK_ITEMS] child:listId] childByAutoId];
  [itemRef setValue:bookmark];
  return [itemRef key];
}

- (void)removeBookmark:(NSString*)databaseKey {
  if (listId == nil) {
    return;
  }
  FIRDatabaseReference * itemRef = [[[[[FIRDatabase database] reference] child:DB_BOOKMARK_ITEMS] child:listId] child:databaseKey];
  [itemRef setValue:nil];
}

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(initializeFirebase, exportedInitializeFirebase)
{
  [BookmarkService.sharedInstance initializeFirebase];
}
  
RCT_REMAP_METHOD(addBookmark, addBookmark:(NSDictionary*)bookmark resolver:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject) {
  NSString* key = [BookmarkService.sharedInstance addBookmark:bookmark];
  if (key == nil) {
    NSError* error = [NSError errorWithDomain:@"tripfinger.com" code:10 userInfo:nil];
    reject(@"no_events", @"There were no events", error);
  }
  resolve(key);
}
  
RCT_REMAP_METHOD(removeBookmark, exportedRemoveBookmark:(NSString*)databaseKey) {
  [BookmarkService.sharedInstance removeBookmark:databaseKey];
}

//RCT_EXPORT_METHOD(setNavBarHidden:(BOOL *)hidden)
//{
//  dispatch_async(dispatch_get_main_queue(), ^{
//    UIViewController * root = [UIApplication sharedApplication].delegate.window.rootViewController;
//    UINavigationController * nav = root.childViewControllers[0];
//    [nav setNavigationBarHidden:hidden animated:YES];
//  });
//}

@end
