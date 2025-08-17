//
//  NotificationManger.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//


import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request notification permission
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted.")
            } else {
                print("❌ Notification permission denied.")
            }
        }
    }
    
    // Schedule a notification in X seconds
    func scheduleNotification(title: String, seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Timer Complete"
        content.body = "The timer for \(title) is finished."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("📅 Notification scheduled in \(seconds) seconds for task: \(title)")
            }
        }
    }
    
    // Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🔕 All scheduled notifications canceled.")
    }
    
    // Optional: show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
