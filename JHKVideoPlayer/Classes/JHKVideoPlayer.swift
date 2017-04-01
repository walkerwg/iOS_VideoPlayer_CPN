//
//  JHKVideoPlayer.swift
//  JHKVideoPlayer
//
//  This is the core .swift file for JHKVideoPlayer
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
open class JHKVideoPlayer: UIView {

    // MARK: - states signal
    /// Status for video player
    ///
    /// - Default: default value as JHKVideoPlayerState.stop
    /// - SeeAlso: JHKVideoPlayerState
    public var playState: JHKVideoPlayerState = .stop {
        didSet {
            switch playState {
            case .playing:
                self.player?.play()
                let image = UIImage.imageInBundle(named: "btn_pause")
                controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
            case .pause:
                self.player?.pause()
                // 开始监听方法，暂停监听信号，原因是当程序后台运行时及延迟播放时需要不改变信号但执行方法
                playerPausePlaying()
                let image = UIImage.imageInBundle(named: "btn_play")
                controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
            case .stop:
                let image = UIImage.imageInBundle(named: "btn_play")
                controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
                controlView?.resetStatus()
            }
        }
    }

    // whether view is on full screen mode
    public var isFull: JHKPlayerFullScreenMode = .normal {
        didSet {
            if isFull == .normal {
                let image = UIImage.imageInBundle(named: "player_full")
                controlView?.fullOrSmallButton.setBackgroundImage(image, for: .normal)
                controlView?.definitionButton.removeFromSuperview()
                controlView?.bottomControlsArray.remove(self.controlView?.definitionButton)
                controlView?.moreButton.removeFromSuperview()
                controlView?.topControlsArray.remove(self.controlView?.moreButton)
                self.frame = originFrame!
                controlView?.setNeedsLayout()
            }
            else {
                let image = UIImage.imageInBundle(named: "player_shrink")
                controlView?.fullOrSmallButton.setBackgroundImage(image, for: .normal)
                controlView?.bottomControlsArray.add(self.controlView?.definitionButton)
                controlView?.topControlsArray.add(self.controlView?.moreButton)
                self.frame = (self.window?.bounds)!
                controlView?.setNeedsLayout()
            }
        }
    }

    public var fillMode: JHKPlayerContentFillMode = .normal

    // MARK: - delegate
    // player delegate for further use
    public weak var actionDelegate: JHKPlayerActionsDelegate?

    // MARK: - custom setting
    // Custom settings for appearance
    open var autoStart: Bool = true
    open var autoNext: Bool = true
    open var autoDismissMenu: Bool = true
    open var autoLandscape: Bool = UIDevice.current.userInterfaceIdiom == .phone
    open var hideStatusBarWhenFullScreen: Bool = true
    public var breakPoint: CGFloat?

    // MARK: - Core component
    // Lazy load AVPlayer as the core media player
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var playerAsset: AVURLAsset?
    private var snapshotGenerator: AVAssetImageGenerator?
    private var imageOutPut: AVPlayerItemOutput?

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
    fileprivate var link: CADisplayLink?
    public var localeTime: TimeInterval?
    // Monitoring playing call back
    fileprivate var playbackTimeObserver: Any?

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

    // Check if network is in lag
    public func checkLag() {
        let current: TimeInterval = CMTimeGetSeconds((player?.currentTime())!)
        // TODO: 比较条件逻辑未完全完成
        if current == localeTime {
            playerDelay(true)
        } else {
            playerDelay(false)
        }
        localeTime = current
    }

