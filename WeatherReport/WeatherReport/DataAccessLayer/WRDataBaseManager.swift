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
}

class WRDataBaseManager {
    static var sharedInstance: WRDataBaseManager {
        struct Singleton {
            static let instance: WRDataBaseManager = WRDataBaseManager()
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
    
    func register(_ models: [WRDatabaseModelProtocol]) {
        for protocolObj in models {
            self.dbQueue.inDatabase { (db) in
                try! db.executeUpdate(protocolObj.sqlTableString(), values: nil)
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
    
    func query(_ model: WRDatabaseModelProtocol) -> [WRBasicModel] {
        var resultModel: [WRBasicModel] = [WRBasicModel]()
        self.dbQueue.inDatabase { (db) in
            let executeSql = "SELECT * FROM \(model.sqlTableName());"
            let result:FMResultSet = try! db.executeQuery(executeSql, values: nil)
            
            while(result.next()) {
                let classObj = type(of: model)
                var obj: classObj = classObj()
                let objInfo:[String: String] = result.resultDictionary
                for key in objInfo.keys {
                    obj.setValue(objInfo[key], forKeyPath:key)
                }
                resultModel.append(obj)
            }
        }
        return resultModel
    }
}
