//
//  ViewController.swift
//  vibrate
//
//  Created by christopher putra setiawan on 17/01/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol PlaylistProtocol {
    func songSelected(song: Song, songlist: [Song])
    func updatelist(songlist: [Song])
}

class ViewController: UIViewController {
    
    var delegate:PlaylistProtocol!
    
    var songsbundle: [String] = []
    var songlist = [Song]()
    var currsonglist = [Song]()
    var activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView()
    var nosonglabel = UILabel()
    var exportLabel: UILabel!
    var popupexport: UIView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var buttonname: UIButton!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var insert: UIButton!
    var insertbutton: UIButton!
    
    @IBOutlet weak var close: UIButton!
    @IBAction func exit(_ sender: Any) {
        delegate.updatelist(songlist: self.songlist)
        self.dismiss(animated: true, completion: nil)
    }
    var documentURL = { () -> URL in
        let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentURL
    }
    func checkForMusicLibraryAccess(andThen f:(()->())? = nil) {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            f?()
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        f?()
                    }
                }
            }
        case .restricted:
            // do nothing
            break
        case .denied:
            // do nothing, or beg the user to authorize us in Settings
            break
        }
    }
    func presentPicker (sender: Any) {
        checkForMusicLibraryAccess {
            let picker = MPMediaPickerController(mediaTypes:.music)
            picker.showsCloudItems = false
            picker.delegate = self
            picker.allowsPickingMultipleItems = true
            picker.modalPresentationStyle = .popover
            picker.preferredContentSize = CGSize(width: 500,height: 600)
            self.present(picker, animated: true)
            if let pop = picker.popoverPresentationController {
                if let b = sender as? UIBarButtonItem {
                    pop.barButtonItem = b
                }
            }
        }
    }
    @IBAction func insert(_ sender: Any) {
        self.presentPicker(sender: sender)
    }
    @IBAction func insertsong(button : UIButton){
        self.presentPicker(sender: button)
    }
    func reloadData(){
        if currsonglist.isEmpty {
            view.addSubview(nosonglabel)
        }
        else{
            nosonglabel.removeFromSuperview()
        }
        self.table.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
        insertbutton = UIButton.init(frame: CGRect(origin: CGPoint(x: self.view.frame.width - 70.0, y: self.view.frame.height - 110.0), size: CGSize(width: 50.0, height: 50.0)))
        insertbutton.layer.borderColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1).cgColor
        insertbutton.layer.borderWidth = 2
        insertbutton.titleLabel?.textAlignment = .center
        insertbutton.setBackgroundImage(UIImage(named: "plus"), for: .normal)
        insertbutton.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        insertbutton.setTitleColor(.black, for: .normal)
        insertbutton.titleLabel?.center.y = insertbutton.center.y - 5
        insertbutton.titleLabel?.baselineAdjustment = UIBaselineAdjustment.alignCenters
        insertbutton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        insertbutton.layer.cornerRadius = 25.0
        insertbutton.addTarget(self, action: #selector(insertsong(button:)), for: .touchUpInside)
        view.addSubview(insertbutton)
        popupexport = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        popupexport.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.white
        exportLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        exportLabel.textColor = UIColor.white
        exportLabel.center = CGPoint(x: activityIndicator.center.x, y: activityIndicator.center.y + 30.0)
        exportLabel.text = "Processing"
        exportLabel.font = .systemFont(ofSize: 14.0)
        exportLabel.textAlignment = .center
        popupexport.addSubview(exportLabel)
        popupexport.addSubview(activityIndicator)
        table.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 0)
        table.frame.size = CGSize(width: view.frame.width, height: view.frame.height - 115)
        table.rowHeight = 60
        nosonglabel = UILabel(frame: CGRect(x: table.center.x - 50, y: table.center.y - 100, width: 100, height: 20))
        nosonglabel.center = CGPoint(x: table.center.x, y: table.center.y - 50)
        nosonglabel.textAlignment = .center
        nosonglabel.font = UIFont.systemFont(ofSize: 15)
        nosonglabel.text = "No song"
        nosonglabel.textColor = .gray
        searchbar.layer.cornerRadius = 2
        
        for subView in searchbar.subviews
        {
            for subView1 in subView.subviews
            {
                
                if let textfield = subView1 as? UITextField
                {
                    textfield.superview?.layer.cornerRadius = 2
                    textfield.tintColor = .white
                    textfield.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                    textfield.layer.cornerRadius = 2
                    textfield.font = UIFont.systemFont(ofSize: 15)
                    textfield.textColor = UIColor.white
                }
            }
            
        }
        searchbar.tintColor = UIColor.init(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
        searchbar.barTintColor = UIColor.init(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
        let gl = CAGradientLayer()
        let colorTop = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0).cgColor
        let colorBottom = UIColor(red: 0, green: 1, blue: 1, alpha: 0.3).cgColor
        
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.5]
        gl.position = CGPoint(x: view.center.x, y: view.center.y + 1000)
        gl.frame = view.frame
        
        view.layer.insertSublayer(gl, at: 0)
        table.delegate = self
        table.dataSource = self
        searchbar.delegate = self
        if let unarchivedObject = UserDefaults.standard.object(forKey: "SongArray") as? Data {
            
            self.songlist = (NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [Song])!
            self.currsonglist = self.songlist
        }
        reloadData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else{
            currsonglist = songlist
            table.reloadData()
            return
        }
        currsonglist = songlist.filter({ (song) -> Bool in
            song.title.lowercased().contains(searchText.lowercased())
        })
        table.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