    // MARK: - Logical methods
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
    fileprivate func checkLocalFileExistsAtPath(_ url: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.absoluteString) == true {
            mediaURL = URL(fileURLWithPath: url.absoluteString)
        }
    }

    /// Set background color for all menus related to view player
    public func setMenuBackgroundColor(color: UIColor) {
        controlView?.menuContentColor = color
    }

    /// Function provide instance for side menu
    public func setMenuContent(view: UIView) {
        view.frame = (controlView?.sideMenu.bounds)!
        for view in (controlView?.sideMenu.subviews)! {
            view.removeFromSuperview()
        }
        controlView?.sideMenu.addSubview(view)
    }

    // MARK: - Manager methods
    // Remove Observers
    public func RemoveObservers() {
        if playbackTimeObserver != nil {
            player?.removeTimeObserver(playbackTimeObserver!)
            playbackTimeObserver = nil
        }
        if link != nil {
            link?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            link = nil
        }
        playerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: playerItem)
    }
    
    @objc fileprivate func orientChange(_ notification: NSNotification) {
        let orient = UIDevice.current.orientation
        self.deviceOrient(orient)
    }
    
    @objc fileprivate func playerFinishPlay(_ notification: NSNotification) {
        player?.seek(to: kCMTimeZero, completionHandler: { _ in
            self.playerFinishedPlay()
        })
    }
    
    @objc fileprivate func appDidEnterBackground() {
        if playState == .playing {
            playerPausePlaying()
        }
    }

    @objc fileprivate func appDidEnterForeground() {
        if playState == .playing {
            playerStartPlaying()
        }
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
    public convenience init(url: String) {
        self.init(frame: .zero)
        let urlFromString = URL(string: url)
        self.mediaURL = urlFromString
    }

    // Constructor for initWithNSCode, which required since swift2.1 when init() is override
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Destory observers while inallocation
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Successfully destory video player")
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
        JHKControlClosure()

        // Determined use local file or outside link
        checkLocalFileExistsAtPath(mediaURL!)
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
    }

    /// Add observes for player status and state value
    public func addObservers() {
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(orientChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerFinishPlay(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(JHKVideoPlayer.appDidEnterBackground), name: Notification.Name.UIApplicationWillResignActive, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: playerItem)
    }

    /// KVO responses. React immediately after playerItem status change and loading cache change.
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem = object as? AVPlayerItem
        if keyPath == "status" {
            if playerItem?.status == .readyToPlay {
                // Player successfully load the video, status readyToPlay
                let duration = CMTimeGetSeconds((playerItem?.duration)!)
                totalTime = CGFloat(duration)
                if autoStart {
                    playerStartPlaying()
                }
            } else {
                // Player fail to load the video, status unknown or fail
                playerFailToLoad()
            }
        } else if keyPath == "loadedTimeRanges" {
            let timeInterval = playerAvailableDuration()
            let duration = CMTimeGetSeconds((playerItem?.duration)!)
            loadedTime = CGFloat(timeInterval / duration)
        }
    }

    /// Call when video successfully loaded, anounced that player is ready to play.
    public func playerStartPlaying() {
        controlView?.loadingIndicator.stopAnimating()
        playState = .playing
        if playbackTimeObserver == nil {
            playbackTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil, using: { [weak self](time) in
                guard let sself = self else { return }
                let currentSecond = CGFloat((sself.playerItem?.currentTime().value)!) / CGFloat((sself.playerItem?.currentTime().timescale)!)
                sself.currentTime = currentSecond
                // TODO: 暂时使用的是传入断点的方式，若逻辑趋于复杂，可使用传出监听方式
                if sself.breakPoint != nil && currentSecond >= sself.breakPoint! {
                    sself.lockPlayer(with: "锁屏提示语", action: "超链接", handler: nil)
                }
                //self?.actionDelegate?.breakPointListener(time: currentSecond)
            })
        }
        if link == nil {
            link = CADisplayLink(target: self, selector: #selector(checkLag))
            link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        }
        actionDelegate?.startPlayingListener()
    }

    /// Call when video pause play, anounced that player is paused and.
    public func playerPausePlaying() {
        if playbackTimeObserver != nil {
            player?.removeTimeObserver(playbackTimeObserver!)
            playbackTimeObserver = nil
        }
        if link != nil {
            link?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            link = nil
        }
    }

    // Stop video player and deallocate
    public func playerStopPlaying() {
        UIApplication.shared.isIdleTimerDisabled = false
        RemoveObservers()
        playState = .stop
        player?.rate = 0
        player?.replaceCurrentItem(with: nil)
        playerItem = nil
        player = nil
    }

    /// Call when player fail to load resource, anounced that resource is not valid.
    private func playerFailToLoad() {
        playState = .stop
        controlView?.loadingIndicator.stopAnimating()
    }

    /// Call when player finished playing current video, anounced for further setting.
    private func playerFinishedPlay() {
        playState = .stop
        if autoNext {
            actionDelegate?.playNextAction()
        }
    }

    public func lockPlayer(with warning: String?, action: String?, handler: (() -> (Void))?) {
        playerStopPlaying()
        controlView?.setUpLockMask(message: warning!, button: action)
        controlView?.insertSubview((controlView?.lockMaskView)!, at: 0)

        controlView?.autoHiddenMenu = false
        controlView?.bottomBar.isUserInteractionEnabled = false
    }

    public func unlocakPlayer() {
        controlView?.lockMaskView.removeFromSuperview()

        controlView?.autoHiddenMenu = true
        controlView?.bottomBar.isUserInteractionEnabled = true
    }

    /// Orient change response
    private func deviceOrient(_ orient: UIDeviceOrientation) {
        if autoLandscape {
            if orient == .portrait {
                isFull = .normal
            } else if orient == .landscapeLeft || orient == .landscapeRight {
                isFull = .full
            }
        }
    }

    /// Delay player playing until checkLag return true
    private func playerDelay(_ flag: Bool) {
        if flag == true && playState == .stop {
            self.controlView?.loadingIndicator.startAnimating()
            playerPausePlaying()
        } else {
            self.controlView?.loadingIndicator.stopAnimating()
        }
    }

    // MARK: - Blocks, Implement closures for player controls
    open func JHKControlClosure() {

        // Processor changing closure
        JHKPlayerClosure.sliderValueChangeClosure = { [weak self] (time) in
            guard let sself = self else { return }
            sself.player?.seek(to: CMTime.init(seconds: Double(time), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            sself.currentTime = CGFloat(time)
            sself.playState = .pause
        }

        // Processor change end closure
        JHKPlayerClosure.sliderDragedClosure = { [weak self] in
            guard let sself = self else { return }
            sself.playerStartPlaying()
        }

        // Change mode of full screen or shrink screen
        JHKPlayerClosure.fullOrShrinkClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.isFull == .normal {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }

        // Change playing states closure
        JHKPlayerClosure.playOrPauseClosure = { [weak self] in
            guard let sself = self else { return }
            switch sself.playState {
            case .playing:
                sself.playState = .pause
            case .pause:
                sself.playerStartPlaying()
            case .stop:
                sself.initPlayer()
                print("Vidoe is on the loading")
            }
        }

        // Turn back button closure
        JHKPlayerClosure.turnBackClosure = { [weak self] in
            guard let sself = self else { return }
            sself.playerStopPlaying()
            sself.actionDelegate?.playerQuitAction()
        }

        // Play next button closure
        JHKPlayerClosure.playNextClosure = { [weak self] in
            guard let sself = self else { return }
            sself.actionDelegate?.playNextAction()
        }

        /// Play previous button closure
        JHKPlayerClosure.playPreviousClosure = { [weak self] in
            guard let sself = self else { return }
            sself.actionDelegate?.playPreviousAction()
        }

        /// Push screen button closure
        JHKPlayerClosure.pushScreenClosure = { [weak self] in
            guard let sself = self else { return }
            sself.actionDelegate?.pushScreenAction()
        }

        /// More info button closure
        JHKPlayerClosure.moreInfoClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.actionDelegate != nil {
                sself.setMenuContent(view: (sself.actionDelegate!.moreMenuAction()))
            }
        }

        /// Change definition closure
        JHKPlayerClosure.changeDefinitionClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.actionDelegate != nil {
                sself.setMenuContent(view: (sself.actionDelegate!.determinedDefinition()))
            }
        }

        /// Reset current time to schedule
        JHKPlayerClosure.scheduledPlayerClosure = { [weak self] (time) in
            guard let sself = self else { return }
            sself.player?.seek(to: CMTime.init(seconds: Double(time), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
    }
}

extension UIImage {
    /// Extension for determined specific Image resources in the bundle of CocoaPods Component
    ///
    /// - Parameter name: (String) - image name in bundle
    /// - Parameter bundle: (String) - bundle name in specific
    /// - Returns: image: UIImage
    /// - Warning: for internal use only
    /// - SeeAlso: `imageInBundle()`
    internal class func imageInBundle(named name: String, from bundle: String? = nil) -> UIImage? {
        let searchUrl = Bundle(for: JHKVideoPlayer.self).url(forResource: bundle ?? "JHKVideoPlayer", withExtension: "bundle")
        let bundleUrl = Bundle(url: searchUrl!)?.url(forResource: "JHKPlayerBundle", withExtension: "bundle")
        let bundle = Bundle(url: bundleUrl!)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
}
