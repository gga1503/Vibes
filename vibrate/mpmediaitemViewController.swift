//
//  mpmediaitemViewController.swift
//  vibrate
//
//  Created by Christopher Putra Setiawan on 13/08/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class mpmediaitemViewController: UIViewController {
    let particleEmitter = CAEmitterLayer()
    
    
    @IBOutlet weak var logo: UIImageView!
    @IBAction func start(_ sender: Any) {
        particleEmitter.lifetime = 1
    }
    
    @IBAction func STOP(_ sender: Any) {
        particleEmitter.lifetime = 0
    }

    func createParticles() {
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: view.frame.height + 500)
        particleEmitter.emitterShape = .rectangle
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: view.frame.height)
        let cell = makeEmitterCell()
        particleEmitter.lifetime = 1
        particleEmitter.emitterCells = [cell]
        view.layer.insertSublayer(particleEmitter, at: 0)
    }
    
    func makeEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 1
        cell.lifetime = 20
        cell.lifetimeRange = 0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi * 3 / 2
        cell.emissionRange = CGFloat.pi / 10
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.25
        cell.scaleSpeed = -0.05
        cell.alphaRange = 1
        cell.alphaSpeed = -0.05
        cell.contents = UIImage(named: "sliderthumb")?.alpha(0.2).cgImage
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //createParticles()
        view.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
        let colorTop = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0).cgColor
        let colorBottom = UIColor(red: 0, green: 1, blue: 1, alpha: 0.3).cgColor
        
        let gl = CAGradientLayer()
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.5]
        gl.position = CGPoint(x: view.center.x, y: view.center.y + 1000)
        gl.frame = view.frame
        view.layer.insertSublayer(gl, at: 0)
        
        let blur = UIBlurEffect(style: .dark)
        let effect = UIVisualEffectView(effect: blur)
        effect.alpha = 1
        effect.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        //view.addSubview(effect)
        let logoup = logo
        logo = nil
        view.addSubview(logoup!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
