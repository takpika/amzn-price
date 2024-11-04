//
//  ContentView.swift
//  amzn-price
//
//  Created by takumi saito on 2019/10/11.
//  Copyright © 2019 takpika. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct ContentView : View {
    let product_data: Product
    let price_data: ChartData
    let number: Int
    @State var label = "Hello World!!!!"
    let f = time_setup(type: 3)
    let image_url :String
    
    init(number: Int){
        self.number = number
        self.product_data = data[number]
        self.price_data = make_data(number: number)
        self.image_url =  (getDocumentsURL().appendingPathComponent("\(product_data.id).jpg"))!.path
    }
    var body: some View {
        ScrollView{
            VStack{
                graphView(id: product_data.id)
                Text(product_data.title)
                    .font(.title)
                    .padding(.horizontal)
                HStack{
                    if product_data.availables.last! && product_data.market_p.last!{
                        Text("出品者から購入可能")
                            .foregroundColor(Color.green)
                    }
                    Spacer()
                    if product_data.availables.last!{
                        Text("¥\(product_data.prices.last!)")
                    }else{
                        Text("在庫なし")
                            .foregroundColor(Color.red)
                    }
                }
                .padding(.all)
                HStack{
                    VStack(alignment: .leading){
                        Button("Amazonで確認"){
                            let url = URL(string: "https://www.amazon.co.jp/dp/\(self.product_data.id)")
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!)
                            }
                        }
                        .padding(.bottom)
                        Button("サクラチェッカーで確認"){
                            let url = URL(string: "https://sakura-checker.jp/search/\(self.product_data.id)")
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!)
                            }
                        }
                        Spacer()
                        Text(f.string(from: product_data.dates.last!))
                    }
                    Spacer()
                    BarChartView(data: price_data, title: "")
                }
                .padding([.leading, .bottom, .trailing])
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(number: .zero)
    }
}
#endif
