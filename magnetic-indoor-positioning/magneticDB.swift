//
//  magneticDB.swift
//  magnetic-indoor-positioning
//

import SQLite

class MagneticDB {
    fileprivate let db: Connection?
    fileprivate let data = Table("data")
    
    fileprivate let id = Expression<Int64>("id")
    fileprivate let x = Expression<Int64>("x")
    fileprivate let y = Expression<Int64>("y")
    fileprivate let angle = Expression<Int64>("angle")
    fileprivate let magx = Expression<Double>("magx")
    fileprivate let magy = Expression<Double>("magy")
    fileprivate let magz = Expression<Double>("magz")
    fileprivate let mag = Expression<Double>("mag")
    fileprivate let date = Expression<String>("date")
    
    init() {
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.edu.um.plusa.sharedDefault")!.path
        
        do {
            db = try Connection("\(path)/data.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(data.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(x)
                table.column(y)
                table.column(angle)
                table.column(magx)
                table.column(magy)
                table.column(magz)
                table.column(mag)
                table.column(date)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func insertData(x: Int64, y: Int64, angle: Int64, magx: Double, magy: Double, magz: Double, mag: Double, date: String) -> Int64? {
        createTable()
        do {
            let rowid = try db?.run(data.insert(self.x <- x, self.y <- y, self.angle <- angle, self.magx <- magx, self.magy <- magy, self.magz <- magz, self.mag <- mag, self.date <- date))
            print("inserted id: \(rowid!)")
            return rowid!
        } catch {
            print("Insertion failed: \(error)")
            return nil
        }
    }
    
    func queryData(completion: (Array<Dictionary<String, String>>) -> ()) {
        
        var array = [[String:String]]()
        
        do {
            if let stmt = try db?.prepare(data) {
                var dict: Dictionary<String, String> = Dictionary()
                for tmp in stmt {
//                    print("\(tmp[date]) Point(\(tmp[x]), \(tmp[y])) at \(tmp[angle]): \(tmp[mag])")
                    dict["id"] = String(tmp[id])
                    dict["date"] = tmp[date]
                    dict["x"] = String(tmp[x])
                    dict["y"] = String(tmp[y])
                    dict["angle"] = String(tmp[angle])
                    dict["mag"] = String(tmp[mag])
                    array.append(dict)
                }
            }
        } catch {
            print("Query failed: \(error)")
        }
        completion(array)
    }
    
    func deleteData(x:Int64, y:Int64, angle:Int64, mag:Double, date:String) {
        // variable 'mag' is not being used
        do {
            let dataToDelete = data.filter(self.x == x && self.y == y && self.angle == angle && self.date == date)
            print("\(dataToDelete)")
            if let numberOfDeletedRow = try (db?.run(dataToDelete.delete())) {
                print("Deleted \(numberOfDeletedRow) row(s) of data.")
            }
        } catch {
            print("Delete failed: \(error)")
        }
    }
    
    func flushAllData() -> Bool {
        do {
            try db?.run(data.drop(ifExists: true))
            return true
        } catch {
            print("Drop failed: \(error)")
            return false
        }
    }
}
