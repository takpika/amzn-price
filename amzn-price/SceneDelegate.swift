//
//  SceneDelegate.swift
//  amzn-price
//
//  Created by takumi saito on 2019/10/11.
//  Copyright © 2019 takpika. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller
        let contentView = ProductListView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else{
            print("Error: Code -101") //Error Code -101
            return
        }
        print("HOST: \(url.host!)")
        print("QUERY: \(url.query!)")
        
        guard let components = URLComponents(string: url.absoluteString), let host = components.host, let query = components.query else {
            print("Error: Code -102") //Error Code -102
            return
        }
        
        if host == "add" && query.prefix(3) == "id="{
            print("Import: ID")
            let id = query.replace("id=","")
            message = add(id: id)
            print(message)
        }else if host == "add" && query.prefix(4) == "url="{
            print("Import: URL")
            let search = query.replace("url=","")
            let count = search.count
            var id = ""
            if count < 7{
                message = "無効なURLです。"
                print("Error: Invalid URL -103") //Error Code -103
            }else{
                if search.prefix(8).contains("http://") || search.prefix(8).contains("https://"){
                    if search.prefix(24).contains("www.amazon.co.jp"){
                        let locate1 = search.range(of: "/dp/")
                        let locate2 = search.range(of: "/gp/product/")
                        if locate1 != nil || locate2 != nil{
                            if locate1 != nil{
                                print("Import: URL Type 1")
                                id = String(search[search.index(locate1!.lowerBound, offsetBy: 4)..<search.index(locate1!.lowerBound, offsetBy: 14)])
                            }else{
                                print("Import: URL Type 2")
                                id = String(search[search.index(locate2!.lowerBound, offsetBy: 12)..<search.index(locate2!.lowerBound, offsetBy: 22)])
                            }
                            message = add(id: id)
                            print(message)
                        }else{
                            message = "商品ページではありません。"
                            print("Error: Not Product URL -104") //Error Code -104
                        }
                    }else{
                        message = "Amazon.co.jpではないようです。"
                        print("Error: Not amazon.co.jp -105") //Error Code -105
                    }
                }else{
                    message = "無効なURLです。"
                    print("Error: Invalid URL -106") //Error Code -106
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

