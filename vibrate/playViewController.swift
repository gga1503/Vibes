//
//  playViewController.swift
//  vibrate
//
//  Created by Vincent Hartanto on 31/01/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import UIKit
import AVFoundation
import aubio
import AudioToolbox
import WatchConnectivity
import HealthKit

class playViewController: UIViewController , WCSessionDelegate{
    
    @IBOutlet weak var currtime: UILabel!
    @IBOutlet weak var lefttime: UILabel!
    @IBOutlet weak var slidecontrol: UISlider!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songartist: UILabel!
    @IBOutlet var settingsview: UIView!
    @IBOutlet var watchview: UIView!
    
    lazy var imageView = UIImageView(image: self.gif)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ViewController{
            dest.delegate = self
        }
    }
    
    var session:WCSession = WCSession.default
    var albums: [AlbumInfo] = []
    var player:AVAudioPlayer?
    var timer = Timer()
    var index = 0
    var last:Double = 0
    var beats:[Double] = []
    var songlist:[Song] = []
    var songshuffled:[Song] = []
    var nowIndex = 0
    var nowshuffledIndex = 0
    var duration = 0
    var bpm:Double?
    var generator = UIImpactFeedbackGenerator(style: .heavy)
    var lastvolume: Float = 0
    var songimg: UIImageView = UIImageView()
    let gl = CAGradientLayer()
    let colorsAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
    let gif = UIImage.gifImageWithName("muter")
    var settingsview2: UIView?
    var watchview2: UIView?
    let particleEmitter2 = CAEmitterLayer()
    let particleEmitter = CAEmitterLayer()
    var imagespectrum = UIImageView?.self
    var aboutcontainer: UIView = UIView()
    var watchcontainer: UIView = UIView()
    var watchlabel: UILabel = UILabel()
    var watchdesc: UILabel = UILabel()
    let healthStore = HKHealthStore()
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["Request"] != nil{
            var status = "pause"
            if player != nil {
                if player!.isPlaying{
                    status = "play"
                }
            }
            session.sendMessage(["Status": status], replyHandler: nil, errorHandler: nil)
        }
        else{
        DispatchQueue.main.async {
            if message["Message"] as! String == "next"{
                self.playNext()
            }
            else if message["Message"] as! String == "prev" {
                self.playPrev()
            }
            else if message["Message"] as! String == "play" {
                self.play()
            }
            else{
                self.pause()
            }
        }
        }
    }
    func playNext() {
        if !songlist.isEmpty {
        if shuffleButtonOutlet.currentBackgroundImage == UIImage(named: "Tshuffle") {
            if nowshuffledIndex + 1 < songshuffled.count {
                nowshuffledIndex = nowshuffledIndex + 1
            }
            else {
                nowshuffledIndex = 0
            }
            playMusic(song: songshuffled[nowshuffledIndex])
        }
        else {
            if nowIndex + 1 < songlist.count {
                nowIndex = nowIndex + 1
            }
            else {
                nowIndex = 0
            }
            playMusic(song: songlist[nowIndex])
        }
        }
    }
    func playPrev() {
        if !songlist.isEmpty {
        if shuffleButtonOutlet.currentBackgroundImage == UIImage(named: "Tshuffle") {
            if nowshuffledIndex - 1 >= 0 {
                nowshuffledIndex = nowshuffledIndex - 1
            }
            else {
                nowshuffledIndex = songshuffled.count - 1
            }
            playMusic(song: songshuffled[nowshuffledIndex])
        }
        else {
            if nowIndex - 1 >= 0 {
                nowIndex = nowIndex - 1
            }
            else {
                nowIndex = songlist.count - 1
            }
            playMusic(song: songlist[nowIndex])
        }
        }
    }
    func createParticles2() {
        particleEmitter2.emitterPosition = CGPoint(x: view.center.x, y: view.frame.height + 250)
        particleEmitter2.emitterShape = .rectangle
        particleEmitter2.emitterSize = CGSize(width: view.frame.width, height: 50)
        let cell = makeEmitterCell2()
        particleEmitter2.lifetime = 1
        particleEmitter2.emitterCells = [cell]
        view.layer.addSublayer(particleEmitter2)
    }
    
    func makeEmitterCell2() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 30
        cell.lifetime = 10
        cell.lifetimeRange = 0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi * 3 / 2
        cell.emissionRange = CGFloat.pi / 10
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.25
        cell.scaleSpeed = -0.1
        cell.alphaRange = 1
        cell.alphaSpeed = -0.1
        cell.contents = UIImage(named: "thumb")?.alpha(0.1).cgImage
        return cell
    }
    func createParticles() {
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: view.center.y - 80)
        particleEmitter.emitterShape = .circle
        particleEmitter.emitterSize = CGSize(width: 20, height: 20)
        let cell = makeEmitterCell()
        particleEmitter.lifetime = 0
        particleEmitter.velocity = 2
        particleEmitter.emitterCells = [cell]
        view.layer.insertSublayer(particleEmitter, at: 0)
    }
    
    func makeEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 1000
        cell.lifetime = 0.7
        cell.lifetimeRange = 0
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi / 2
        cell.emissionRange = CGFloat.pi * 2
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.1
        cell.alphaRange = 1
        cell.alphaSpeed = -2.0
        cell.contents = UIImage(named: "thumb")?.alpha(0.5).cgImage
        return cell
    }
    @objc func stopParticle(){
        particleEmitter.lifetime = 0
    }
    func fireParticle(){
        particleEmitter.lifetime = 1
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(stopParticle), userInfo: nil, repeats: false)
    }
    @objc func startAnimate(){
        colorsAnimation.fromValue = gl.colors
        colorsAnimation.toValue = [ UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0).cgColor, UIColor(red: 0, green: 1, blue: 1, alpha: 0.6).cgColor]
        colorsAnimation.duration = Double(bpm!)
        colorsAnimation.repeatCount = Float.infinity
        colorsAnimation.autoreverses = true
        colorsAnimation.fillMode = .forwards
        colorsAnimation.isRemovedOnCompletion = false
        gl.add(colorsAnimation, forKey: "colors")
    }
    @objc func impact(){
            self.generator = UIImpactFeedbackGenerator(style: .heavy)
            self.generator.impactOccurred()
        self.fireParticle()
    }
    @objc func impact2(){
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.warning)
        self.fireParticle()
    }
    @objc func fires(){
        if player != nil {
            self.player!.updateMeters()
            var power:Float = -160
            for i in 0...self.player!.numberOfChannels {
                if self.player!.averagePower(forChannel: i) > -160 {
                    power = self.player!.averagePower(forChannel: i)
                    break
                }
            }
            print(power)
            UIView.animate(withDuration: 0.1, animations: {
                if power > -2 {
                    power = 2
                }
                var scale = CGFloat(1.0 + abs(1/power))
                self.songimg.transform = CGAffineTransform(scaleX: scale, y: scale )
            })
            DispatchQueue.main.async {
                let dr = Int(self.player!.currentTime)
                let end = Int(self.player!.duration)
                self.currtime.text = String(format: "%02d:%02d",dr/60,dr%60)
                self.lefttime.text = String(format: "-%02d:%02d",(end-dr)/60,(end-dr)%60)
            
                self.slidecontrol.value = Float(self.player!.currentTime)
                if self.player!.isPlaying{
                    if self.index < self.beats.count{
                        if Double(round(100*self.beats[self.index])/100) == Double(round(self.player!.currentTime*100)/100 + 0.0) {
                            print(self.index)
                    
                    var msg = 0
                            if self.index < self.beats.count-1 {
                                if Double(round(100*self.beats[self.index+1])/100) - Double(round(100*self.beats[self.index])/100) > 0.6{
                            msg = 1
                        }
                                else if Double(round(10*self.beats[self.index+1])/10) - Double(round(10*self.beats[self.index])/10) < 0.1{
                            msg = 2
                                    self.index = self.index + 1
                        }
                    }
                                Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(self.impact), userInfo: nil, repeats: false)
                            self.sendWatchMessage(type: msg)
                    
                    /*UIView.animate(withDuration: 0.05, animations: {
                        
                        self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }) { (finished) in
                        UIView.animate(withDuration: 0.05, animations: {
                            self.imageView.transform = CGAffineTransform.identity
                        })
                    }*/
                            self.index = self.index+1
                }
                        else if Double(round(100*self.beats[self.index])/100) < Double(round(self.player!.currentTime*100)/100 + 0.0){
                            while Double(round(100*self.beats[self.index])/100) <= Double(round(self.player!.currentTime*100)/100 + 0.0) && self.index < self.beats.count - 1 {
                                self.index = self.index+1
                    }
                }
            }
            }
            else {
                    self.timer.invalidate()
                    self.playNext()
            }
        }
        }
    }
    func sendWatchMessage(type: Int) {
        var message = ["Message" : "0"]
        if type == 1 {
            message = ["Message" : "1"]
        }
        else if type == 2 {
            message = ["Message" : "2"]
        }
        session.sendMessage(message as [String : Any], replyHandler: nil, errorHandler: { (err) in
            print(err.localizedDescription)
        })
    }
    var documentURL = { () -> URL in
        let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentURL
    }
    func playMusic(song: Song){
        session.sendMessage(["Status": "play"], replyHandler: nil, errorHandler: nil)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        let res = documentURL().appendingPathComponent(song.storagePath).path
        if song.artwork != nil {
            songimg.image = song.artwork
            songimg.layer.cornerRadius = 20
        }
        else{
            songimg.image = UIImage(named: "songicon3")
        }
        songTitle.text = song.title
        do{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            player = try AVAudioPlayer(contentsOf: documentURL().appendingPathComponent(song.storagePath))
            if player != nil{
                if (res != "") {
                    beats = [Double]()
                    let buff_size: uint_t = 512
                    let hop_size : uint_t = 256
                    let b = new_aubio_source(res, 0, hop_size)
                    let samplerate = aubio_source_get_samplerate(b)
                    let tempo: OpaquePointer? = new_aubio_tempo("default",buff_size,hop_size,samplerate)
                    let a = new_fvec(hop_size)
                    print(samplerate)
                    var read: uint_t = 0
                    let beat = new_fvec(1)
                    var total_frames : uint_t = 0
                    aubio_tempo_set_silence (tempo,-30)
                    while (true) {
                        aubio_source_do(b, a, &read)
                        aubio_tempo_do(tempo, a, beat)
                        if (fvec_get_sample(beat, 0) != 0) {
                            let beat_time : Double = Double(total_frames) / Double(samplerate)
                            beats.append(beat_time - 0.15)
                        }
                        total_frames += read
                        if (read < hop_size) { break }
                    }
                    var bpmanalyze: [Float : Int] = [:]
                    let len = beats.count
                    var i = 0
                    while i < len - 1 {
                        var rounded = Float(round((beats[i + 1] - beats[i]) * 10) / 10)
                        if bpmanalyze[rounded] != nil{
                            bpmanalyze[rounded] = bpmanalyze[rounded]! + 1
                        }
                        else{
                            bpmanalyze[rounded] = 1
                        }
                        i = i + 1
                    }
                    print(bpmanalyze)
                    var biggest = 0
                    var tempbpm: Double!
                    bpmanalyze.forEach { (key: Float, val: Int) in
                        if(val > biggest){
                            biggest = val
                            tempbpm = Double(key)
                        }
                    }
                    i = 0
                    var count = 0
                    bpm = 0
                    while i < len - 1 {
                        var rounded = Double(round((beats[i + 1] - beats[i]) * 100) / 100)
                        if rounded == tempbpm {
                            bpm = bpm! + (beats[i + 1] - beats[i])
                            count = count + 1
                        }
                        i = i + 1
                    }
                    bpm = bpm! / Double(count)
                    print(bpm)
                    print("read", total_frames, "frames at", aubio_source_get_samplerate(b), "Hz")
                    del_aubio_source(b)
                    del_fvec(a)
                }
                if volumeButtonOutlet.currentBackgroundImage == UIImage(named: "TmuteVolumeButton")
                {
                    player!.volume = 0
                }
                index = 0
                player!.isMeteringEnabled = true
                player!.prepareToPlay()
                player!.play()
                slidecontrol.minimumValue = 0
                slidecontrol.maximumValue = Float(player!.duration)
                if song.artist != " " {
                    songartist.text = song.artist
                }
                else{
                    songartist.text = "No artist"
                }
                slidecontrol.value = 0
                let durationtemp = Int(player!.duration)
                currtime.text = "00:00"
                lefttime.text = String(format: "-%02d:%02d",durationtemp/60,durationtemp%60)
                playButtonOutlet.setBackgroundImage(UIImage(named: "TpauseButton"), for: .normal)
                timer.invalidate()
                Timer.scheduledTimer(timeInterval: beats[0], target: self, selector: #selector(startAnimate), userInfo: nil, repeats: false)
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fires), userInfo: nil, repeats: true)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    @IBOutlet weak var playButtonOutlet: UIButton!
    
    
    @IBAction func settingspress(_ sender: Any) {
        view.addSubview(settingsview2!)
        UIView.animate(withDuration: 0.5) {
            self.settingsview2!.alpha = 1
        }
    }
    @IBAction func slides(_ sender: Any) {
        if player != nil{
            let curr = Double(slidecontrol.value)
            index=0
            let templen = beats.count
            while beats[index] < curr {
                if index + 1 < templen {
                    index = index + 1
                }
                else{
                    break
                }
            }
                player!.currentTime = TimeInterval(slidecontrol.value)
                player!.prepareToPlay()
                player!.play()
                timer.invalidate()
            
            if player != nil && beats[index] != nil && index < beats.count - 1{
                Timer.scheduledTimer(timeInterval: beats[index] - player!.currentTime, target: self, selector: #selector(startAnimate), userInfo: nil, repeats: false)
            }
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fires), userInfo: nil, repeats: true)
            playButtonOutlet.setBackgroundImage(UIImage(named: "TpauseButton"), for: .normal)
        }
    }
    @IBAction func stopslide(_ sender: Any) {
        timer.invalidate()
    }
    func play(){
        if player != nil{
            print("play")
            playButtonOutlet.setBackgroundImage(UIImage(named: "TpauseButton"), for: .normal)
            player!.play()
            timer.invalidate()
            if player != nil && index < beats.count - 1 && beats[index] != nil {
                Timer.scheduledTimer(timeInterval: beats[index] - player!.currentTime, target: self, selector: #selector(startAnimate), userInfo: nil, repeats: false)
            }
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fires), userInfo: nil, repeats: true)
        }
    }
    func pause(){
        if player != nil{
            timer.invalidate()
            gl.removeAllAnimations()
            playButtonOutlet.setBackgroundImage(UIImage(named: "TplayButton"), for: .normal)
            player!.pause()
        }
    }
    @IBAction func playButton(_ sender: UIButton) {
        if player != nil{
            if playButtonOutlet.currentBackgroundImage == UIImage(named: "TplayButton")
            {
                play()
                session.sendMessage(["Status":"play"], replyHandler: nil, errorHandler: nil)
            }
            else
            {
                pause()
                session.sendMessage(["Status":"pause"], replyHandler: nil, errorHandler: nil)
            }
        }
        else {
            self.performSegue(withIdentifier: "toPlaylist", sender: self)
        }
    }
    
    @IBOutlet weak var heartButtonOutlet: UIButton!
    
    @IBAction func heartButton(_ sender: UIButton) {
        
        if heartButtonOutlet.currentBackgroundImage == UIImage(named: "TheartStroke")
        {
            heartButtonOutlet.setBackgroundImage(UIImage(named: "TheartFull"), for: .normal)
        }
        else{
            heartButtonOutlet.setBackgroundImage(UIImage(named: "TheartStroke"), for: .normal)
        }
        
    }
    
    @IBOutlet weak var shuffleButtonOutlet: UIButton!
    
    @IBAction func shuffleButton(_ sender: UIButton) {
        
        if shuffleButtonOutlet.currentBackgroundImage == UIImage(named: "Tshuffle")
        {
            shuffleButtonOutlet.setBackgroundImage(UIImage(named: "TstopShuffleS"), for: .normal)
            nowIndex = 0
            while songlist[nowIndex].id != songshuffled[nowshuffledIndex].id{
                nowIndex = nowIndex + 1
            }
        }
        else{
            shuffleButtonOutlet.setBackgroundImage(UIImage(named: "Tshuffle"), for: .normal)
            songshuffled = songlist.shuffled()
            nowshuffledIndex = 0
            while songlist[nowIndex].id != songshuffled[nowshuffledIndex].id{
                nowshuffledIndex = nowshuffledIndex + 1
            }
        }
        
    }
    
    @IBOutlet weak var volumeButtonOutlet: UIButton!
    
    @IBAction func nextButton(_ sender: Any) {
        playNext()
    }
    @IBAction func prevButton(_ sender: Any) {
        playPrev()
    }
    @objc func openwatch(_ sender: UIButton){
    }
    @IBAction func volumeButton(_ sender: UIButton) {
        if self.session.isPaired{
        if self.session.isWatchAppInstalled{
            if self.session.isReachable{
                self.watchlabel.text = "You are connected."
                self.watchdesc.text = "Feel the unlimited experience"
                self.watchlabel.textColor = UIColor(red: 0, green: 170, blue: 0, alpha: 1)
            }
            else{
                self.watchlabel.text = "Almost there."
                self.watchdesc.text = "Open your Vibes watch app"
                self.watchlabel.textColor = .white
                let button = UIButton()
                button.setTitle("Open", for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                button.frame = CGRect(x: 0, y: 160, width: 80, height: 40)
                button.layer.cornerRadius = 20
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.white.cgColor
                button.alpha = 0.7
                button.addTarget(self, action: #selector(openwatch(_:)), for: .touchUpInside)
                //watchcontainer.addSubview(button)
            }
        }
        else{
            self.watchlabel.text = "Cannot find Watch App."
            self.watchdesc.text = "Install Vibes in your Apple Watch"
            self.watchlabel.textColor = .white
        }
    }
    else{
        self.watchlabel.text = "You are not connected to Apple Watch."
        self.watchdesc.text = "Connect your apple watch to feel more powerful haptics"
        self.watchlabel.textColor = .white
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.watchview2!.alpha = 1
            self.view.addSubview(self.watchview2!)
        }) { (completed) in
            UIView.animate(withDuration: 0.2, animations: {
                self.watchview2!.subviews.forEach({ (sub) in
                    if ((sub as? UIImageView) != nil){
                        sub.alpha = 0.5
                        sub.transform = CGAffineTransform(translationX: 50, y: 0)
                    }
                })
            })
        }
    }
    
    @objc func closesettings(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            self.settingsview2!.alpha = 0
        }) { (completed) in
            self.settingsview2!.removeFromSuperview()
        }
    }
    @objc func closewatch(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            self.watchview2!.alpha = 0
        }) { (completed) in
            self.watchview2!.removeFromSuperview()
            self.watchview2!.subviews.forEach({ (sub) in
                if ((sub as? UIImageView) != nil){
                    sub.alpha = 0
                    sub.transform = CGAffineTransform.identity
                }
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        imageView.frame = CGRect(x: 0,y: 0, width: 630, height: 350)
        createParticles()
        createParticles2()
        
        settingsview.frame = view.frame
        settingsview.alpha = 0
        settingsview.center = view.center
        settingsview.backgroundColor = .clear
        aboutcontainer.frame = CGRect(x: settingsview.center.x - 150, y: settingsview.center.y - 200, width: 300, height: 400)
        let abouttitle = UILabel()
        abouttitle.frame = CGRect(x: 0, y: 0, width: aboutcontainer.frame.width, height: 20)
        abouttitle.text = "Vibes"
        abouttitle.textColor = .white
        abouttitle.textAlignment = .left
        abouttitle.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        let aboutdesc = UILabel()
        aboutdesc.numberOfLines = 6
        aboutdesc.font = UIFont(name: "Avenir", size: 20.0)
        aboutdesc.textColor = .white
        aboutdesc.frame = CGRect(x: 0, y: 20, width: aboutcontainer.frame.width, height: 200)
        aboutdesc.text = "Vibes is an advanced music player which let you experience music without limits. Feel alive with solid haptics and vibrations based on music beats. Limit your limitations."
        settingsview2 = settingsview
        settingsview = nil
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.closesettings(_:)))
        let blur = UIBlurEffect(style: .dark)
        let effect = UIVisualEffectView(effect: blur)
        effect.alpha = 0.9
        effect.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        settingsview2!.addSubview(effect)
        aboutcontainer.addSubview(abouttitle)
        aboutcontainer.addSubview(aboutdesc)
        settingsview2!.addSubview(aboutcontainer)
        settingsview2!.addGestureRecognizer(gesture)
        
        watchview.frame = view.frame
        watchview.backgroundColor = .clear
        watchview.alpha = 0
        watchview2 = watchview
        watchview = nil
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(self.closewatch(_:)))
        let gestureview = UIView()
        let blur2 = UIBlurEffect(style: .dark)
        let effect2 = UIVisualEffectView(effect: blur2)
        effect2.alpha = 0.9
        effect2.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        gestureview.backgroundColor = .clear
        gestureview.frame = view.frame
        let watchimg = UIImageView(image: UIImage(named: "watch5"))
        watchimg.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        watchimg.center = CGPoint(x: view.center.x - 150, y: view.center.y)
        watchimg.alpha = 0
        watchcontainer.frame = CGRect(x: view.center.x, y: view.center.y - 100, width: view.frame.width / 2 - 50, height: 200)
        watchlabel.text = "You are not connected to Apple Watch."
        watchlabel.textColor = .white
        watchlabel.numberOfLines = 3
        watchlabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        watchlabel.frame = CGRect(x: 0, y: 0, width: watchcontainer.frame.width, height: 100)
        watchdesc.text = "connect your apple watch to feel more powerful haptics."
        watchdesc.font = UIFont(name: "Avenir", size: 15)
        watchdesc.textColor = .white
        watchdesc.numberOfLines = 3
        watchdesc.frame = CGRect(x: 0, y: 90, width: watchcontainer.frame.width, height: 70)
        watchcontainer.addSubview(watchlabel)
        watchcontainer.addSubview(watchdesc)
        gestureview.addGestureRecognizer(gesture2)
        watchview2!.addSubview(effect2)
        watchview2!.addSubview(gestureview)
        watchview2!.addSubview(watchimg)
        watchview2!.addSubview(watchcontainer)
        
        
        
        let colorTop = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0).cgColor
        let colorBottom = UIColor(red: 0, green: 1, blue: 1, alpha: 0.3).cgColor
        
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.5]
        gl.position = CGPoint(x: view.center.x, y: view.center.y + 1000)
        gl.frame = view.frame
        view.layer.insertSublayer(gl, at: 0)
        songimg.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        songimg.image = UIImage(named: "songicon3")
        songimg.layer.cornerRadius = 25
        songimg.layer.masksToBounds = true
        songimg.backgroundColor = UIColor(red: 0, green: 100/255, blue: 100/255, alpha: 1)
        songimg.center = CGPoint(x: view.center.x, y: view.center.y - 80)
        view.addSubview(songimg)
        let blur3 = UIBlurEffect(style: .dark)
        let effect3 = UIVisualEffectView(effect: blur3)
        effect3.alpha = 0.4
        effect3.layer.cornerRadius = 25
        effect3.clipsToBounds = true
        effect3.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        effect3.center = songimg.center
        view.addSubview(effect3)
        slidecontrol.setThumbImage(UIImage(named: "thumb") , for: UIControl.State.normal)
        slidecontrol.minimumTrackTintColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
        session.delegate = self
        session.activate()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
extension playViewController: PlaylistProtocol{
    
    func songSelected(song: Song, songlist: [Song]) {
        self.songlist = songlist
        if shuffleButtonOutlet.currentBackgroundImage == UIImage(named: "Tshuffle"){
            songshuffled = songlist.shuffled()
            nowshuffledIndex = songshuffled.firstIndex(of: song)!
        }
        else{
            nowIndex = songlist.firstIndex(of: song)!
        }
        playMusic(song: song)
        session.sendMessage(["Status":"play"], replyHandler: nil, errorHandler: nil)
    }
    func updatelist(songlist: [Song]) {
        var index = self.songlist.count
        let len = songlist.count
        while index < len {
            self.songlist.append(songlist[index])
            if songshuffled.count == 0 {
                self.songshuffled.append(songlist[index])
            }
            else{
                var random = Int.random(in: 0..<songshuffled.count + 1)
                while random == nowshuffledIndex {
                    random = Int.random(in: 0..<songshuffled.count + 1)
                }
                self.songshuffled.insert(songlist[index], at: random)
            }
            index = index + 1
        }
    }
}
