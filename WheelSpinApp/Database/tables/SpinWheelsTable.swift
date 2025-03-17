//
//  SpinWheelsTable.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 29/01/2025.
//

import Foundation
import SQLite
import UIKit

struct SpinWheel: Identifiable {
    let id: String
    var title: String
    var labels: [String]

    init(title: String, labels: [String]) {
        let deviceId =
            UIDevice.current.identifierForVendor?.uuidString ?? "UnknownDevice"
        self.id = "\(UUID().uuidString)-\(deviceId)"
        self.title = title
        self.labels = labels
    }

    init(id: String, title: String, labels: String) {
        var decodedArray: [String] = []
        if let jsonData = labels.data(using: .utf8) {
            decodedArray = try! JSONDecoder().decode(
                [String].self, from: jsonData)
        }

        self.id = id
        self.title = title
        self.labels = decodedArray
    }

    var labelsJson: String {
        let jsonData = try! JSONEncoder().encode(self.labels)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

class SpinWheelsTable {
    static let shared = SpinWheelsTable(db: DatabaseManager.shared.getDB())
    let device = UIDevice.current

    private var db: Connection

    private let spinWheelTable = Table("SpinWheels")
    private let id = SQLite.Expression<String>("id")
    private let title = SQLite.Expression<String>("title")
    private let labels = SQLite.Expression<String>("labels")

    init(db: Connection) {
        self.db = db

        do {
            try db.run(
                spinWheelTable.create(ifNotExists: true) { table in
                    table.column(id, primaryKey: true)
                    table.column(title)
                    table.column(labels)
                })
        } catch {
            print(error)
        }
    }

    func createSpinWheel(spinWheel: SpinWheel) -> Int64 {
        do {
            let insert = spinWheelTable.insert(
                self.id <- spinWheel.id,
                self.title <- spinWheel.title,
                self.labels <- spinWheel.labelsJson
            )
            let spinWheelId = try self.db.run(insert)
            return spinWheelId
        } catch {
            print(error)
        }
        return 0
    }

    func getSpinWheels() async -> [SpinWheel] {
        var spinWheelList = [SpinWheel]()

        do {
            for item in try db.prepare(spinWheelTable) {
                spinWheelList.append(
                    SpinWheel(
                        id: item[id], title: item[title], labels: item[labels]))
            }
        } catch {
            print(error)
        }

        return spinWheelList
    }

    func getSpinWheelDetail(id: String) async -> SpinWheel? {
        do {
            let query = spinWheelTable.filter(self.id == id)
            if let item = try db.pluck(query) {
                return SpinWheel(
                    id: item[self.id],
                    title: item[self.title],
                    labels: item[self.labels]
                )
            }
        } catch {
            print("❌ Lỗi khi lấy dữ liệu từ SQLite: \(error)")
        }
        return nil
    }
}
