//
//  AudioViewController.swift
//  iOSBackgroundDemo
//
//  Created by ZhaoFucheng on 16/4/4.
//  Copyright © 2016年 ZhaoFucheng. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioViewController: UIViewController {

    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var player: AVQueuePlayer!
    private var myContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: .DefaultToSpeaker)
        } catch {
            NSLog("Failed to set audio session category.  Error: \(error)")
        }
        
        let songNames = ["我也可以是流浪诗人","家"]
        
        let songs = songNames.map {
            AVPlayerItem(URL:NSBundle.mainBundle().URLForResource($0, withExtension: "mp3")!)
        }
        
        player = AVQueuePlayer(items: songs)
        player.actionAtItemEnd = .Advance
        
        //添加KVO
        player.addObserver(self, forKeyPath: "currentItem", options: OCUtils.keyValueObservingOptions() , context: &myContext)
        
        player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 100), queue: dispatch_get_main_queue()) {
            [unowned self] time in
            let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
            if UIApplication.sharedApplication().applicationState == .Active {
                self.timeLabel.text = timeString
            } else {
                print("Background: \(timeString)")
            }
        }
    }

    //KVO 更新歌曲名字
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentItem", let player = object as? AVPlayer,
            currentItem = player.currentItem?.asset as? AVURLAsset {
            songLabel.text = currentItem.URL.lastPathComponent?.stringByReplacingOccurrencesOfString(".mp3", withString: "") ?? "Unknown"
            configNowPlayingCenter(currentItem)
        }
    }
    
    //播放按钮事件
    @IBAction func playAndPauseAction(sender: UIButton) {
        sender.selected = !sender.selected
        if sender.selected {
            player.play()
            let currentItem = player.currentItem?.asset as? AVURLAsset
            configNowPlayingCenter(currentItem!)
        } else {
            player.pause()
        }
    }
    
    //配置NowPlayingCenter
    func configNowPlayingCenter(currentItem: AVURLAsset) {
        if (NSClassFromString("MPNowPlayingInfoCenter") != nil) {
            
            var songInfo = Dictionary<String, AnyObject>()
            
            let songTitle = currentItem.URL.lastPathComponent?.stringByReplacingOccurrencesOfString(".mp3", withString: "")
            
            let albumArt = MPMediaItemArtwork(image: UIImage(named: songTitle!)!)
            songInfo[MPMediaItemPropertyTitle] = songTitle
            songInfo[MPMediaItemPropertyArtist] = "演唱者"
            songInfo[MPMediaItemPropertyAlbumTitle] = "专辑"
            songInfo[MPMediaItemPropertyArtwork] = albumArt
            songInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            songInfo[MPMediaItemPropertyPlaybackDuration] = CMTimeGetSeconds((player.currentItem?.duration)!)
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        }
    }
    
    //重写方法 成为第一响应者
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //Remote Control控制音乐的播放
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        switch event?.subtype {
        case UIEventSubtype.RemoteControlPlay?: // 音乐播放
            player.play()
            break
        case UIEventSubtype.RemoteControlPause?: // 音乐暂停
            player.pause()
            break
        case UIEventSubtype.RemoteControlPreviousTrack?: //上一首
            break;
        case UIEventSubtype.RemoteControlNextTrack?: //下一首
            player.advanceToNextItem()
            break;
        case UIEventSubtype.RemoteControlTogglePlayPause?: //耳机线控的播放暂停
            break
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "currentItem", context: &myContext)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
