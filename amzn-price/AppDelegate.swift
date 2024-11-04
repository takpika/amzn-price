//
//  AppDelegate.swift
//  amzn-price
//
//  Created by takumi saito on 2019/10/11.
//  Copyright © 2019 takpika. All rights reserved.
//

import UIKit
import BackgroundTasks
import Ji

extension String {
    func replace(_ from: String,_ to: String) -> String {
        var replacedString = self
        replacedString = replacedString.replacingOccurrences(of: from, with: to)

        return replacedString
    }
}

//let password = "niconiconetchokaigi2020"

class BackgroundOperation: Operation{
    var data: [Product]
    let isfirst = UserDefaults.standard.object(forKey: "isfirst") as! Bool
    
    init(data: [Product]){
        self.data = data
    }
    
    override func main(){
        func load_a(id:String) -> [String:Any]{
            print("Start: load \(id)")
            let date = Date()
            if id != "" {
                let urlstr = "https://www.amazon.co.jp/dp/\(id)"
                //let urlstr = "https://www.google.com/"
                let url = URL(string: urlstr)
                var sourceHTML = ""
                do{
                    sourceHTML = try String(contentsOf: url!)
                }catch{
                    sourceHTML = "ERROR!!"
                }
                let jiDoc = Ji(htmlString: sourceHTML)
                let page_title = jiDoc?.xPath("//title")?.first?.content!
                if !page_title!.contains("ページが見つかりません"){
                    let title = jiDoc?.xPath("//span[@id='productTitle']")?.first?.content!
                    let product_title = title?.trimmingCharacters(in: .whitespacesAndNewlines)
                    let available_label = jiDoc?.xPath("//div[@id='availability']/span[contains(@class,'a-size-medium')]")?.first?.content!
                    let ava_label = available_label?.trimmingCharacters(in: .whitespacesAndNewlines)
                    var price: Int
                    let available = ava_label!.contains("在庫切れ")
                    let available2 = ava_label!.contains("からお求めいただけます")
                    if available{
                        //在庫切れ
                        price = 0
                    }else if !available && !available2{
                        //在庫あり
                        let price_label = jiDoc?.xPath("//span[@id='priceblock_ourprice']")?.first?.content!
                        let price_label2 = price_label?.trimmingCharacters(in: .whitespacesAndNewlines) as! String
                        let price_label3 = price_label2.replace("¥", "").replace(",", "")
                        price = Int(price_label3)!
                    }else{
                        //出品者から購入
                        let price_label =
                            jiDoc?.xPath("//div[@id='unqualifiedBuyBox']/div[@class='a-box-inner']/div[@contains(@class,'a-text-center')]/span[@class='a-color-price']")?.first?.content!
                        let price_label2 = price_label?.trimmingCharacters(in: .whitespacesAndNewlines) as! String
                        let price_label3 = price_label2.replace("¥", "").replace(",", "")
                        price = Int(price_label3)!
                    }
                    //return product_title!
                    return ["id":id,"title":product_title!,"price":price,"available":!available, "market_p": !available2, "date": date]
                    //return "Hello"
                }else{
                    return ["id":id,"price":0,"available":false,"market_p": false, "date": date]
                }
            }else{
                return ["id":id,"price":0,"available":false,"market_p": false, "date": date]
            }
        }
        var newdata: [Product] = []
        for i in 0..<data.count{
            let pro_data = data[i]
            let id = pro_data.id
            var title = pro_data.title
            var dates = pro_data.dates
            var prices = pro_data.prices
            var availables = pro_data.availables
            var market_p = pro_data.market_p
            let results = load_a(id: id)
            print("finish: load \(id)")
            dates.append(results["date"] as! Date)
            prices.append(results["price"] as! Int)
            availables.append(results["available"] as! Bool)
            market_p.append(results["market_p"] as! Bool)
            if results["available"] as! Bool == false{
                title = results["title"] as! String
            }
            if isfirst != nil{
                if isfirst{
                    var lowest: Int = 9999999999
                    let price = results["price"] as! Int
                    for x in 0..<pro_data.prices.count{
                        if pro_data.prices[x] < lowest && pro_data.prices[x] != 0 && pro_data.prices[x] != 9999999{
                            lowest = pro_data.prices[x]
                        }
                    }
                    if price < lowest && price != 0 && price != 9999999{
                        let notification = UNMutableNotificationContent()
                        notification.title = "商品が安くなりました！"
                        notification.body = "\(title)が安くなりました！: ¥\(results["price"] as! Int)"
                    }
                }
            }
            newdata.append(Product(id: id, title: title, dates: dates, prices: prices, availables: availables, market_p: market_p))
        }
        data = newdata
        save()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "takpika.amzn-price.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }
    
    private func scheduleAppRefresh(){
        let request = BGAppRefreshTaskRequest(identifier: "takpika.amzn-price.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do{
            try BGTaskScheduler.shared.submit(request)
        }catch{
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask){
        print("handleAppRefresh")
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        reload()
        let operation = BackgroundOperation(data: data)
        operation.completionBlock = {
            task.setTaskCompleted(success: operation.isFinished)
        }
        queue.addOperation(operation)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Background")
        NSLog("Background")
        scheduleAppRefresh()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

