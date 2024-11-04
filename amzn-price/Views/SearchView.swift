//
//  SearchView.swift
//  amzn-price
//
//  Created by takumi saito on 2020/04/15.
//  Copyright © 2020 takpika. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    @State var search = ""
    @State var message = ""
    @State var showingAlert = false
    @Binding var showModal: Bool
    var body: some View {
        NavigationView{
            VStack{
                TextField("URLを入力", text: $search)
                    .padding(.horizontal)
                HStack{
                    Spacer()
                    Button(action: {
                        if var myString = UIPasteboard.general.string {
                            if let range = myString.range(of: "http") {
                                myString = myString.replace(String(myString[myString.startIndex..<range.lowerBound]), "")
                            }
                            self.search = myString
                        }
                    }) {
                        Image(systemName:"doc.on.clipboard")
                    }
                }
                .padding(.all)
                Spacer()
            }.navigationBarItems(leading:
                Button(action: {
                    self.showModal.toggle()
                }) {
                Text("キャンセル")
                }
                , trailing:
                Button(action: {
                    let count = self.search.count
                    var id = ""
                    if count < 7{
                        self.message = "無効なURLです。"
                    }else{
                        if self.search.prefix(8).contains("http://") || self.search.prefix(8).contains("https://"){
                            if self.search.prefix(24).contains("www.amazon.co.jp"){
                                let locate1 = self.search.range(of: "/dp/")
                                let locate2 = self.search.range(of: "/gp/product/")
                                if locate1 != nil || locate2 != nil{
                                    if locate1 != nil{
                                        id = String(self.search[self.search.index(locate1!.lowerBound, offsetBy: 4)..<self.search.index(locate1!.lowerBound, offsetBy: 14)])
                                    }else{
                                        id = String(self.search[self.search.index(locate2!.lowerBound, offsetBy: 12)..<self.search.index(locate2!.lowerBound, offsetBy: 22)])
                                    }
                                    self.message = add(id: id)
                                }else{
                                    self.message = "商品ページのURLを入力してください。"
                                }
                            }else{
                                self.message = "Amazon.co.jp以外は使用できません。"
                            }
                        }else{
                            self.message = "無効なURLです。"
                        }
                    }
                    self.showingAlert = true
                    self.search = ""
                }) {
                    Text("追加")
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text(self.message))
                    
                }
            )
            .navigationBarTitle("商品を追加")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(showModal: .constant(true))
    }
}