extension ViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            var cell = table.cellForRow(at: indexPath)
            cell?.backgroundColor = .black
            delegate.songSelected(song: currsonglist[indexPath.row], songlist: self.songlist)
                self.dismiss(animated: true, completion: nil)
        }
        
    }
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currsonglist.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 0)
        cell.backgroundColor = .clear
        let border = UIView(frame: CGRect(x: 90, y: cell.frame.height - 1, width: cell.frame.width - 90, height: 1))
        border.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        cell.addSubview(border)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if let artwork = currsonglist[indexPath.row].artwork{
            cell.songicon.image = artwork
        }
        else{
            cell.songicon.image = UIImage(named: "songicon3")!.alpha(0.2)
        }
        cell.songicon.layer.cornerRadius = 4
        cell.songtitle.text = currsonglist[indexPath.row].title
        if songlist[indexPath.row].artist != "" {
            cell.songartist.text = currsonglist[indexPath.row].artist
        }
        else{
            cell.songartist.text = "No artist"
        }
        return cell
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
extension MPMediaItem{
    
    // Value is in Bytes
    var fileSize: Int{
        get{
            if let size = self.value(forProperty: "fileSize") as? Int{
                return size
            }
            return 0
        }
    }
    
    var fileSizeString: String{
        let formatter = Foundation.NumberFormatter()
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: NSNumber(value: Float(self.fileSize)/1048567.0)) ?? "0") + " MB"
    }
    
}
extension ViewController : MPMediaPickerControllerDelegate {
    // must implement these, as there is no automatic dismissal
    
    func loadingView(){
        activityIndicator.startAnimating()
        view.addSubview(popupexport)
    }
    func finishLoading(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.popupexport.removeFromSuperview()
        }
    }
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        for tempItem in mediaItemCollection.items {
            let item: MPMediaItem = tempItem
            let pathURL: URL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
            if pathURL == nil {
                print("Picking Error")
                return
            }
            let songAsset = AVURLAsset(url: pathURL!, options: nil)
            
            let tracks = songAsset.tracks(withMediaType: .audio)
            
            if(tracks.count > 0){
                let track = tracks[0]
                if(track.formatDescriptions.count > 0){
                    let desc = track.formatDescriptions[0]
                    let audioDesc = CMAudioFormatDescriptionGetStreamBasicDescription(desc as! CMAudioFormatDescription)
                    let formatID = audioDesc?.pointee.mFormatID
                    
                    var fileType:String?
                    var ex:String?
                    
                    switch formatID {
                    case kAudioFormatLinearPCM:
                        print("wav or aif")
                        let flags = audioDesc?.pointee.mFormatFlags
                        if( (flags != nil) && flags == kAudioFormatFlagIsBigEndian ){
                            fileType = "public.aiff-audio"
                            ex = "aif"
                        }else{
                            fileType = "com.microsoft.waveform-audio"
                            ex = "wav"
                        }
                        
                    case kAudioFormatMPEGLayer3:
                        print("mp3")
                        fileType = "com.apple.quicktime-movie"
                        ex = "mp3"
                        break;
                        
                    case kAudioFormatMPEG4AAC:
                        print("m4a")
                        fileType = "com.apple.m4a-audio"
                        ex = "m4a"
                        break;
                        
                    case kAudioFormatAppleLossless:
                        print("m4a")
                        fileType = "com.apple.m4a-audio"
                        ex = "m4a"
                        break;
                        
                    default:
                        break;
                    }
                    let exportSession = AVAssetExportSession(asset: AVAsset(url: pathURL!), presetName: AVAssetExportPresetAppleM4A)
                    exportSession?.shouldOptimizeForNetworkUse = true
                    //                    exportSession?.outputFileType = AVFileType.m4a
                    //                    exportSession?.outputFileType = AVFileType(rawValue: fileType! as String) ;
                    exportSession?.outputFileType = AVFileType.m4a ;
                    
                    let artwork = item.artwork?.image(at: CGSize(width: 50, height: 50)) ?? nil
                    let fileName = item.value(forProperty: MPMediaItemPropertyTitle) as! String
                    
                    print("fileName -> \(fileName)")
                    let outputURL = "\(fileName).m4a"
                    print("OutURL->\(outputURL)")
                    print("fileSizeString->\(item.fileSizeString)")
                    print("fileSize->\(item.fileSize)")
                    print("Bpm->\(item.beatsPerMinute)")
                    
                    let duplicate = songlist.filter({ $0.id == item.persistentID })
                    if duplicate.count == 0{
                        self.songlist.append(Song.init(title: fileName, fileType: fileType ?? "", ext: ex ?? "", artwork: artwork as Any,size: item.fileSizeString, artist: item.albumArtist ?? "", bpm: item.beatsPerMinute, id: item.persistentID, storagePath: outputURL, isClouditem: item.isCloudItem))
                        self.currsonglist = self.songlist
                    }
                    loadingView()
                    exportSession?.outputURL = documentURL().appendingPathComponent(outputURL)
                    exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                        if exportSession!.status == AVAssetExportSession.Status.completed  {
                            print("Export Successfull")
                            let songData = NSKeyedArchiver.archivedData(withRootObject: self.songlist)
                            UserDefaults.standard.set(songData, forKey: "SongArray")
                            print("arr => \(self.songlist)")
                            
                            DispatchQueue.main.async {
                                self.reloadData()
                            }
                            
                        } else {
                            print("Export failed")
                            print(exportSession!.error as Any)
                        }
                        self.finishLoading()
                    })
                }
            }
        }
        self.dismiss(animated:true)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("cancel")
        self.dismiss(animated:true)
    }
    
}
