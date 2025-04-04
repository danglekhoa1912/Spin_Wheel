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

    private let schemaVersionTable = Table("SchemaVersion")
    private let version = SQLite.Expression<Int>("version")
    private let migrations: [(Int, (Connection) throws -> Void)] = []

    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!

            db = try! Connection("\(path)/SpinWheelDatabase.db")
            try! setupDatabase()
        } catch {
            fatalError("Database connection is nil")
        }
    }

    func getDB() -> Connection {
        return db
    }

    private func setupDatabase() throws {
        try db.run(
            schemaVersionTable.create(ifNotExists: true) { table in
                table.column(version)
            })
        try runMigrations()
    }

    private func runMigrations() throws {
        do {
            var currentVersion = 0
            let versionQuery = schemaVersionTable.select(version)
            if let row = try db.pluck(versionQuery) {
                currentVersion = row[version]
            } else {
                try db.run(schemaVersionTable.insert(version <- 0))
            }
            let targetVersion = migrations.map { $0.0 }.max() ?? 0

            for (versionNumber, migration) in migrations
            where currentVersion < versionNumber {
                try migration(db)
                if try db.scalar(schemaVersionTable.count) > 0 {
                    try db.run(
                        schemaVersionTable.update(version <- versionNumber))
                } else {
                    try db.run(
                        schemaVersionTable.insert(version <- versionNumber))
                }
            }
        }
    }
}
