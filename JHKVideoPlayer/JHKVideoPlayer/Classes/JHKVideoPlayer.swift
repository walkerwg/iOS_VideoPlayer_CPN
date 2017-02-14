//
//  JHKVideoPlayer.swift
//  JHKVideoPlayer
//  This is the core .swift file for JHKVideoPlayer
//
//
//  Created by LuisGin on 17/2/7.
//  Copyright © 2017 LuisGin. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

/// Enums for playing status
public enum JHKVideoPlayerState: Int {
    case playing = 0
    case pause
    case stop
}

/// Enums whether Player is on full screen mode
public enum JHKPlayerFullScreenMode: Int {
    case normal = 0
    case full
}

/// Enum fill strategy
public enum JHKPlayerContentFillMode: Int {
    case normal
    case aspectFit
    case scaleFill
}

/// An implement of video player which provide multiple predefined action, and can be expanded in further
///
/// - Author: Luis Gin
/// - Version: v0.1.1
open class JHKVideoPlayer: UIView, JHKPlayerDelegate {

// MARK: - states signal
    /// Status for video player
    ///
    /// - Default: default value as JHKVideoPlayerState.stop
    /// - SeeAlso: JHKVideoPlayerState
    public var playState: JHKVideoPlayerState = .stop {
        didSet {
            if oldValue != playState {
                switch playState {
                case .playing:
                    self.player?.play()
                    let image = UIImage.imageInBundle(named: "btn_pause")
                    controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
                    if link == nil {
                        link = CADisplayLink(target: self, selector: #selector(checkLag))
                        link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
                    }
                case .pause:
                    self.player?.pause()
                    let image = UIImage.imageInBundle(named: "btn_play")
                    controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
                    if link != nil {
                        link?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
                        link = nil
                    }
                case .stop:
                    self.stopPlay()
                }
            }
        }
    }

    // whether view is on full screen mode
    public var isFull: JHKPlayerFullScreenMode = .normal {
        didSet {
            if isFull == .normal {
                self.frame = self.originFrame!
                let image = UIImage.imageInBundle(named: "player_full")
                controlView?.fullOrSmallButton.setBackgroundImage(image, for: .normal)
                if (self.playerDelegate?.responds(to: NSSelectorFromString("playerDidShrink")))! {
                    self.playerDelegate?.playerDidShrink!()
                } else {
                    self.controlView?.definitionButton.removeFromSuperview()
                    self.controlView?.bottomControlsArray.remove(self.controlView?.definitionButton)
                    self.controlView?.moreButton.removeFromSuperview()
                    self.controlView?.topControlsArray.remove(self.controlView?.moreButton)
                }
            }
            else {
                self.frame = (self.window?.bounds)!
                let image = UIImage.imageInBundle(named: "player_shrink")
                controlView?.fullOrSmallButton.setBackgroundImage(image, for: .normal)
                if (self.playerDelegate?.responds(to: NSSelectorFromString("playerDidFull")))! {
                    self.playerDelegate?.playerDidFull!()
                } else {
                    self.controlView?.bottomControlsArray.add(self.controlView?.definitionButton)
                    self.controlView?.topControlsArray.add(self.controlView?.moreButton)
                }
            }
        }
    }

    public var fillMode: JHKPlayerContentFillMode = .normal

// MARK: - delegate
    // player delegate for further use
    public weak var playerDelegate: JHKPlayerDelegate?

// MARK: - custom setting
    // Custom settings for appearance
    open var autoStart: Bool = true
    open var autoNext: Bool = true
    open var autoDismissMenu: Bool = true
    open var autoLandscape: Bool = UIDevice.current.userInterfaceIdiom == .phone
    open var hideStatusBarWhenFullScreen: Bool = true

// MARK: - Core component
    // Lazy load AVPlayer as the core media player
    public var player: AVPlayer?
    public var playerLayer: AVPlayerLayer?
    public var playerItem: AVPlayerItem?
    public var playerAsset: AVURLAsset?
    public var snapshotGenerator: AVAssetImageGenerator?
    public var imageOutPut: AVPlayerItemOutput?

    // Control Menu
    public var controlView: JHKPlayerView?

// MARK: - Data
    // Origin frame
    fileprivate var originFrame: CGRect?
    
    // Title description
    public var videoTitle: String? {
        didSet {
            controlView?.titleLabel.text = videoTitle!
        }
    }
//    var videoDescription: String? {
//        didSet {
//            controlView?.titleLabel.text = videoTitle! + videoDescription!
//        }
//    }
    
    // Loaded video length
    public var loadedTime: CGFloat? {
        didSet {
            guard let loadedTime = loadedTime else { return }
            controlView?.loadProgressView.setProgress(Float(loadedTime), animated: true)
        }
    }
    
    // Played video length
    public var currentTime: CGFloat? {
        didSet {
            guard let currentTime = currentTime else { return }
            controlView?.playSlider.setValue(Float(currentTime), animated: true)
            let timeCurrent :String = formatTimer(currentTime)
            controlView?.currentTimeLabel.text = "\(timeCurrent)"
        }
    }
    
    // Total video length
    public var totalTime: CGFloat? {
        didSet {
            guard let totalTime = totalTime else { return }
            let timeTotal = formatTimer(totalTime)
            controlView?.totalTimeLabel.text = "\(timeTotal)"
            controlView?.playSlider.maximumValue = Float(totalTime)
        }
    }
    
    // Resources url for the media
    public var mediaURL: URL? {
        didSet {
            initPlayer()
        }
    }
    // Interaction with system flush interval
    public var link: CADisplayLink?
    public var localeTime: TimeInterval?
    
// MARK: - Air play support
//    var allowsExternalPlayback = true
//    var isExternalPlaybackActive: Bool {
//      guard let player = self.player else {
//        return false
//    }
//    return player.isExternalPlaybackActive
//  }
    
// MARK: - Public Util Function
    public func formatTimer(_ time: CGFloat) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        if time / 3600 > 1 {
            formatter.dateFormat = "HH:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }
    
    public func checkLag() {
        let current: TimeInterval = CMTimeGetSeconds((player?.currentTime())!)
        if current == localeTime {
            if JHKPlayerClosure.playerDelayClosure != nil {
                JHKPlayerClosure.playerDelayClosure!(true)
            }
        } else {
            if JHKPlayerClosure.playerDelayClosure != nil {
                JHKPlayerClosure.playerDelayClosure!(false)
            }
        }
        localeTime = current
    }
    
// MARK: - Logical methods
    // Stop video player and deallocate
    open func stopPlay() {
        UIApplication.shared.isIdleTimerDisabled = false
        RemoveObservers()
        player?.rate = 0
        player?.replaceCurrentItem(with: nil)
        playerItem = nil
        player = nil
        let image = UIImage.imageInBundle(named: "btn_play")
        controlView?.playSlider.setValue(0, animated: true)
        controlView?.loadProgressView.setProgress(0, animated: false)
        controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
    }

    // Player finish playing current video
    func playfinish(_ notification: NSNotification) {
        player?.seek(to: kCMTimeZero, completionHandler: {_ in
            JHKPlayerClosure.playerFinishClosure!()
        })
    }
    
    // Calculate cache memory
    fileprivate func playerAvailableDuration() -> TimeInterval {
        let loadedTimeRange = player?.currentItem?.loadedTimeRanges
        let timeRange = (loadedTimeRange?.first)?.timeRangeValue
        let startSeconds = CMTimeGetSeconds((timeRange?.start)!)
        let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
        let result = startSeconds + durationSeconds
        return result
    }
    
    // judge if have local file loaded
    fileprivate func isFileExistsAtPath(_ url: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.absoluteString) == true {
            mediaURL = URL(fileURLWithPath: url.absoluteString)
        }
    }

    /// Set background color for all menus related to view player
    fileprivate func setMenuBackgroundColor(color: UIColor) {
        controlView?.menuContentColor = color
    }

// MARK: - Manager methods
    // Remove Observers
    public func RemoveObservers() {
        if link != nil {
            link?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            link = nil
        }
        playerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        player?.removeTimeObserver(playbackTimeObserver!)
        playbackTimeObserver = nil
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(orientChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc fileprivate func orientChange(_ notification: NSNotification) {
        let origent = UIDevice.current.orientation
        if JHKPlayerClosure.deviceOrientClosure != nil{
            JHKPlayerClosure.deviceOrientClosure!(origent)
        }
    }
    
    @objc fileprivate func playerFinishPlay(_ notification: NSNotification) {
        player?.seek(to: kCMTimeZero, completionHandler: {_ in
            JHKPlayerClosure.playerFinishClosure!()
        })
    }
    
    @objc fileprivate func appDidEnterBackground() {
        if playState == .playing {
            player?.pause()
        }
    }
    
    @objc fileprivate func appDidEnterForeground() {
        if playState == .playing {
            player?.play()
        }
    }
    
    // Monitoring playing call back
    fileprivate var playbackTimeObserver: Any?
    fileprivate func monitoringPlayerBack() {
        playbackTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil, using: { [weak self](time) in
            guard let sself = self else { return }
            let currentSecond = CGFloat((sself.playerItem?.currentTime().value)!) / CGFloat((sself.playerItem?.currentTime().timescale)!)
            sself.currentTime = currentSecond
        })
    }
    
// MARK: - init methods
    // Override init method
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        originFrame = frame

        // Set audio display category
        // 本设置将使播放器不随系统静音而静音
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }

    // Init with media url
    public convenience init(url: NSString) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let urlFromString = URL(string: url as String)
        self.mediaURL = urlFromString
    }

