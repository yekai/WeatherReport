//
//  WRDataBaseManager.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

protocol WRDatabaseModelProtocol {
    func sqlTableName() -> String
    func sqlTableString() -> String
    func sqlTableKeys() -> String
    func sqlTableValues() -> String
    func cityString() -> String
    func sqlTableOrderBy() -> String?
}

class WRDatabaseClient {
    static var sharedInstance: WRDatabaseClient {
        struct Singleton {
            static let instance: WRDatabaseClient = WRDatabaseClient()
        }
        return Singleton.instance
    }
    
    private var dbPath: String
    private var dbQueue: FMDatabaseQueue
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        self.dbPath = "\(path)/weatherReport.sqlite"
        self.dbQueue = FMDatabaseQueue(path:dbPath)!
    }
    
    func isDatabaseAvailable() -> Bool {
        let pathAvailable = FileManager.default.fileExists(atPath: self.dbPath)
        var count = 0;
        if pathAvailable {
            self.dbQueue.inDatabase { (db) in
                let result: FMResultSet = try! db.executeQuery("SELECT count(*) FROM sqlite_master where type='table';", values: nil)
                while result.next() {
                    count = Int(result.int(forColumnIndex: 0))
                }
            }
        }
        
        return pathAvailable && count > 0
    }
    
    func register(_ models: [WRDatabaseModelProtocol]) {
        if !isDatabaseAvailable() {
            for protocolObj in models {
                self.dbQueue.inDatabase { (db) in
                    try! db.executeUpdate(protocolObj.sqlTableString(), values: nil)
                }
            }
        }
    }
    
    func saveObj(_ model: WRDatabaseModelProtocol) -> Bool {
        var res = true
        self.dbQueue.inDatabase { (db) in
            let executeSql = "INSERT INTO \(model.sqlTableName())(\(model.sqlTableKeys())) VALUES (\(model.sqlTableValues()));"
            res = db.executeUpdate(executeSql, withArgumentsIn: model.sqlTableValues().components(separatedBy: ","))
        }
        return res
    }
    
    func query(_ model: WRDatabaseModelProtocol) -> [String: Any]? {
        var resultModel: [[String: Any]] = [[String: Any]]()
        self.dbQueue.inDatabase { (db) in
            var executeSql = "SELECT * FROM \(model.sqlTableName()) WHERE cityName='\(model.cityString())'"
            if let sqlOrderBy = model.sqlTableOrderBy() {
                executeSql = "\(executeSql) \(sqlOrderBy)"
            }
            executeSql = "\(executeSql);"
            let result:FMResultSet = try! db.executeQuery(executeSql, values: nil)
            
            while(result.next()) {
                let objInfo:[String: Any] = result.resultDictionary as! [String : Any]
                resultModel.append(objInfo)
            }
        }
        if resultModel.count > 0 {
            return resultModel.first
        }
        return nil
    }
    
    func queryAll(_ model: WRDatabaseModelProtocol) -> [[String: Any]] {
        var resultModel: [[String: Any]] = [[String: Any]]()
        self.dbQueue.inDatabase { (db) in
            let executeSql = "SELECT * FROM \(model.sqlTableName());"
            let result:FMResultSet = try! db.executeQuery(executeSql, values: nil)
            
            while(result.next()) {
                let objInfo:[String: Any] = result.resultDictionary as! [String : Any]
                resultModel.append(objInfo)
            }
        }
        return resultModel
    }
    
    func queryCount(_ model: WRDatabaseModelProtocol) -> Int {
        var count = 0
        self.dbQueue.inDatabase { (db) in
            let executeSql = "SELECT count(*) FROM \(model.sqlTableName());"
            let result:FMResultSet = try! db.executeQuery(executeSql, values: nil)
            
            while(result.next()) {
                count = Int(result.int(forColumnIndex: 0))
            }
        }
        return count
    }
}
