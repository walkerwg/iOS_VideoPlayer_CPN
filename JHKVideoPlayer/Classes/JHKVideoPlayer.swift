//
//  JHKVideoPlayer.swift
//  JHKVideoPlayer
//
//  This is the core Swift file for JHKVideoPlayer, containing logical methods and structure functions.
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

/// Enums for lock status
public enum JHKVideoPlayerLockState: Int {
    case notLocked = 0
    case locked
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
open class JHKVideoPlayer: UIView, JHKInternalTransport {

    // MARK: - Status signal
    /// Status for video player
    ///
    /// - Default: default value as JHKVideoPlayerState.stop
    /// - SeeAlso: JHKVideoPlayerState
    public var playState: JHKVideoPlayerState = .stop {
        didSet {
            switch playState {
            case .playing:
                self.player?.play()
                let imageNormal = UIImage.imageInBundle(named: "暂停")
                controlView?.playOrPauseButton.setBackgroundImage(imageNormal, for: .normal)
                let imagePressDown = UIImage.imageInBundle(named: "暂停 按下")
                controlView?.playOrPauseButton.setBackgroundImage(imagePressDown, for: .highlighted)
            case .pause:
                self.player?.pause()
                // 开始监听方法，暂停监听信号，原因是当程序后台运行时及延迟播放时需要不改变信号但执行方法
                playerPausePlaying()
                let imageNormal = UIImage.imageInBundle(named: "播放")
                controlView?.playOrPauseButton.setBackgroundImage(imageNormal, for: .normal)
                let imagePressDown = UIImage.imageInBundle(named: "播放 按下")
                controlView?.playOrPauseButton.setBackgroundImage(imagePressDown, for: .highlighted)
            case .stop:
                let imageNormal = UIImage.imageInBundle(named: "播放")
                controlView?.playOrPauseButton.setBackgroundImage(imageNormal, for: .normal)
                let imagePressDown = UIImage.imageInBundle(named: "播放 按下")
                controlView?.playOrPauseButton.setBackgroundImage(imagePressDown, for: .highlighted)
                controlView?.resetStatus()
            }
        }
    }

    public var playLockState: JHKVideoPlayerLockState = .notLocked {
        didSet {
            switch playLockState {
            case .notLocked:
                print("锁屏状态：没有锁")
                controlView?.topBar.isHidden = false
                controlView?.bottomBar.isHidden = false
                controlView?.playOrPauseButton.isHidden = false
                
                controlView?.isPlayerLocked = false
                controlView?.isPlayerScreenLocked = false
                controlView?.bottomBar.isUserInteractionEnabled = true
                let imageNormal = UIImage.imageInBundle(named: "解锁")
                controlView?.lockPlayScreenButton.setBackgroundImage(imageNormal, for: .normal)
                // 允许点击开通会员按钮
                self.controlView?.lockMessageView.isUserInteractionEnabled = true
                // 已经解锁锁屏，屏幕可以任意旋转
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setValuesInterfaceOrientationMaskNoti"), object: "3")

            case .locked:
                print("锁屏状态：锁屏")
                // 屏蔽界面所有操作
                controlView?.topBar.isHidden = true
                controlView?.bottomBar.isHidden = true
                controlView?.playOrPauseButton.isHidden = true
                controlView?.isSideMenuShow = false
                controlView?.isPlayerLocked = true
                controlView?.isPlayerScreenLocked = true
                controlView?.bottomBar.isUserInteractionEnabled = false
                
                let imageNormal = UIImage.imageInBundle(named: "锁定")
                controlView?.lockPlayScreenButton.setBackgroundImage(imageNormal, for: .normal)
                // 不允许点击开通会员按钮
                self.controlView?.lockMessageView.isUserInteractionEnabled = false
                // 已经锁屏，屏幕只允许横向全屏
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setValuesInterfaceOrientationMaskNoti"), object: "2")

            }
        }
    }
    
