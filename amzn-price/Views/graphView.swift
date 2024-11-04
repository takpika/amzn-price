//
//  graphView.swift
//  amzn-price
//
//  Created by takumi saito on 2020/04/14.
//  Copyright © 2020 takpika. All rights reserved.
//

import SwiftUI

struct graphView: UIViewRepresentable {
    let id:String
    init(id: String){
        self.id = id
    }
    func makeUIView(context: Context) -> UIImageView {
        UIImageView(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        let url = getDocumentsURL().appendingPathComponent("\(id).jpg")
        uiView.image = UIImage(contentsOfFile: url!.path)
        uiView.contentMode = UIView.ContentMode.scaleAspectFit
    }

    struct graphView_Previews: PreviewProvider {
        static var previews: some View {
            graphView(id: "")
        }
    }
}
