//
//  GameScene.swift
//  FlappyBird
//
//  Created by Yuto Masamura on 2020/03/15.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // それぞれのシーン上の画面を構成する要素をノード (SKNodeクラス) と呼ぶ
    // SKNodeクラスを継承したクラスが実際のUI部品
    // 画像を描画するSKSpriteNodeクラス、文字を描画するSKLabelNodeクラス、図形を描画するSKShapeNodeクラス
    // 壁や背景、アイテムなどの文字でもない描画するものでもない、ただの物体にはSKNodeクラスを使う
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var bugNode:SKNode!
    
    // 衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0 // 0...00001
    let groundCategory: UInt32 = 1 << 1 // 0...00010
    let wallCategory: UInt32 = 1 << 2 // 0...00100
    let scoreCategory: UInt32 = 1 << 3 // 0...01000
    
    // スコア用
    var score = 0
    
    // 画面上部にスコアとベストスコアを表示するようにする
    // 文字の表示にはSKLabelNodeクラス
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    // ベストスコアをUserDefaultsで保存するために、userDefaultsクラスのUserDefaults.standardプロパティでUserDefaultsを取得します。
    let userDefaults:UserDefaults = UserDefaults.standard
    
    // SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view:SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        // 虫のノード
        bugNode = SKNode()
        addChild(bugNode)
        
        
        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupBug()
        
        setupScoreLabel()
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    // 画面をタップした時に呼ばれるメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向に力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        } else if bird.speed == 0 {
            restart()
        }
        
    }
    
    // SKPhysicsContactDelegatwのメソッド 衝突した時に呼ばれるメソッド
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときはなにもしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) ==  scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            // ベストスコア更新化確認する
            // UserDefaultsはキーと値を指定して保存する
            // 取り出すときはキーを指定する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                // ベストスコアの確認のために、integer(forKey:)メソッドでキーを指定して取得する（ベストスコアが保存されていなければ0が返ってくる）
                // 現在のスコアと比較し、ベストスコアが更新されていればset(_:forKey:)メソッドで値とキーを指定して
                userDefaults.set(bestScore, forKey: "BEST")
                // 保存する
                userDefaults.synchronize()
            }
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            // 回転する動きが終わったら、completion（完了で）鳥の速度を0にする
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        // スコアを0に戻す
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        
        // 鳥の位置を初期位置に設定
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        // 一旦壁を全て取り除く
        wallNode.removeAllChildren()
        
        // スクロール、鳥のspeedを1に戻す
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        // collisionBitMaskプロパティは当たった時に跳ね返る動作をする相手を設定
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        // アニメーションを設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像を一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        
        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            // 地面のため四角形で物理体を設定
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            // スプライトに物理演算を設定する
            // falseを設定することで重力の影響を受けず、衝突時に動かないようにする
            sprite.physicsBody?.isDynamic = false
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func  setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像を一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        // 元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        // スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            // スプライトにアクションを設定する
            sprite.run(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
            
        }
    }

    
    func setupWall() {
        // 壁の画像を読み込む
        let walltexture = SKTexture(imageNamed: "wall")
        walltexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + walltexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 3
        
        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        // 下の壁のY軸上限位置（中央位置から下方向の最大振れ幅で下の画面を表示する位置）
        // 地面のサイズを取得する
        let groundSize = SKTexture(imageNamed: "ground").size()
        
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - walltexture.size().height / 2 - random_y_range / 2 - random_y_range / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + walltexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥
            
            // 0~random_y_rengeまでランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            // 下限の壁を作成する
            let under = SKSpriteNode(texture: walltexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: walltexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            // 衝突時に動かないよう設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: walltexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + walltexture.size().height + slit_length)
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: walltexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            // 衝突時に動かないよう設定する
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            // スコアアップ用のノード --- ここから ---
            let scoreNode = SKNode()
            // どこの場所に設置するのか、場所についての設定　《（幅が上側の壁の幅と鳥の幅の半分）（高さがフレームの半分）の場所》
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            
            // 見えない物体を設置する　《長方形の物体で（幅が上側の壁の幅）（高さがフレームの高さ）》
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf:  CGSize(width: upper.size.width, height: self.frame.size.height))
            
            // 当たり判定（falseなので物体にぶつかる）
            scoreNode.physicsBody?.isDynamic = false
            
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            //--- ここまで ---
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 壁を作成->時間待ち->壁の作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBug() {
        // 虫の画像を読み込む
        let bugTexture = SKTexture(imageNamed: "bug")
        bugTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + bugTexture.size().width)
        
        // 画面外まで移動するアクションを作成
        let moveBug = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自身を取り除くアクションを作成
        let removeBug = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let bugAnimation = SKAction.sequence([moveBug, removeBug])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 虫が現れる位置（上下の振れ幅）を鳥のサイズの３倍とする
        let random_y_range = birdSize.height * 3
        
        // 虫のY軸下限位置（中央位置から下方向の最大振れ幅で下の方に現れる虫を表示する位置）を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.height - groundSize.height) / 2
        
        // 虫を生成するアクションを作成
        let createBugAnimation = SKAction.run({
            
            print("虫のアクションが作成されました。")
            
            // 虫関連のノードを乗せるノードを作成
            let bug = SKNode()
            bug.position = CGPoint(x: self.frame.size.width + bugTexture.size().width / 2, y: 0)
            bug.zPosition = -50 // 雲より手前地面より奥
            
            // 0~random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_bug_y = center_y + random_y
            
            // 下に表示される虫を作成
            let underBug = SKSpriteNode(texture: bugTexture)
            underBug.position = CGPoint(x: 0, y: under_bug_y)
            bug.addChild(underBug)
            
            bug.run(bugAnimation)
        })
        let waitAnimation = SKAction.wait(forDuration: 1)
        
        // 虫を作成->時間待ち->虫を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createBugAnimation, waitAnimation]))
        
        bugNode.run(repeatForeverAnimation)
    }
}
