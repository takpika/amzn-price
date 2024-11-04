//
//  Data_base.swift
//  amzn-price
//
//  Created by takumi saito on 2020/06/25.
//  Copyright © 2020 takpika. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import WidgetKit

var data: [Product] = []

struct Product: Identifiable, Codable{
    let id : String
    var title : String
    var dates : [Date]
    var prices : [Int]
    var availables : [Bool]
    var market_p : [Bool]
}

let groupID = "group.takpika.ampr"

func reload(){
    let decoder = JSONDecoder()
    let FileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent("UserData.json")
    print(FileURL?.path)
    do{
        data = try decoder.decode([Product].self, from: Data(contentsOf: FileURL!))
        print("Complete: load")
    }catch{
        print("Error: load")
        data = []
    }
    if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

func save(){
    let documentsURL = (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent("UserData.json"))
    let encoder = JSONEncoder()
    do{
        let jsdata = try encoder.encode(data)
        try jsdata.write(to: documentsURL!)
        print("Complete: Save")
    }catch{
        print("Error: Save")
    }
    if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

func getDocumentsURL() -> NSURL {
    let documentsURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)! as NSURL
    return documentsURL
}

let dynamicColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
    switch traitCollection.userInterfaceStyle{
    case .unspecified, .light:
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
    default:
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
    }
}

let textColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
    switch traitCollection.userInterfaceStyle{
    case .unspecified, .light:
        return .white
    default:
        return .black
    }
}

func time_setup(type: Int) -> DateFormatter{
    let form = DateFormatter()
    if type == 1{
        form.dateStyle = .medium
        form.timeStyle = .none
    }else if type == 2{
        form.dateStyle = .none
        form.timeStyle = .short
    }else if type == 3{
        form.dateStyle = .medium
        form.timeStyle = .short
    }
    form.locale = Locale(identifier: "ja_JP")
    return form
}
