//
//  SpinWheelsTable.swift
//  WheelSpinApp
//
//  Created by Dang Khoa Dang Le on 29/01/2025.
//

import Firebase
import FirebaseFirestore
import Foundation
import SQLite
import UIKit

struct SpinWheel: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var labels: [String]
    var shareCode: String?
    var isUploadToServer: Bool

    init(title: String, labels: [String]) {
        let deviceId =
            UIDevice.current.identifierForVendor?.uuidString ?? "UnknownDevice"
        self.id = "\(UUID().uuidString)-\(deviceId)"
        self.title = title
        self.labels = labels
        self.isUploadToServer = false
    }

    init(
        id: String, shareCode: String?, title: String, labels: String,
        isUploadToServer: Bool
    ) {
        var decodedArray: [String] = []
        if let jsonData = labels.data(using: .utf8) {
            decodedArray = try! JSONDecoder().decode(
                [String].self, from: jsonData)
        }
        self.shareCode = shareCode
        self.id = id
        self.title = title
        self.labels = decodedArray
        self.isUploadToServer = isUploadToServer ?? false
    }

    init(
        id: String, shareCode: String?, title: String, labels: [String],
        isUploadToServer: Bool
    ) {
        self.shareCode = shareCode
        self.id = id
        self.title = title
        self.labels = labels
        self.isUploadToServer = isUploadToServer ?? false
    }

    var labelsJson: String {
        let jsonData = try! JSONEncoder().encode(self.labels)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case labels
        case shareCode
        case isUploadToServer
    }
}

class SpinWheelsTable: ObservableObject {
    static let shared = SpinWheelsTable(db: DatabaseManager.shared.getDB())
    let device = UIDevice.current

    private var db: Connection
    private var dbFirebase = Firestore.firestore()

    @Published var spinWheels: [SpinWheel] = []

    private let spinWheelTable = Table("SpinWheels")
    private let id = SQLite.Expression<String>("id")
    private let shareCode = SQLite.Expression<String?>("shareCode")
    private let title = SQLite.Expression<String>("title")
    private let labels = SQLite.Expression<String>("labels")
    private let isUploadToServer = SQLite.Expression<Bool>("isUploadToServer")

    let notification = NotificationManager.shared

    init(db: Connection) {
        self.db = db
        do {
            try db.run(
                spinWheelTable.create(ifNotExists: true) { table in
                    table.column(id, primaryKey: true)
                    table.column(title)
                    table.column(labels)
                    table.column(shareCode, unique: true)
                    table.column(isUploadToServer, defaultValue: false)
                })
            Task {
                await loadSpinWheels()
            }
        } catch {
            print("⚠️ Lỗi khi migrate bảng: \(error)")
        }

        Task {
            await loadSpinWheels()
        }
    }

    func createSpinWheel(spinWheel: SpinWheel) async -> Int64 {
        do {
            let insert = spinWheelTable.insert(
                self.id <- spinWheel.id,
                self.title <- spinWheel.title,
                self.labels <- spinWheel.labelsJson,
                self.shareCode <- spinWheel.shareCode ?? ""
            )
            let spinWheelId = try self.db.run(insert)
            await MainActor.run {
                self.spinWheels.append(spinWheel)
            }
            return spinWheelId
        } catch {
            print(error)
        }
        return 0
    }

    func deleteSpinWheel(id: String) async -> Bool {
        do {
            let query = spinWheelTable.filter(self.id == id)
            let rowsDeleted = try db.run(query.delete())
            if rowsDeleted > 0 {
                await MainActor.run {
                    self.spinWheels.removeAll { $0.id == id }
                }
                return true
            }
            return false
        } catch {
            print("❌ Lỗi khi xóa SpinWheel: \(error)")
            return false
        }
    }

    private func loadSpinWheels() async {
        var spinWheelList = [SpinWheel]()
        do {
            for item in try db.prepare(spinWheelTable) {
                spinWheelList.append(
                    SpinWheel(
                        id: item[id], shareCode: item[shareCode],
                        title: item[title], labels: item[labels],
                        isUploadToServer: item[isUploadToServer]))
            }
            await MainActor.run {
                self.spinWheels = spinWheelList
            }
        } catch {
            print(error)
        }
    }

    func saveToFirestore(spinWheel: SpinWheel) async -> String? {
        do {
            print(spinWheel.isUploadToServer)
            if spinWheel.isUploadToServer {
                return spinWheel.shareCode
            }
            let ref = try dbFirebase.collection("spinWheelsShared").addDocument(
                from: spinWheel)
            let documentID = ref.documentID
            print("✅ Đã lưu SpinWheel vào Firestore với ID: \(documentID)")
            await updateSpinWheel(
                spinWheel: SpinWheel(
                    id: spinWheel.id, shareCode: documentID,
                    title: spinWheel.title, labels: spinWheel.labelsJson,
                    isUploadToServer: true))
            return documentID
        } catch {
            print("❌ Lỗi khi lưu SpinWheel vào Firestore: \(error)")
            return nil
        }
    }

