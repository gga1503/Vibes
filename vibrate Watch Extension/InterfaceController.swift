//
//  InterfaceController.swift
//  vibrate Watch Extension
//
//  Created by Christopher Putra Setiawan on 23/08/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import ClockKit
import HealthKit
import SpriteKit

class InterfaceController: WKInterfaceController,WCSessionDelegate{
    
    
    var session: WCSession = WCSession.default
    var beats:[Double] = []
    @IBOutlet weak var scene: WKInterfaceSKScene!
    
    @IBOutlet weak var tap: WKTapGestureRecognizer!
    
    
    @IBAction func tapped(_ sender: Any) {
    }
    
    @IBAction func nextsong() {
        session.sendMessage(["Message":"next"], replyHandler: nil, errorHandler: nil)
    }
    
    @IBAction func prevsong() {
        session.sendMessage(["Message":"prev"], replyHandler: nil, errorHandler: nil)
    }
    
    var spectrum = SKSpriteNode()
    var spectrumbeat: [SKTexture] = []
    var playbuttonbool: Bool = false
    @IBOutlet weak var playbutton: WKInterfaceButton!
    @IBAction func play() {
        var message: String?
        if playbuttonbool {
            message = "pause"
            playbutton.setBackgroundImageNamed("TplayButton.png")
        }
        else{
            message = "play"
            playbutton.setBackgroundImageNamed("TpauseButton.png")
        }
        playbuttonbool = !playbuttonbool
        session.sendMessage(["Message" : message as Any], replyHandler: nil, errorHandler: nil)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("aa")
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["beat"] != nil {
            beats = message["beat"] as! [Double]
        }
        else if message["Status"] != nil {
            if message["Status"] as! String == "play"{
                playbuttonbool = true
                playbutton.setBackgroundImageNamed("TpauseButton.png")
            }
            else{
                playbuttonbool = false
                playbutton.setBackgroundImageNamed("TplayButton.png")
            }
        }
        else{
            self.spectrum.run(
                SKAction.animate(with: self.spectrumbeat,
                                 timePerFrame: 0.01,
                                 resize: false,
                                 restore: true),
                withKey:"spectrumbeat")
            if message["Message"] as! String == "0" {
                WKInterfaceDevice.current().play(.start)
            }
            else if message["Message"] as! String == "1" {
                WKInterfaceDevice.current().play(.failure)
            }
            else if message["Message"] as! String == "2" {
                WKInterfaceDevice.current().play(.directionDown)
            }
            else {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
    func checkStatus(){
        session.sendMessage(["Request":"request"], replyHandler: nil, errorHandler: nil)
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        checkStatus()
        
    }
    @objc func start(){
        WKInterfaceDevice.current().play(.start)
    }
    override func willActivate() {
        super.willActivate()
        session.delegate = self
        session.activate()
        checkStatus()
        let spectrumsize = 120
        scene.scene?.backgroundColor = .clear
        let skscene = SKScene(size: CGSize(width: spectrumsize, height: spectrumsize))
        print(contentFrame.width, contentFrame.height)
        skscene.backgroundColor = .clear
        let spectrumatlas = SKTextureAtlas(named: "spectrum7")
        
        let numImages = spectrumatlas.textureNames.count
        for i in 1...numImages {
            let spectrumname = "spectrum\(i)"
            spectrumbeat.append(spectrumatlas.textureNamed(spectrumname))
        }
        let firstFrameTexture = spectrumbeat[0]
        spectrum = SKSpriteNode(texture: firstFrameTexture)
        spectrum.run(
            SKAction.animate(with: spectrumbeat,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true),
                 withKey:"spectrumbeat")
        spectrum.position = CGPoint(x: spectrumsize/2, y: spectrumsize/2)
        spectrum.scale(to: CGSize(width: spectrumsize, height: spectrumsize))
        skscene.addChild(spectrum)
        scene.presentScene(skscene)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
