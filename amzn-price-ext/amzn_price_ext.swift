//
//  amzn_price_ext.swift
//  amzn-price-ext
//
//  Created by takumi saito on 2020/06/23.
//  Copyright © 2020 takpika. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    typealias Intent = SelectProductIntent
    
    func placeholder(in context: Context) -> ProductEntry {
        ProductEntry(date: Date(), id: "null", name: "None", price: -1, available: false, market: false, updatedate: Date())
    }
    
    func getSnapshot(for configuration: SelectProductIntent, in context: Context, completion: @escaping (ProductEntry) -> ()) {
        print("getSnapshot")
        reload()
        let entry = ProductEntry(
            date: Date(),
            id: data[0].id,
            name: data[0].title,
            price: data[0].prices.last!,
            available: data[0].availables.last!,
            market: data[0].market_p.last!,
            updatedate: data[0].dates.last!
        )
        completion(entry)
    }
    
    func getTimeline(for configuration: SelectProductIntent, in context: Context, completion: @escaping (Timeline<ProductEntry>) -> ()) {
        var entries: [ProductEntry] = []
        reload()
        var entry : ProductEntry
        if data.count > 0 {
            entry = ProductEntry(date: Date(), id: data[0].id, name: data[0].title, price: data[0].prices.last!, available: data[0].availables.last!, market: data[0].market_p.last!, updatedate: data[0].dates.last!)
        }else{
            entry = ProductEntry(date: Date(), id: "No Product", name: "None", price: 0, available: false, market: false, updatedate: Date())
        }
        print("GETTIMELINE")
        entries.append(entry)
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ProductEntry: TimelineEntry {
    let date : Date
    let id : String
    let name : String
    let price : Int
    let available : Bool
    let market : Bool
    let updatedate : Date
}

public class SelectProductIntent: INIntent {
    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Int
    @NSManaged public var available: Bool
    @NSManaged public var market: Bool
    @NSManaged public var updatedate: Date?
}

struct PlaceholderView : View {
    var body: some View {
        VStack{
            Text("takpika")
        }
    }
}

struct amzn_price_extEntrySmallView : View {
    var entry: Provider.Entry
    var image: UIImage
    var available = true
    
    init(entry: Provider.Entry){
        self.entry = entry
        do{
            self.image = try UIImage(data: Data(contentsOf: getDocumentsURL().appendingPathComponent("\(entry.id).jpg")!))!
        }catch{
            self.image = UIImage(systemName: "xmark.octagon")!
            available = false
            print("Error")
        }
    }
    var body: some View {
        VStack{
            if available{
                ZStack{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    VStack{
                        Spacer()
                        HStack{
                            Text(verbatim: entry.name)
                                .font(.caption)
                                .lineLimit(1)
                                .background(Color(dynamicColor))
                            Spacer()
                        }
                        HStack{
                            if entry.available && !entry.market{
                                Text("¥\(entry.price)")
                                    .font(.footnote)
                                    .background(Color(dynamicColor))
                            }else if entry.available && entry.market{
                                Text("出品者から購入可")
                                    .font(.footnote)
                                    .foregroundColor(.green)
                                    .background(Color(dynamicColor))
                            }else{
                                Text("在庫なし")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .background(Color(dynamicColor))
                            }
                            Spacer()
                        }
                    }
                    .padding(.all)
                }
            }else{
                Text("商品がありません")
                    .font(.caption)
            }
        }
    }
}

struct amzn_price_extEntryMediumView : View {
    let f1 = time_setup(type: 1)
    let f2 = time_setup(type: 2)
    var entry: Provider.Entry
    var image: UIImage
    var available: Bool = true
    
    init(entry: Provider.Entry){
        self.entry = entry
        do{
            self.image = try UIImage(data: Data(contentsOf: getDocumentsURL().appendingPathComponent("\(entry.id).jpg")!))!
        }catch{
            self.image = UIImage(systemName: "xmark.octagon")!
            available = false
            print("Error")
        }
    }
    var body: some View {
        VStack{
            if available{
                VStack{
                    HStack{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        VStack{
                            HStack{
                                Text(verbatim: entry.name)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(.bottom)
                            HStack{
                                if entry.available && !entry.market{
                                    Text("¥\(entry.price)")
                                }else if entry.available && entry.market{
                                    Text("出品者から購入可")
                                        .foregroundColor(.green)
                                }else{
                                    Text("在庫なし")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.leading)
                    }
                    HStack{
                        Spacer()
                        if self.f1.string(from: Date()) == self.f1.string(from: entry.updatedate){
                            Text(self.f2.string(from: entry.updatedate))
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                        }else{
                            Text(self.f1.string(from: entry.updatedate))
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        }
                    }
                }
                .padding(.all)
            }else{
                Text("商品が登録されていません")
            }
        }
    }
}

struct amzn_price_smallext: Widget {
    private let kind: String = "jp.takpika.amzn_price.ext.small"

    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: Provider.Intent.self,
            provider: Provider()
        ) { entry in
            amzn_price_extEntrySmallView(entry: entry)
        }
        .configurationDisplayName("小")
        .description("アプリに登録した一番上の商品を表示します。")
        .supportedFamilies([.systemSmall])
    }
}

struct amzn_price_mediumext: Widget {
    private let kind: String = "jp.takpika.amzn_price.ext.medium"

    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: Provider.Intent.self,
            provider: Provider()
        ) { entry in
            amzn_price_extEntryMediumView(entry: entry)
        }
        .configurationDisplayName("中")
        .description("アプリに登録した一番上の商品を表示します。")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct amzn_price_bundle: WidgetBundle {
    var body: some Widget {
        amzn_price_smallext()
        amzn_price_mediumext()
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
