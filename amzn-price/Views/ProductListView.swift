//
//  ProductListView.swift
//  amzn-price
//
//  Created by takumi saito on 2020/04/14.
//  Copyright © 2020 takpika. All rights reserved.
//

import SwiftUI
import SwiftUIRefresh

struct ProductListView: View {
    @State var product_datas = setup()
    @State var isPresented = false
    @State var isRefreshing = false
    let notice = notice_setup()
    var body: some View {
        ZStack{
            ListView1(product_datas: $product_datas, isRefreshing: $isRefreshing)
            PlusOverView(isPresented: $isPresented)
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