    // Constructor for initWithNSCode, which required since swift2.1 when init() is override
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Destory observers while inallocation
    deinit {
        RemoveObservers()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
        controlView?.frame = self.bounds
    }

    /// Init components when an URL is settled for player
    public func initPlayer() {
        // Disable screen lock timer
        UIApplication.shared.isIdleTimerDisabled = true

        if player != nil {
            player = nil
            RemoveObservers()
        }

        if controlView == nil {
            controlView = JHKPlayerView()
            self.addSubview(controlView!)
        }
        JHKNotificationClosure()
        JHKControlClosure()

        // Determined use local file or outside link
        isFileExistsAtPath(mediaURL!)
        playerAsset = AVURLAsset(url: mediaURL!, options: nil)
        playerItem = AVPlayerItem(asset: playerAsset!)

        // Set up item for AVPlayer
        if player?.currentItem != nil {
            player?.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }

        // Set up layer for AVPlayer
        if playerLayer != nil {
            let playerLayer = self.layer.sublayers?.first
            (playerLayer as! AVPlayerLayer).player = player
        } else {
            self.playerLayer = AVPlayerLayer(player: player)
            self.layer.insertSublayer(playerLayer!, at: 0)
        }

        addObservers()
        if autoStart {
            player?.play()
        }
    }

