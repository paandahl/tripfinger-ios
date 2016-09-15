import Foundation
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

protocol BookmarkListener: class {
  func bookmarksUpdated(bookmarks: [BookmarkItem])
}

class BookmarkService: NSObject {

  private static let KEY_MWM_BOOKMARKS_MIGRATED = "MWM_BOOKMARKS_MIGRATED"
  private static let KEY_FIREBASE_USER_ID = "FIR_USER_ID"
  private static let DB_BOOKMARK_LISTS = "bookmarkLists"
  private static let DB_BOOKMARK_ITEMS = "bookmarkItems"

  private var bookmarkedListings = Set<String>()
  private var userId: String?
  private var listId: String?
  private var delegate: BookmarkListener!
  
  init(delegate: BookmarkListener) {
    self.delegate = delegate
    super.init()
    FIRDatabase.database().persistenceEnabled = true
    populateUserId()
  }

  private func populateUserId() {
    let storedId = NSUserDefaults.standardUserDefaults().stringForKey(BookmarkService.KEY_FIREBASE_USER_ID)
    if let storedId = storedId {
      userId = storedId
      populateListId()
    } else {
      createNewUserId()
    }
  }
  
  private func createNewUserId() {
    if NetworkUtil.connectedToNetwork() {
      FIRAuth.auth()!.signInAnonymouslyWithCompletion { (user, error) in
        if error != nil {
          print("req errored: \(error)")
          SyncManager.delay(3, closure: self.createNewUserId)
        } else {
          self.userId = user!.uid
          NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: BookmarkService.KEY_FIREBASE_USER_ID)
          self.populateListId()
        }
      }
    } else {
      SyncManager.delay(3, closure: createNewUserId)
    }
  }
  
  private func syncUserData() {
    FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_LISTS)
      .child(userId!)
      .keepSynced(true)
    FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_ITEMS)
      .child(listId!)
      .keepSynced(true)
  }
  
  private func populateListId() {
    let userListsRef = FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_LISTS)
      .child(userId!)
    userListsRef.keepSynced(true)
    userListsRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
      if !snapshot.exists() {
        print("no lists. creating one.")
        self.createNewListId()
        return
      }
      let children = snapshot.children
      while let childSnap: AnyObject = children.nextObject() {
        let childSnapshot = childSnap as! FIRDataSnapshot
        self.listId = childSnapshot.key
        print("Got list key: " + childSnapshot.key)
      }
      self.createItemListener()
    })
  }
  
  private func createNewListId() {
    let list = BookmarkList(name: "My Places")
    let listRef = FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_LISTS)
      .child(userId!).childByAutoId()
    listRef.setValue(list.toDict())
  }
  
  private func createItemListener() {
    syncUserData()
    let itemsRef = FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_ITEMS)
      .child(listId!)
    itemsRef.observeEventType(.Value, withBlock: { (snapshot) -> Void in
      let children = snapshot.children
      var bookmarks = [BookmarkItem]()
      var bookmarkedListings = Set<String>()
      while let childSnap: AnyObject = children.nextObject() {
        let childSnapshot = childSnap as! FIRDataSnapshot
        let bookmarkDict = childSnapshot.value as! [String : AnyObject]
        let bookmark = BookmarkItem(dict: bookmarkDict)
        bookmark.databaseKey = childSnapshot.key
        bookmarks.append(bookmark)
        if let listingId = bookmark.listingId {
          bookmarkedListings.insert(listingId)
        }
      }
      print("Fetched \(bookmarks.count) bookmarks.")
      self.bookmarkedListings = bookmarkedListings
      self.delegate.bookmarksUpdated(bookmarks)
    })
  }
  
  func isListingBookmarked(listingId: String) -> Bool {
    return bookmarkedListings.contains(listingId)
  }
  
  func addBookmark(bookmark: BookmarkItem) {
    guard let listId = listId else {
      return
    }
    let itemRef = FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_ITEMS)
      .child(listId).childByAutoId()
    itemRef.setValue(bookmark.toDict())
  }
  
  func updateBookmark(bookmark: BookmarkItem) {
    guard let listId = listId else {
      return
    }
    guard let databaseKey = bookmark.databaseKey else {
      print("Tried to update bookmark without databaseKey set.")
      return
    }
    let itemRef = FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_ITEMS)
      .child(listId).child(databaseKey)
    itemRef.setValue(bookmark.toDict())
  }

  func removeBookmarkForListing(listingId: String) {
    
  }

  func removeBookmark(bookmark: BookmarkItem) {
    guard let listId = listId else {
      return
    }
    guard let databaseKey = bookmark.databaseKey else {
      print("Tried to update bookmark without databaseKey set.")
      return
    }
    let itemRef = FIRDatabase.database().reference()
      .child(BookmarkService.DB_BOOKMARK_ITEMS)
      .child(listId).child(databaseKey)
    itemRef.setValue(nil)
  }
  
  func isBookmarkMigrationDone() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(BookmarkService.KEY_MWM_BOOKMARKS_MIGRATED)
  }
  
  func setBookmarksMigrated() {
    NSUserDefaults.standardUserDefaults().setValue(true, forKey: BookmarkService.KEY_MWM_BOOKMARKS_MIGRATED)
  }
}