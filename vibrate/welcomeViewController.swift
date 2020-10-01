//
//  welcomeViewController.swift
//  vibrate
//
//  Created by christopher putra setiawan on 31/01/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import UIKit
import SpriteKit
class welcomeViewController: UIViewController, SKViewDelegate{
    let emptyString = String() // Do nothing
    
    @IBOutlet weak var logo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.cornerRadius = 25
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
        
        
        let colorTop = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0).cgColor
        let colorBottom = UIColor(red: 0, green: 1, blue: 1, alpha: 0.3).cgColor
        let gl = CAGradientLayer()
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.5]
        gl.position = CGPoint(x: view.center.x, y: view.center.y + 1000)
        gl.frame = view.frame
        view.layer.insertSublayer(gl, at: 0)
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
        
    }
    
    @objc func timeToMoveOn() {
        UIView.animate(withDuration: 0.5, animations: {
            
            self.logo.alpha = 0
            self.logo.transform = CGAffineTransform(translationX: 0, y: -100)
        }) { (complete) in
            
            self.performSegue(withIdentifier: "playscreen", sender: self)
        }
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
