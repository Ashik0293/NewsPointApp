//
//  AppDelegate.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import UIKit
import CoreData
import BackgroundTasks
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundFetchTimer: Timer?
    let newsRefreshIdentifier = "com.NewsPoint.newsRefresh"
    let minimumRefreshInterval: TimeInterval = 10

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTasks()
        
        FirebaseApp.configure()
        scheduleAppRefresh()
        
        return true
    }

    //MARK: Google SignIN Setup
    
    func application(_ app: UIApplication,
                         open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {

            return GIDSignIn.sharedInstance.handle(url)
        }
    
    
    // MARK: - Background Task Setup
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: newsRefreshIdentifier,
                                       using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: newsRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: minimumRefreshInterval)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled")
        } catch {
            print("Could not schedule app refresh: \(error)")
            setupLocalTimerFallback()
        }
    }
    
    // MARK: - Background Task Handler
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        
        let fetchOperation = BlockOperation {
            self.fetchLatestNews { success in
                task.setTaskCompleted(success: success)
            }
        }
        
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        
        queue.addOperation(fetchOperation)
    }
    
    // MARK: - News Fetching
    
    private func fetchLatestNews(completion: @escaping (Bool) -> Void) {
        let apiService = APIService()
        apiService.fetchNews { result in
            switch result {
            case .success(let articles):
                
                NewsManager.shared.articles = articles
                //.articles = articles
                completion(true)
                
            case .failure(let error):
                print("Background fetch failed: \(error)")
                completion(false)
            }
        }
    }

  
    // MARK: - Fallback Timer
    
    private func setupLocalTimerFallback() {
        // Only use timer fallback when in foreground
        backgroundFetchTimer?.invalidate()
        backgroundFetchTimer = Timer.scheduledTimer(withTimeInterval: minimumRefreshInterval,
                                                 repeats: true) { _ in
            if UIApplication.shared.applicationState == .active {
                self.fetchLatestNews { _ in
                    // Completion handling if needed
                }
            }
        }
    }
    
    // MARK: - Silent Push Notifications (Optional)
    
    func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if userInfo["silent"] as? Bool == true {
            fetchLatestNews { success in
                completionHandler(success ? .newData : .failed)
            }
        } else {
            completionHandler(.noData)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle discarded scenes
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsPointEntity")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// Notification extension
extension Notification.Name {
    static let newDataAvailable = Notification.Name("newDataAvailable")
}
