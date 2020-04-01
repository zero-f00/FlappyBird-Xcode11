//
//  ViewController.swift
//  FlappyBird
//
//  Created by Yuto Masamura on 2020/03/15.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer:AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 再生するaudioファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "backgroundSound", ofType: "mp3")!
        // 再生するURLを作成
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        // audioを再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        // AVAudioPlayerのデリゲートプロトコル
        audioPlayer.delegate = self
        
        // audioPlayerの再生前に呼び出しておいた方いいもの（ラグを最小化できるらしい）
        audioPlayer.prepareToPlay()
        // 再生
        audioPlayer.play()
        
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