    func addSpinWheelFromShareCode(code: String) async {
        do {
            print(await !isExistByShareCode(shareCode: code))
            if await isExistByShareCode(shareCode: code) {
                notification.showNotification(
                    title: "Wheel already exists", isError: true)
            } else {
                let deviceId =
                    await UIDevice.current.identifierForVendor?.uuidString
                    ?? "UnknownDevice"
                let query = dbFirebase.collection("spinWheelsShared").document(
                    code)
                let snapshot = try await query.getDocument()
                var spinWheel = try snapshot.data(as: SpinWheel.self)
                spinWheel.shareCode = code
                spinWheel.id = "\(UUID().uuidString)-\(deviceId)"
                await createSpinWheel(spinWheel: spinWheel)
                notification.showNotification(
                    title: "Wheel added successfully", isError: false)
                print(
                    "✅ Đã lấy SpinWheel từ Firestore với shareCode: \(code)"
                )

            }

        } catch {
            notification.showNotification(
                title: "Error when adding wheel", isError: true)
            print("❌ Lỗi khi lấy SpinWheel từ Firestore: \(error)")
        }

    }

    func getSpinWheels() async -> [SpinWheel] {
        var spinWheelList = [SpinWheel]()

        do {
            for item in try db.prepare(spinWheelTable) {
                spinWheelList.append(
                    SpinWheel(
                        id: item[id], shareCode: item[shareCode],
                        title: item[title], labels: item[labels],
                        isUploadToServer: item[isUploadToServer]))
            }
        } catch {
            notification.showNotification(
                title: "Error when get wheel list! Please try again",
                isError: true)
            print(error)
        }

        return spinWheelList
    }

    func getSpinWheelDetail(id: String) async -> SpinWheel? {
        do {
            let query = spinWheelTable.filter(self.id == id)
            if let item = try db.pluck(query) {
                return SpinWheel(
                    id: item[self.id], shareCode: item[self.shareCode],
                    title: item[self.title],
                    labels: item[self.labels],
                    isUploadToServer: item[self.isUploadToServer]
                )
            }
        } catch {
            notification.showNotification(
                title: "Error when get wheel list! Please try again",
                isError: true)
            print("❌ Lỗi khi lấy dữ liệu từ SQLite: \(error)")
        }
        return nil
    }

    func getSpinWheelByShareCode(_ code: String) async -> SpinWheel? {
        do {
            let query = spinWheelTable.filter(self.shareCode == code)
            if let item = try db.pluck(query) {
                return SpinWheel(
                    id: item[self.id],
                    shareCode: item[self.shareCode],
                    title: item[self.title],
                    labels: item[self.labels],
                    isUploadToServer: item[self.isUploadToServer]
                )
            }
        } catch {
            notification.showNotification(
                title: "Error when get wheel! Please try again", isError: true)
            print("❌ Lỗi khi tìm SpinWheel bằng shareCode: \(error)")
        }
        return nil
    }

    func updateIsUpload(id: String, value: Bool) -> Bool {
        do {
            let spinwheelToUpdate = spinWheelTable.filter(self.id == id)
            try db.run(
                spinwheelToUpdate.update(
                    isUploadToServer <- value
                ))
            notification.showNotification(
                title: "Wheel updated successfully", isError: false)
            return true
        } catch {
            notification.showNotification(
                title: "Error when update wheel", isError: true)
            print("❌ Lỗi khi update SpinWheel: \(error)")
        }
        return false
    }

    @MainActor
    func updateSpinWheel(spinWheel: SpinWheel) -> SpinWheel? {
        do {
            let spinwheelToUpdate = spinWheelTable.filter(
                self.id == spinWheel.id)
            try db.run(
                spinwheelToUpdate.update(
                    title <- spinWheel.title,
                    labels <- spinWheel.labelsJson,
                    shareCode <- spinWheel.shareCode,
                    isUploadToServer <- spinWheel.isUploadToServer
                ))
            if let index = spinWheels.firstIndex(where: {
                $0.id == spinWheel.id
            }) {
                spinWheels[index] = spinWheel  // Thay thế item cũ bằng item mới
            } else {
                spinWheels.append(spinWheel)  // Nếu không tìm thấy, thêm mới (tùy trường hợp)
            }
            return spinWheel
        } catch {
            print("❌ Lỗi khi update SpinWheel: \(error)")
        }
        return nil
    }

    func isExistByShareCode(shareCode: String) async -> Bool {
        do {
            let query = spinWheelTable.filter(self.shareCode == shareCode)
            if let item = try db.pluck(query) {
                return true
            }
        } catch {
            print("❌ Lỗi khi lấy dữ liệu từ SQLite: \(error)")
        }
        return false
    }
}