    /// Whether view is on full screen mode
    /// - Default: default value as JHKPlayerFullScreenMode.normal
    public var isFull: JHKPlayerFullScreenMode = .normal {
        didSet {
            if isFull == .normal { // 小屏幕时
                // 放大全屏按钮
                let imageNormal = UIImage.imageInBundle(named: "全屏")
                controlView?.fullOrSmallButton.setBackgroundImage(imageNormal, for: .normal)
                let imagePressDown = UIImage.imageInBundle(named: "全屏 按下")
                controlView?.fullOrSmallButton.setBackgroundImage(imagePressDown, for: .highlighted)
//                // 暂停按钮
//                let image = UIImage.imageInBundle(named: "btn_pause")
//                controlView?.playOrPauseButton.setBackgroundImage(image, for: .normal)
                // 返回退出按钮
                let imageNormal_Back = UIImage.imageInBundle(named: "返回")
                controlView?.returnButton.setBackgroundImage(imageNormal_Back, for: .normal)
                let imagePressDown_Back = UIImage.imageInBundle(named: "返回 按下")
                controlView?.returnButton.setBackgroundImage(imagePressDown_Back, for: .highlighted)

                controlView?.definitionButton.removeFromSuperview()
                controlView?.bottomControlsArray.remove(self.controlView!.definitionButton)
//                controlView?.moreButton.removeFromSuperview()
//                controlView?.pushButton.removeFromSuperview()
                controlView?.topControlsArray.remove(self.controlView!.moreButton)
                if originFrame != nil {
                    self.frame = originFrame!
                }
                controlView?.setNeedsLayout()
            }
            else {// 全屏时
                // 缩小至小屏幕按钮
                let imageNormal = UIImage.imageInBundle(named: "缩小")
                controlView?.fullOrSmallButton.setBackgroundImage(imageNormal, for: .normal)
                let imagePressDown = UIImage.imageInBundle(named: "缩小 按下")
                controlView?.fullOrSmallButton.setBackgroundImage(imagePressDown, for: .highlighted)
                // 返回退出按钮
                let imageNormal_Back = UIImage.imageInBundle(named: "返回")
                controlView?.returnButton.setBackgroundImage(imageNormal_Back, for: .normal)
                let imagePressDown_Back = UIImage.imageInBundle(named: "返回 按下")
                controlView?.returnButton.setBackgroundImage(imagePressDown_Back, for: .highlighted)

                // 位于主屏幕上的按钮
                let imageNormal_BackScreen = UIImage.imageInBundle(named: "返回")
                controlView?.returnButtonHalfOnScreen.setBackgroundImage(imageNormal_BackScreen, for: .normal)
                let imagePressDown_BackScreen = UIImage.imageInBundle(named: "返回 按下")
                controlView?.returnButtonHalfOnScreen.setBackgroundImage(imagePressDown_BackScreen, for: .highlighted)
                controlView?.bottomControlsArray.add(self.controlView!.definitionButton)
//                controlView?.topControlsArray.add(self.controlView!.moreButton)
//                controlView?.topControlsArray.add(self.controlView!.pushButton)
                originFrame = self.frame
                if self.window != nil {
                    self.frame = self.window!.bounds
                } else {
                    self.frame = UIScreen.main.bounds
                }
                controlView?.setNeedsLayout()
            }
        }
    }
    
    // Content fill mode, default is normal
    public var fillMode: JHKPlayerContentFillMode = .normal

    // MARK: - delegate
    // player delegate for further use
    public weak var actionDelegate: JHKPlayerActionsDelegate?

    // MARK: - custom setting
    // Custom settings for appearance
    open var autoStart: Bool = true
    open var autoNext: Bool = true
    open var autoHiddenMenu: Bool = true
    open var autoLandscape: Bool = UIDevice.current.userInterfaceIdiom == .phone

    // MARK: - Core component
    // Lazy load AVPlayer as the core media player
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var playerAsset: AVURLAsset?
    private var snapshotGenerator: AVAssetImageGenerator?
    private var imageOutPut: AVPlayerItemOutput?

    // Control Menu
    open var controlView: JHKPlayerView?

    // MARK: - Data
    // Origin frame
    fileprivate var originFrame: CGRect?
    
    // Title description
    public var videoTitle: String? {
        didSet {
            controlView?.titleLabel.text = videoTitle ?? ""
        }
    }
    
    // 清晰度按钮名字设置
    public var definitBTNTitle: String? {
        didSet {
            controlView?.definitionButton.setTitle(definitBTNTitle ?? "标清", for: .normal)
        }
    }
    
    // Loaded video length
    public var loadedTime: CGFloat? {
        didSet {
            guard let loadedTime = loadedTime else { return }
            controlView?.loadProgressView.setProgress(Float(loadedTime), animated: true)
        }
    }

    // Title description
    public var playRate: Float? {
        didSet {
            if #available(iOS 10.0, *) {
                player?.automaticallyWaitsToMinimizeStalling = false
            } else {
                // Fallback on earlier versions
            }
            player?.rate = playRate!
            print("播放速率: \(player?.rate)")
            print(player?.rate)
            print(playRate!)
        }
    }

