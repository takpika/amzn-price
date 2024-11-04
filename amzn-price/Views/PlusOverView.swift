//
//  PlusOverView.swift
//  amzn-price
//
//  Created by takumi saito on 2020/06/29.
//  Copyright © 2020 takpika. All rights reserved.
//

import SwiftUI

struct PlusOverView: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack{
            Spacer()
            VStack{
                Spacer()
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Text("＋")
                        .font(.largeTitle)
                        .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(Color.green)
                        .foregroundColor(Color(textColor))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $isPresented) {
                    SearchView(showModal: $isPresented)
                }
            }
        }
        .padding(.all)
    }
}
