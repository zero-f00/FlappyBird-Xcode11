//
//  ViewController.swift
//  FlappyBird
//
//  Created by Yuto Masamura on 2020/03/15.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // SKViewに型を変換する
        let skView = self.view as! SKView
        
        // FPSを表示する
        skView.showsFPS = true
        
        // ノードの数を表示する
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        // ビューにシーンを表示する
        skView.presentScene(scene)
    }
    
    // ステータスバーを消すメソッド
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

