//
//  WRDataBaseManager.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

/**
 * This is a deep databse layer for our apps
 * it contains all models simple save, delete
 * update, query operation for all models, it
 * is used to cache all model data and display
 * cache info while network is offline mode
 **/
class WRDatabaseClient {
    //Singleton design pattern
    static var sharedInstance: WRDatabaseClient {
        struct Singleton {
            static let instance: WRDatabaseClient = WRDatabaseClient()
        }
        return Singleton.instance
    }
    //the sqlite database stored path
    private var dbPath: String
    //the sqlite databse queue executor
    private var dbQueue: FMDatabaseQueue
    
    private var documentDir: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    init() {
        dbPath = "\(documentDir)/weatherReport.sqlite"
        dbQueue = FMDatabaseQueue(path:dbPath)!
    }
    
    convenience init(forTest: Bool) {
        self.init()
        if forTest {
            dbPath = "\(documentDir)/weatherReportTest.sqlite"
            dbQueue = FMDatabaseQueue(path:dbPath)!
        }
    }
    
    //confirm the database whether owns the initialed tables
    func isDatabaseAvailable() -> Bool {
        //confirm the database path created
        let pathAvailable = FileManager.default.fileExists(atPath: self.dbPath)
        var count = 0;
        if pathAvailable {
            //confirm the tables created
            self.dbQueue.inDatabase { (db) in
                do {
                    let result: FMResultSet = try db.executeQuery("SELECT count(*) FROM sqlite_master where type='table';", values: nil)
                    while result.next() {
                        count = Int(result.int(forColumnIndex: 0))
                    }
                } catch {
                    print("sqlite_master select error.")
                }
            }
        }
        
        return pathAvailable && count > 0
    }
    
    //create tables for all related models
    func register(_ models: [WRDatabaseModelProtocol]) {
        if !isDatabaseAvailable() {
            models.forEach { (protocolObj) in
                self.dbQueue.inDatabase { (db) in
                    do {
                        try db.executeUpdate(protocolObj.sqlTableString(), values: nil)
                    } catch {
                        print("Register Table \(protocolObj.sqlTableName()) error")
                    }
                }
            }
        }
    }
    
    //save one model data in databse
    func saveObj(_ model: WRDatabaseModelProtocol) -> Bool {
        var res = true
        self.dbQueue.inDatabase { (db) in
            let executeSql = "INSERT INTO \(model.sqlTableName())(\(model.sqlTableKeys())) VALUES (\(model.sqlTableValues()));"
            res = db.executeUpdate(executeSql, withArgumentsIn: model.sqlTableValues().components(separatedBy: ","))
        }
        return res
    }
    
    //query one model data info from database
    func query(_ model: WRDatabaseModelProtocol) -> [String: Any]? {
        var resultModel: [[String: Any]] = [[String: Any]]()
        self.dbQueue.inDatabase { (db) in
            do {
                var executeSql = "SELECT * FROM \(model.sqlTableName()) WHERE cityName='\(model.cityString())'"
                if let sqlOrderBy = model.sqlTableOrderBy() {
                    executeSql = "\(executeSql) \(sqlOrderBy)"
                }
                executeSql = "\(executeSql);"
                let result:FMResultSet = try db.executeQuery(executeSql, values: nil)
                
                while(result.next()) {
                    let objInfo:[String: Any] = result.resultDictionary as! [String : Any]
                    resultModel.append(objInfo)
                }
            } catch {
                print("select table \(model.sqlTableName()) error")
            }
        }
        if resultModel.count > 0 {
            return resultModel.first
        }
        return nil
    }
    
    //query all data model info from database
    func queryAll(_ model: WRDatabaseModelProtocol) -> [[String: Any]] {
        var resultModel: [[String: Any]] = [[String: Any]]()
        self.dbQueue.inDatabase { (db) in
            do {
                let executeSql = "SELECT * FROM \(model.sqlTableName());"
                let result:FMResultSet = try db.executeQuery(executeSql, values: nil)
                
                while(result.next()) {
                    let objInfo:[String: Any] = result.resultDictionary as! [String : Any]
                    resultModel.append(objInfo)
                }
            } catch {
                print("select all table error")
            }
        }
        return resultModel
    }
    
    //query all model data count number in database
    func queryCount(_ model: WRDatabaseModelProtocol) -> Int {
        var count = 0
        self.dbQueue.inDatabase { (db) in
            do {
                let executeSql = "SELECT count(*) FROM \(model.sqlTableName());"
                let result:FMResultSet = try db.executeQuery(executeSql, values: nil)
                
                while(result.next()) {
                    count = Int(result.int(forColumnIndex: 0))
                }
            } catch {
                print("select model count error")
            }
        }
        return count
    }
}