    /// Add observes for player status and state value
    public func addObservers() {
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(orientChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerFinishPlay(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name.UIApplicationWillResignActive, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: playerItem)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem = object as? AVPlayerItem
        if keyPath == "status" {
            if playerItem?.status == .readyToPlay {
                // Player successfully load the video
                let duration = CMTimeGetSeconds((playerItem?.duration)!)
                totalTime = CGFloat(duration)

                if JHKPlayerClosure.playerSuccessClosure != nil {
                    JHKPlayerClosure.playerSuccessClosure!()
                }
                monitoringPlayerBack()
            } else {
                // Player fail to load the video
                if JHKPlayerClosure.playerFailClosure != nil {
                    JHKPlayerClosure.playerFailClosure!()
                }
            }
        } else if keyPath == "loadedTimeRanges" {
            let timeInterval = playerAvailableDuration()
            let duration = CMTimeGetSeconds((playerItem?.duration)!)

            self.loadedTime = CGFloat(timeInterval / duration)
        }
    }

// MARK: - Blocks
    open func JHKNotificationClosure() {

        // Video successfully loaded call back
        JHKPlayerClosure.playerSuccessClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.autoStart == true {
                //sself.controlView?.loadingIndicator.stopAnimating()
                //sself.controlView?.loadingIndicator.hidesWhenStopped = true
                sself.playState = .playing
            }
        }

        // Video fail to init resource call back
        JHKPlayerClosure.playerFailClosure = { [weak self] in
            guard let sself = self else { return }
            sself.playState = .stop
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: {
                sself.controlView?.loadingIndicator.stopAnimating()
                sself.controlView?.loadingIndicator.hidesWhenStopped = true
                sself.playState = .stop
            })
        }

        // Player finish closure
        JHKPlayerClosure.playerFinishClosure = { [weak self] in
            guard let sself = self else { return }
            sself.playState = .stop
            if sself.autoNext && (sself.playerDelegate?.responds(to: NSSelectorFromString("playNextVideo")))! {
                sself.playerDelegate?.playNextVideo!()
            }
        }

        // Orient change closure
        JHKPlayerClosure.deviceOrientClosure = {[weak self] (origent) in
            guard let sself = self else { return }
            if sself.autoLandscape == true {
                if origent == UIDeviceOrientation.portrait {
                    sself.isFull = .normal
                } else if origent == UIDeviceOrientation.landscapeLeft || origent == UIDeviceOrientation.landscapeRight {
                    sself.isFull = .full
                }
            }
        }

