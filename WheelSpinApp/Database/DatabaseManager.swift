//
//  DatabaseManager.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 29/01/2025.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let db: Connection
    
    init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        db = try! Connection("\(path)/SpinWheelDatabase.db")
    }
    
    func getDB() -> Connection {
        return db
    }
}
