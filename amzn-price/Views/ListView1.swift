//
//  ListView1.swift
//  amzn-price
//
//  Created by takumi saito on 2020/06/29.
//  Copyright © 2020 takpika. All rights reserved.
//

import SwiftUI

struct ListView1: View{
    @Binding var product_datas: [Product]
    @Binding var isRefreshing : Bool
    
    var body: some View {
        NavigationView{
            List{
                ForEach(product_datas){ item in
                    ListView11(item: item)
                }
                .onDelete(perform: delete)
                .onMove(perform: rowReplace)
            }
            .navigationBarItems(trailing: EditButton())
            /*.navigationBarItems(leading: Button(action: {
                self.isPresented.toggle()
            },label:{
                Image(systemName: "plus")
            })
                .sheet(isPresented: $isPresented){
                    SearchView(showModal: self.$isPresented)
                }
                , trailing: EditButton())*/
            .navigationBarTitle("商品一覧")
        }.pullToRefresh(isShowing: $isRefreshing) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                refresh()
                self.product_datas = data
                self.isRefreshing = false
            }
        }
    }
    
    func delete(at offsets: IndexSet){
        do{
            let aray = Array(offsets)
            let fileName = "\(data[aray[0]].id).jpg"
            try FileManager.default.removeItem(at: getDocumentsURL().appendingPathComponent(fileName)!)
        }catch{
            print("Error: Delete Image File")
        }
        data.remove(atOffsets: offsets)
        save()
        product_datas = data
    }
    
    func rowReplace(_ from: IndexSet, _ to: Int){
        data.move(fromOffsets: from, toOffset: to)
        save()
        product_datas = data
    }
}

struct ListView11: View {
    
    var item : Product
    let f1 = time_setup(type: 1)
    let f2 = time_setup(type: 2)
    
    var body: some View {
        NavigationLink(destination: ContentView(number: get_number(id: item.id))){
            HStack{
                VStack(alignment: .leading){
                    Text(item.title)
                        .lineLimit(3)
                    if item.availables.last! && !item.market_p.last!{
                        Text("¥\(item.prices.last!)")
                    }else if !item.availables.last!{
                        Text("在庫なし")
                            .foregroundColor(Color.red)
                    }else{
                        Text("出品者から購入可能")
                            .foregroundColor(Color.green)
                    }
                }
                Spacer()
                VStack(alignment: .trailing){
                    Spacer()
                    if self.f1.string(from: Date()) == self.f1.string(from: item.dates.last!){
                        Text(self.f2.string(from: item.dates.last!))
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                    }else{
                        Text(self.f1.string(from: item.dates.last!))
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    }
                }
            }
        }
    }
}

struct BlockView_1 : View {
    
    var item : Product
    let f1 = time_setup(type: 1)
    let f2 = time_setup(type: 2)
    
    var body: some View{
        NavigationLink(destination: ContentView(number: get_number(id: item.id))){
            VStack{
                Spacer()
                HStack{
                    Text(item.title)
                        .lineLimit(2)
                    Spacer()
                }
                HStack{
                    if item.availables.last! && !item.market_p.last!{
                        Text("¥\(item.prices.last!)")
                    }else if !item.availables.last!{
                        Text("在庫なし")
                            .foregroundColor(.red)
                    }else{
                        Text("出品者から購入可能")
                            .foregroundColor(.green)
                    }
                    Spacer()
                    if self.f1.string(from: Date()) == self.f1.string(from: item.dates.last!){
                        Text(self.f2.string(from: item.dates.last!))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }else{
                        Text(self.f1.string(from: item.dates.last!))
                            .font(.footnote)

                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct ListView1_Previews: PreviewProvider{
    static var previews: some View{
        Group{
            BlockView_1(item: Product(id: "1", title: "TEST", dates: [Date()], prices: [-1], availables: [false], market_p: [false]))
        }
    }
}