        // Delay play if there is lag
        JHKPlayerClosure.playerDelayClosure = { [weak self] (flag) in
            guard let sself = self else { return }
            if flag == true && sself.playState == .stop {
                sself.controlView?.loadingIndicator.startAnimating()
            } else {
                sself.controlView?.loadingIndicator.stopAnimating()
                sself.controlView?.loadingIndicator.hidesWhenStopped = true
            }
        }

        // Processor changing closure
        JHKPlayerClosure.sliderValueChangeClosure = { [weak self] (time) in
            guard let sself = self else { return }
            sself.player?.seek(to: CMTime.init(seconds: Double(time), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            sself.playState = .pause
        }

        // Processor change end closure
        JHKPlayerClosure.sliderDragedClosure = { [weak self] in
            guard let sself = self else { return }
            sself.playState = .playing
        }
    }

    /// Implement closures for player controls
    open func JHKControlClosure() {

        // Change mode of full screen or shrink screen
        JHKPlayerActionClosure.fullOrShrinkClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.isFull == .normal {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }

        // Change playing states closure
        JHKPlayerActionClosure.playOrPauseClosure = { [weak self] in
            guard let sself = self else { return }
            switch sself.playState {
            case .playing:
                sself.playState = .pause
            case .pause:
                sself.playState = .playing
            case .stop:
                sself.initPlayer()
                print("Vidoe is on the loading")
            }
        }

        // Turn back button closure
        JHKPlayerActionClosure.turnBackClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.playerDelegate != nil && (sself.playerDelegate?.responds(to: NSSelectorFromString("quitVideoPlayer")))! {
                sself.playerDelegate?.quitVideoPlayer!()
            } else {
                sself.playState = .stop
            }
        }

        // Play next button closure
        JHKPlayerActionClosure.playNextClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.playerDelegate != nil && (sself.playerDelegate?.responds(to: NSSelectorFromString("playNextVideo")))! {
                sself.playerDelegate?.playNextVideo!()
            } else {
                sself.playState = .stop
            }
        }

        /// Play previous button closure
        JHKPlayerActionClosure.playPreviousClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.playerDelegate != nil && (sself.playerDelegate?.responds(to: NSSelectorFromString("playPreviewsVideo")))! {
                sself.playerDelegate?.playPreviewsVideo!()
            } else {
                sself.playState = .stop
            }
        }

        /// Push screen button closure
        JHKPlayerActionClosure.pushScreenClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.playerDelegate != nil && (sself.playerDelegate?.responds(to: NSSelectorFromString("pushScreenAction")))! {
                sself.playerDelegate?.pushScreenAction!()
            } else {
                sself.playState = .stop
            }
        }

        /// More info button closure
        JHKPlayerActionClosure.moreInfoClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.playerDelegate != nil && (sself.playerDelegate?.responds(to: NSSelectorFromString("moreMenuAction")))! {
                sself.playerDelegate?.moreMenuAction!()
            } else {
                sself.playState = .stop
            }
        }

        /// Change definition closure
        JHKPlayerActionClosure.changeDefinitionClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.playerDelegate != nil && (sself.playerDelegate?.responds(to: NSSelectorFromString("determinedDefinition")))! {
                sself.playerDelegate?.determinedDefinition!()
            } else {
                sself.playState = .stop
            }
        }

        /// Reset current time to schedule
        JHKPlayerActionClosure.scheduledPlayerClosure = { [weak self] (time) in
            guard let sself = self else { return }
            sself.player?.seek(to: CMTime.init(seconds: Double(time), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
    }
}

extension UIImage {
    /// Extension for determined specific Image resources in the bundle of CocoaPods Component
    ///
    /// - Parameter name: (String) - image name in bundle
    /// - Returns: image: UIImage
    /// - Warning: for internal use only
    /// - SeeAlso: `imageInBundle()`
    internal class func imageInBundle(named name: String) -> UIImage?{
        let bundleUrl = Bundle.main.url(forResource: "JHKPlayerBundle", withExtension: "bundle")
        let bundle = Bundle(url: bundleUrl!)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
    
    /// Extension for determined specific Image resources in the bundle of CocoaPods Component
    ///
    /// - Parameter name: (String) - image name in bundle
    /// - Parameter bundle: (String) - bundle name in specific
    /// - Returns: image: UIImage
    internal class func imageInBundle(named name: String, from bundle: String) -> UIImage?{
        let bundleUrl = Bundle.main.url(forResource: bundle, withExtension: "bundle")
        let bundle = Bundle(url: bundleUrl!)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
}
