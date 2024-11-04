//
//  Data.swift
//  amzn-price
//
//  Created by takumi saito on 2019/10/13.
//  Copyright © 2019 takpika. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Ji
import SwiftUICharts

var product_id = "B07G8C9CPB"
let passw = "niconiconetchokaigi2020"
let t_f = time_setup(type: 1)
var now_watching = 0
var message = ""


func setup() -> [Product]{
    reload()
    return data
}

func notice_setup() -> Bool{
    let isfirst = UserDefaults.standard.object(forKey: "isfirst")
    if isfirst == nil{
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            if error != nil{
                return
            }
            
            if granted{
                print("通知許可")
            }else{
                print("通知拒否")
            }
            UserDefaults.standard.set(granted, forKey: "isfirst")
        })
    }
    return true
}

func add(id: String) -> String{
    var id_data:[String] = []
    for i in 0..<data.count {
        id_data.append(data[i].id)
    }
    if id_data.contains(id){
        return "既にこの商品は追加されています。"
    }else{
        data.append(Product(id: id, title: "再読み込みしてください。", dates: [Date()], prices: [9999999], availables: [false], market_p: [false]))
        return "商品を追加しました。再読み込みしてください。"
    }
}

func get_number(id: String) -> Int{
    var id_data:[String] = []
    for i in 0..<data.count {
        id_data.append(data[i].id)
    }
    var result = 0
    for i in 0..<id_data.count{
        if id_data[i] == id{
            result = i
        }
    }
    return result
}

func make_data(number: Int) -> ChartData{
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd"
    let conv_data = data[number]
    var last_date = format.date(from: "1970-01-01")
    var result: [(String,Double)] = []
    for i in 0..<conv_data.prices.count{
        if t_f.string(from:conv_data.dates[i]) != t_f.string(from:last_date!) && conv_data.prices[i] != 9999999{
            result.append((t_f.string(from: conv_data.dates[i]),Double(conv_data.prices[i])))
            last_date = conv_data.dates[i]
        }
    }
    return ChartData(values: result)
}

func refresh(){
    var newdata: [Product] = []
    for i in 0..<data.count{
        let pro_data = data[i]
        let id = pro_data.id
        var title = pro_data.title
        var dates = pro_data.dates
        var prices = pro_data.prices
        var availables = pro_data.availables
        var market_p = pro_data.market_p
        let results = load(id: id)
        if results["id"] as! String != "Error"{
            dates.append(results["date"] as! Date)
            prices.append(results["price"] as! Int)
            availables.append(results["available"] as! Bool)
            market_p.append(results["market_p"] as! Bool)
            title = results["title"] as! String
            newdata.append(Product(id: id, title: title, dates: dates, prices: prices, availables: availables, market_p: market_p))
        }else{
            print("Error: Refresh")
            return;
        }
    }
    data = newdata
    save()
}


func load(id:String) -> [String:Any]{
    let date = Date()
    if id != "" {
        let urlstr = "https://www.amazon.co.jp/dp/\(id)"
        //let urlstr = "https://www.google.com/"
        let url = URL(string: urlstr)
        var sourceHTML = ""
        do{
            sourceHTML = try String(contentsOf: url!)
        }catch{
            return ["id":"Error","title":"Error","price":0,"available":false, "market_p": false, "date": date];
        }
        let jiDoc = Ji(htmlString: sourceHTML)
        let page_title = jiDoc?.xPath("//title")?.first?.content!
        if !page_title!.contains("ページが見つかりません"){
            let title = jiDoc?.xPath("//span[@id='productTitle']")?.first?.content!
            let product_title = title?.trimmingCharacters(in: .whitespacesAndNewlines)
            let img_src = jiDoc?.xPath("//div[@id='imgTagWrapperId']/img")?.first!.attributes["src"]
            var data:Data
            if (img_src?.prefix(10).contains("data:"))!{
                let data_str = img_src!.replace("data:image/jpeg;base64,", "")
                let options = NSData.Base64DecodingOptions.ignoreUnknownCharacters
                data = Data(base64Encoded: data_str, options: options)!
            }else if (img_src?.prefix(10).contains("http"))!{
                do{
                    data = try Data(contentsOf: URL(string: img_src!)!)
                }catch{
                    print("Error: Image Download \(id)")
                    data = Data()
                }
            }else{
                data = Data()
            }
            let fileURL = getDocumentsURL().appendingPathComponent("\(id).jpg")
            print(fileURL!.path)
            print(data)
            do{
                try data.write(to: fileURL!)
            }catch{
                print("Error: Save Image")
            }
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
                let price_label3 = price_label2.replace("¥", "").replace(",", "").replace("￥","").replace(" ","")
                price = Int(price_label3)!
            }else{
                //出品者から購入
                let price_label =
                    jiDoc?.xPath("//div[@id='unqualifiedBuyBox']/div[@class='a-box-inner']//span[@class='a-color-price']")?.first?.content
                
                ///div[@contains(@class,'a-text-center')]/span[@class='a-color-price']
                let price_label2 = price_label?.trimmingCharacters(in: .whitespacesAndNewlines) as! String
                let price_label3 = price_label2.replace("¥", "").replace(",", "").replace("￥","").replace(" ","")
                price = Int(price_label3)!
            }
            //return product_title!
            return ["id":id,"title":product_title!,"price":price,"available":!available, "market_p":available2, "date": date]
            //return "Hello"
        }else{
            return ["id":"None","title":"Error","price":0,"available":false,"market_p":false, "date": date]
        }
    }else{
        return ["id":"None","title":"Error","price":0,"available":false, "market_p": false, "date": date]
    }
}

/*class Data: ObservableObject {
    /*let product_id = productdata["id"]
    let product_title = productdata["title"]
    let product_price = productdata["price"]
    let product_available = productdata["available"]*/
    var product_id = "B07G8C9CPB"
    var product_data = productdata
}*/