    // Played video length
    public var currentTime: CGFloat? {
        didSet {
            guard let currentTime = currentTime else { return }
            controlView?.playSlider.setValue(Float(currentTime), animated: true)
            let timeCurrent :String = formatTimer(currentTime)
            if isFull == .full {
                controlView?.currentTimeLabel.text = "\(timeCurrent)" // "23:23:59"//
            }else {
                guard let totalTime = totalTime else { return }
                let timeTotal = formatTimer(totalTime)
                controlView?.currentTimeLabel.text = "\(timeCurrent)/\(timeTotal)"
            }
            
        }
    }
    public var startPoint: CGFloat?

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
            // add by wjw
            self.controlView?.loadingIndicator.startAnimating()
            setPlayOrPauseBtnStatus(IsShowAnimate: true)
        }
    }
    // Interaction with system flush interval
    fileprivate var link: CADisplayLink?
    public var localeTime: TimeInterval?
    // Monitoring playing call back
    fileprivate var playbackTimeObserver: Any?
    
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
    @objc public func checkLag() {
        
        var current : TimeInterval = 0
        if let cTim = (player?.currentTime()) {
            current = CMTimeGetSeconds(cTim)
        }

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
        let startSeconds = CMTimeGetSeconds((timeRange?.start) ?? CMTimeMake(0, 0))
        let durationSeconds = CMTimeGetSeconds((timeRange?.duration) ?? CMTimeMake(0, 0))
        let result = startSeconds + durationSeconds
        return result
    }

    // Judge if there is any local file loaded
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

        // Set audio display category
        // TODO: 本设置将使播放器不随系统静音而静音
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
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
        print("***Successfully destory video player***")
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
            controlView?.customizeActionHandler = actionDelegate
            controlView?.internalDelegate = self
            self.addSubview(controlView!)
        }
        JHKControlClosure()

        if mediaURL == nil {
            mediaURL = URL.init(string: "https://xxxxx.mp4")
            print("Error: mediaURL为nil")
        }
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
    func addObservers() {

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
            guard playerItem?.duration != nil else { return }
            guard player?.currentItem?.loadedTimeRanges.count != nil, player?.currentItem?.loadedTimeRanges.count != 0 else { return }
            let timeInterval = playerAvailableDuration()
            let duration = CMTimeGetSeconds((playerItem?.duration)!)
            loadedTime = CGFloat(timeInterval / duration)
//            print("override open func observeValue(forKeyPath keyPath: String?, of")
//            print("\(timeInterval) -- \(duration) -- \(loadedTime) -- \(self.currentTime) -- \(self.totalTime) --- \(self.playerItem)")
//            if self.currentTime==nil {
//                self.currentTime = 0
//            }
//            if Int(self.currentTime!) >= 60  { //self.totalTime
//                playerFinishedPlay()
////                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlayNextVideoJumpADNotify"), object: nil)
//            }
        }
    }

    /// Call when video successfully loaded, anounced that player is ready to play.
    public func playerStartPlaying() {
        controlView?.loadingIndicator.stopAnimating()
        setPlayOrPauseBtnStatus(IsShowAnimate: false)
        playState = .playing
        if playbackTimeObserver == nil {
            playbackTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil, using: {
                [weak self] time in
                guard let sself = self else { return }
                
                // Bug: SSOFEDU-3390
                var currentSecond : CGFloat = 0
                if let timeItem = sself.playerItem?.currentTime() {
                    currentSecond = CGFloat(timeItem.value) / CGFloat(timeItem.timescale)
                }
//                let currentSecond = CGFloat((sself.playerItem?.currentTime().value)!) / CGFloat((sself.playerItem?.currentTime().timescale)!)

                sself.currentTime = currentSecond
                self?.actionDelegate?.breakPointListener(time: currentSecond)
            })
            if startPoint != nil {
                player?.seek(to: CMTime(seconds: Double(startPoint!), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
                startPoint = nil
            }
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
        controlView?.loadingIndicator.stopAnimating()
        setPlayOrPauseBtnStatus(IsShowAnimate: false)
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
        self.actionDelegate?.failLoadListener()
        controlView?.loadingIndicator.stopAnimating()
        setPlayOrPauseBtnStatus(IsShowAnimate: false)
    }

    /// Call when player finished playing current video, anounced for further setting.
    private func playerFinishedPlay() {
        playState = .stop
        if autoNext {
            actionDelegate?.playNextAction()
        }
    }

    public func lockPlayer(with warning: String, buttonName: String = "", isStopPlaying: Bool, actions: [LockAction] = []) {
        if isStopPlaying {
            playerStopPlaying()
        }else {
            playerPausePlaying()
        }
        controlView?.setUpLockMask(message: warning, BTNName: buttonName, actions: actions)
        autoHiddenMenu = false
        controlView?.bottomBar.isUserInteractionEnabled = false
        // add by wjw
        self.controlView?.loadingIndicator.stopAnimating()
        setPlayOrPauseBtnStatus(IsShowAnimate: false)
    }

    public func unlocakPlayer() {
        controlView?.lockMaskView.removeFromSuperview()
        autoHiddenMenu = true
        controlView?.bottomBar.isUserInteractionEnabled = true
    }

    public func removeLocakPlayer() {
        controlView?.lockMaskView.removeFromSuperview()
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
            setPlayOrPauseBtnStatus(IsShowAnimate: true)
            playerPausePlaying()
        } else {
            self.controlView?.loadingIndicator.stopAnimating()
            setPlayOrPauseBtnStatus(IsShowAnimate: false)
        }
    }

    // MARK: - Blocks, Implement closures for player controls
    open func JHKControlClosure() {

        // Processor change end closure
        JHKPlayerClosure.sliderDragedClosure = { [weak self] in
            guard let sself = self else { return }
            sself.playerStartPlaying()
        }

        // Change playing states closure
        JHKPlayerClosure.playOrPauseClosure = { [weak self] in
            guard let sself = self else { return }
            switch sself.playState {
            case .playing:
                sself.playState = .pause
                sself.actionDelegate?.playPauseAction()
            case .pause:
                sself.playerStartPlaying()
            case .stop:
                if isScreenLocked() {
                    return
                }

                sself.initPlayer()
                print("Vidoe is on the loading")
            }
        }
        func isScreenLocked() -> Bool {
            var playerLockedType = "0"
            if let lockType = UserDefaults.standard.object(forKey: "keyLockPlayerType") as? String {
                playerLockedType = lockType
            }
            if  playerLockedType == "overDeviceCount" || playerLockedType == "forOpenVIP" || playerLockedType == "forLastVideo" {
                print("屏幕锁定: \(playerLockedType), 点击播放器按钮不做反应")
                return true
            }
            return false
        }

        // Change playing states closure
        JHKPlayerClosure.lockPlayScreenClosure = { [weak self] in
            guard let sself = self else { return }
            switch sself.playLockState {
            case .notLocked:
                sself.playLockState = .locked
                sself.controlView?.isPlayerLocked = true

            case .locked:
                sself.playLockState = .notLocked
                sself.controlView?.isPlayerLocked = false
            }
        }

        /// More info button closure
        JHKPlayerClosure.moreInfoClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.actionDelegate != nil {
                sself.setMenuContent(view: (sself.actionDelegate!.moreMenuAction()))
            }
        }

        /// Share info button closure
        JHKPlayerClosure.shareInfoClosure = { [weak self] in
            guard let sself = self else { return }
            if sself.actionDelegate != nil {
                sself.actionDelegate?.shareAction()
                
                if self?.isFull == .full {
                    // 点击分享按钮时，如果是全屏状态，则退出全屏
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }

//                dPrint("弹窗分享窗口")
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

// Protocol JHKInternalTransport
extension JHKVideoPlayer {
    func sliderValueChange(value: Float) {
        // Processor changing closure
        self.player?.seek(to: CMTime.init(seconds: Double(value), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        self.currentTime = CGFloat(value)
        self.playState = .pause
    }

    // Change mode of full screen or shrink screen
    func fullOrShrinkAction() {
        var realWidth =  UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
        var realHeight = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        if self.isFull == .normal {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: realHeight, height: realWidth))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            let rect = CGRect(origin: CGPoint(x: 0, y: kStatusBarHeight), size: CGSize(width: realWidth, height: realHeight))
        }
    }

    // Turn back button closure
    func returnButtonAction() {
        if self.isFull == .normal {
            self.playerStopPlaying()
        }
        self.actionDelegate?.playerQuitAction()
    }
    
    func openVIPButtonAction() {
        if self.playLockState != .locked {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openVIPMemberBtnClickedNoti"), object: controlView?.openVIPBtn.titleLabel?.text)
        }
    }
    
    func isFullScreen() -> JHKPlayerFullScreenMode {
        return isFull
    }
    func setPlayOrPauseBtnStatus(IsShowAnimate: Bool) {
        if IsShowAnimate { // 转圈动画显示的时候，播放按钮不显示
            if controlView?.topBar.isHidden == false {
                controlView?.playOrPauseButton.isHidden = true
            }
        }else {
            if controlView?.topBar.isHidden == false {
                controlView?.playOrPauseButton.isHidden = false
            }
        }
    }
}
