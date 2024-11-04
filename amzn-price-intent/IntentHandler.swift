//
//  IntentHandler.swift
//  amzn-price-intent
//
//  Created by takumi saito on 2020/12/01.
//  Copyright © 2020 takpika. All rights reserved.
//

import Intents

class IntentHandler: INExtension, SelectProductIntentHandler {
    func provideProductOptionsCollection(for intent: SelectProductIntent, searchTerm: String?, withcompletion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
        reload()
        let products : [Products] = data.map { product_before in
            let product_after = Products(identifier: product_before.id,
                                         display: product_before.title
            )
            product_after.name = product_before.title
            product_after.price = product_before.prices.last!
            product_after.available = product_before.availables.last!
            product_after.market = product_before.market_p.last!
            product_after.updatedate = product_before.dates.last!
            return product_after
        }
        let allProductIdentifiers = INObjectCollection(items: products)
        completion(allProductIdentifiers, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
}
