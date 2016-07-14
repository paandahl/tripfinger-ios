import RealmSwift

class DatabaseMigrations {
  
  class func migrateVersion1() {
    let config = Realm.Configuration(
      schemaVersion: 1,
      
      migrationBlock: { migration, oldSchemaVersion in
        if (oldSchemaVersion < 1) {
          // let it be handled automatically
        }
    })
    
    Realm.Configuration.defaultConfiguration = config
  }
}