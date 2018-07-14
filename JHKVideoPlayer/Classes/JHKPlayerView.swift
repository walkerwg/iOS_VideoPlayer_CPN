//
//  JHKPlayerView.swift
//  JHKVideoPlayer
//
//  This is the file storing [Views] for JHKVideoPlayer, [Gestures] is also defined on this mask but specific initializer would be accomplished with default [Closure] or open [Delegate].
//
//  Created by LuisGin on 17/2/9.
//  Copyright © 2017年 LuisGin. All rights reserved.
//

import UIKit
import MediaPlayer

let kScreenWidth = UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
let kScreenHeight = UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width
// 适配iPhoneX
let isIPhoneX = (kScreenWidth == 375.0 && kScreenHeight == 812.0 ? true : false)
let X_fullScreen : CGFloat = (isIPhoneX ? 34.0 : 0.0)
let kStatusBarHeight : CGFloat = (isIPhoneX ? 44.0 : 20.0)

/// The view components of JHKVideoPlayer, and can be expanded in further
///
/// - Author: Luis Gin
/// - Version: v0.1.1
open class JHKPlayerView: UIView, UITextViewDelegate {

    // MARK: - Signal
    /// Signal of whether hide all the menu
    public var isMenuHidden: Bool = false {
        didSet{
            for subView in subviews {
                if subView != loadingIndicator && subView != lockMaskView {
                    if subView.tag != 880221 {
                      subView.isHidden = isMenuHidden
                    }
                }
            }
            isSideMenuShow = false
        }
    }

    // Signal of gesture directions
    private var horizontalSignal: Bool = false
    private var gestureLeftSignal: Bool = false
    var sideMenuForDefinition: Bool?
    var isSideMenuShow: Bool = false {
        didSet {
            if isSideMenuShow {
                pushSideMenu()
            } else {
                hideSideMenu()
            }
        }
    }

    // MARK: - UIControls
    // Collect views into arrays to fit auto layout
    public var topControlsArray = NSMutableArray()
    public var bottomControlsArray = NSMutableArray()

    internal var menuContentColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.3) {
        didSet {
            for subView in subviews {
                subView.backgroundColor = menuContentColor
            }
        }
    }
    /// Top menu of player
    public lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = self.menuContentColor
        return view
    }()

    /// Bottom menu of player
    public lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = self.menuContentColor
        return view
    }()

    /// Side menu of player
    public lazy var sideMenu: UIView = {
        let view = UIView()
        view.backgroundColor = self.menuContentColor
        view.clipsToBounds = true
        return view
    }()

    /// Title label on top menu
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        return label
    }()

    /// Return button on top menu left side
    open lazy var returnButton: UIButton = {
        let button = UIButton()
        // TODO: 暂时设置半屏
        let imageNormal = UIImage.imageInBundle(named: "返回")
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "返回 按下")
        button.setBackgroundImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
        return button
    }()

    /// 在主屏幕上的返回按钮，总是显示的，如果topBar显示则它隐藏，否则显示
    open lazy var returnButtonHalfOnScreen: UIButton = {
        let button = UIButton()
        // TODO: 暂时设置半屏
        let imageNormal = UIImage.imageInBundle(named: "返回")
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "返回 按下")
        button.setBackgroundImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
        button.tag = 880221
        return button
    }()
    
    /// Push button on top menu right side
    open lazy var pushButton: UIButton = {
        let button = UIButton()
        button.setTitle("投屏", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.init("18bc84"), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //        button.layer.borderColor = UIColor.white.cgColor
        //        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(pushButtonAction), for: .touchUpInside)
        return button
    }()
    
    /// Push button on top menu right side
    open lazy var pushButtonHalf: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "pushScreen") // btn_pane  投屏
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(pushButtonAction), for: .touchUpInside)
        return button
    }()
    
//    /// More button on top menu right side
//    open lazy var moreButton: UIButton = {
//        let button = UIButton()
//        let image = UIImage.imageInBundle(named: "menu_more")
//        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        button.setBackgroundImage(image, for: .normal)
//        button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
//        return button
//    }()
    
    /// More button on top menu right side
    open lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("选课", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.init("18bc84"), for: .selected)
        button.setTitleColor(UIColor.init("18bc84"), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //        button.layer.borderColor = UIColor.white.cgColor
        //        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        return button
    }()
    
    /// More button on top menu right side
    open lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("分享", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.init("18bc84"), for: .selected)
        button.setTitleColor(UIColor.init("18bc84"), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //        button.layer.borderColor = UIColor.white.cgColor
        //        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
        return button
    }()

    /// Share button on top menu right side -- 小屏幕时的分享
    open lazy var shareButtonHalf: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "分享") // btn_pane  投屏
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "分享 按下") // btn_pane  投屏
        button.setBackgroundImage(imagePressDown, for: .highlighted)
 //       button.addTarget(self, action: #selector(pushButtonAction), for: .touchUpInside)
        button.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
        return button
    }()

    /// 分割线1
    open lazy var separaterLineView1: UIView = {
        let separaLine = UIView()
        separaLine.backgroundColor = UIColor.init("e7e8ed")
        separaLine.height = 8
        separaLine.width = 1
        
        return separaLine
    }()
    
    /// 分割线2
    open lazy var separaterLineView2: UIView = {
        let separaLine = UIView()
        separaLine.backgroundColor = UIColor.init("e7e8ed")
        separaLine.height = 8
        separaLine.width = 1
        
        return separaLine
    }()
    

    /// Time label for playing progress
    open lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textAlignment = .left
        return label
    }()

    /// Time label for total length
    open lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textAlignment = .right
        return label
    }()

    /// Load progressor
    open lazy var loadProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .cyan
        return progressView
    }()

    /// Playing slider
    open lazy var playSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let image = UIImage.imageInBundle(named: "player_slider")
        slider.setThumbImage(image, for: .normal)
        slider.setMaximumTrackImage(transparentImage, for: .normal)
        slider.setMinimumTrackImage(transparentImage, for: .normal)

        slider.addTarget(self, action: #selector(playSliderChanging(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(playSliderDraged(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(playSliderSeeked(_:)), for: .touchDown)
        return slider
    }()
    private var sliderGesture: UITapGestureRecognizer?

    /// Play or pause button
    open lazy var playOrPauseButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "播放")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(playOrPauseAction), for: .touchUpInside)
        return button
    }()
    
    /// Lock Play button 锁住播放屏幕
    open lazy var lockPlayScreenButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "解锁")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(lockPlayScreenAction), for: .touchUpInside)
        return button
    }()
    


    /// Previews video button on bottom mune
    // 上一集 下一集按钮 聚好学3.3版本暂时不使用了，先保留着
    open lazy var previewsButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "btn_previous")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(previewsAction), for: .touchUpInside)
        return button
    }()

    /// Next vidoe button on bottom menu
    // 上一集 下一集按钮 聚好学3.3版本暂时不使用了，先保留着
    open lazy var nextButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "btn_next")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()

    /// Full screen button
    open lazy var fullOrSmallButton: UIButton = {
        let button = UIButton()
        var image = UIImage.imageInBundle(named: "全屏")
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight { // 竖屏
            image = UIImage.imageInBundle(named: "缩小")
        }
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(fullOrShrinkAction), for: .touchUpInside)
        return button
    }()

    /// Indicator
    open lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()

    /// Drag hub
    open lazy var dragHud: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = self.menuContentColor
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    /// Drag label
    open lazy var dragLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = self.menuContentColor
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()

    /// Volume control
    open lazy var volumeControl: MPVolumeView = { [weak self] in
        let volumeView = MPVolumeView()
        for subview in volumeView.subviews {
            if subview.self.classForCoder.description() == "MPVolumeSlider" {
                self?.volumeViewSlider = subview as? UISlider
                break
            }
        }
        return volumeView
    }()
    open var volumeViewSlider: UISlider?
    
    /// Definion setting
    open lazy var definitionButton: UIButton = {
        let button = UIButton()
        button.setTitle("标清", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        button.layer.borderColor = UIColor.white.cgColor
//        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(changeDefinitionAction), for: .touchUpInside)
        return button
    }()

    open lazy var lockMaskView: UIView = { [weak self] in
        let view = UIView()
        // FIXME:
        view.backgroundColor = .black
        return view
    }()

    open lazy var lockMessageView: UITextView = {
        let label = UITextView()
        label.backgroundColor = .clear
        label.isEditable = false
        label.isSelectable = true
        label.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.cyan]
        label.delegate = self
        return label
    }()
    
    // 播放器界面上的 开通VIP会员按钮
    open lazy var openVIPBtn: UIButton = {
        let vipBtn = UIButton(type: .custom)
        vipBtn.frame = CGRect(x: 20, y: 40, width: 100, height: 30)
        vipBtn.center.x = lockMaskView.center.x
        vipBtn.backgroundColor = UIColor.clear
        vipBtn.setTitleColor(UIColor.init("18bc84"), for: .normal)
        vipBtn.setTitleColor(UIColor.init("18bc84"), for: .selected)
        vipBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        vipBtn.setTitle("开通会员", for: .normal)
        vipBtn.addTarget(self, action: #selector(openVIPButtonAction), for: .touchUpInside)
        return vipBtn
    }()

    public var isPlayerLocked : Bool = false  // 屏幕是否已经锁定 默认没有, false:没有锁定, true:已经锁定
    public var isPlayerScreenLocked : Bool = false  // 屏幕是否是锁定界面，播放时左侧的锁. false:没有，true：锁定
    open let TopBarHeightLandScape : CGFloat = 68  // 横屏时顶部菜单栏的高度

    // 锁屏响应链式表
    fileprivate var lockHandlerMap: Dictionary<String, (() -> Void)> = [:]
    // 事件代理与手势代理
    weak var internalDelegate: JHKInternalTransport?
    weak var customizeActionHandler: JHKPlayerActionsDelegate?
    weak var customizeGestureHandler: JHKPlayerGestureHandler?

// MARK: - Init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addAllViews()
        self.addGuestures()
    }

    init(delegate: JHKPlayerActionsDelegate?) {
        super.init(frame: .zero)
        customizeActionHandler = delegate
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if self.isHidden {
            print("播放器已经隐藏，不做任何处理 layoutSubviews")
            return
        }

        if isPlayerLocked && isPlayerScreenLocked  {
            print("屏幕已经锁定，不做任何处理 layoutSubviews")
            return
        }
        
        if isFullOrHalfScreen() == .normal { // 竖屏

            let fontSizeSmall : CGFloat = 14
            
            // 显示半屏所特有的
            pushButtonHalf.isHidden = false
            shareButtonHalf.isHidden = false
            pushButton.isHidden = true
            shareButton.isHidden = true
            separaterLineView1.isHidden = true
            separaterLineView2.isHidden = true
            definitionButton.isHidden = true
            totalTimeLabel.isHidden = true
//            returnButtonHalfOnScreen.isHidden = false
            // 暂时不加了
//            self.addSubview(returnButtonHalfOnScreen)
            lockPlayScreenButton.isHidden = true
            lockPlayScreenButton.removeFromSuperview()

            playOrPauseButton.removeFromSuperview()
            self.addSubview(playOrPauseButton)

            moreButton.removeFromSuperview()
            // 顶部导航栏
            topBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height / 8+3)
            returnButton.frame = CGRect(x: 12, y: 2, width: 26, height: 26)
            returnButtonHalfOnScreen.frame = CGRect(x: 12, y: 2, width: 26, height: 26)

            if topControlsArray.count > 0 {
                for i in 1...topControlsArray.count {
                    let view: UIView = topControlsArray[i - 1] as! UIView
                    topBar.addSubview(view)
                    view.frame = CGRect(x: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count - i) - topBar.frame.height, y: topBar.frame.height * 0.1, width: topBar.frame.height * 0.8, height: topBar.frame.height * 0.8)
                }
            }

            titleLabel.font = UIFont.systemFont(ofSize: fontSizeSmall)
            topBar.addSubview(titleLabel)
            topBar.addSubview(returnButton)

            shareButtonHalf.frame = CGRect(x: topBar.width - 36, y: 1, width: 26, height: 26)
            pushButtonHalf.frame = CGRect(x: topBar.width - 36 - 36, y: 1, width: 26, height: 26)

            var curWidth = kScreenWidth
            if kScreenWidth < kScreenHeight {
                curWidth = kScreenWidth
            }else {
                curWidth = kScreenHeight
            }

            titleLabel.frame = CGRect(x: returnButton.origin.x + returnButton.frame.size.width + 5, y: 0, width: curWidth - (returnButton.origin.x + returnButton.frame.size.width + 5) - (curWidth - (topBar.width - 36 - 36)) - 5, height: topBar.frame.height)

            // 底部导航栏
            bottomBar.frame = CGRect(x: 0, y: self.frame.height * 5 / 6 - 10, width: self.frame.width, height: self.frame.height / 6 + 10)
            playSlider.frame = CGRect(x: 0, y: bottomBar.frame.height - 4, width: bottomBar.frame.width, height: 10)
            let insetH: CGFloat = playSlider.frame.height
            loadProgressView.frame = CGRect(x: 0, y: bottomBar.frame.height, width: bottomBar.frame.width , height: insetH)

            currentTimeLabel.frame = CGRect(x: 8, y: bottomBar.frame.height - 18, width: 200, height: 14)
            currentTimeLabel.textColor = UIColor.init("e7e8ed")
            currentTimeLabel.textAlignment = .left
            playOrPauseButton.frame = CGRect(x: self.frame.width / 2, y: (self.frame.height) / 2, width: 48, height: 48)
            // 播放按钮，停止 播放  上一集/下一集
            playOrPauseButton.center = CGPoint(x: self.frame.width / 2, y: (self.frame.height) / 2)
            // 上一集 下一集按钮 聚好学3.3版本暂时不使用了，先保留着
            fullOrSmallButton.frame = CGRect(x: bottomBar.frame.width - 12 - 28, y: 10, width: 30, height: 30)

            openVIPBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            let strTitle = openVIPBtn.titleLabel?.text ?? ""
            let widthTemp = strTitle.ga_widthForComment(fontSize: 13, height: 28)
            openVIPBtn.frame = CGRect(x: 20, y: 55, width: widthTemp, height: 33)
//            // 清晰度切换
//            definitionButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 2 / 3, height: playOrPauseButton.frame.height * 2 / 5)
//            definitionButton.center = CGPoint(x: playOrPauseButton.center.x - playOrPauseButton.frame.width * 4.5, y: playOrPauseButton.center.y)
//            definitionButton.titleLabel!.font = UIFont.systemFont(ofSize: definitionButton.frame.height * 2 / 3)
        }else { // 全屏显示
            print("--屏幕状态----- 全屏")

            let fontSizeFull : CGFloat = 16

            // 隐藏半屏所特有的
            pushButtonHalf.isHidden = true
            shareButtonHalf.isHidden = true
            pushButton.isHidden = false
            shareButton.isHidden = false
            separaterLineView1.isHidden = false
            separaterLineView2.isHidden = false
            definitionButton.isHidden = false
            lockPlayScreenButton.isHidden = false
//            returnButtonHalfOnScreen.isHidden = true
//            self.addSubview(returnButtonHalfOnScreen)
            // 暂时不加了
//            returnButtonHalfOnScreen.removeFromSuperview()

            topBar.addSubview(moreButton)
            // 添加锁屏按钮
            self.addSubview(lockPlayScreenButton)

            // 顶部导航栏
            topBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: TopBarHeightLandScape)
            // TODO:  增添三元条件分支匹配最小值
            returnButton.frame = CGRect(x: 16 + X_fullScreen, y: 16, width: 30, height: 30)
            returnButtonHalfOnScreen.frame = CGRect(x: 16 + X_fullScreen, y: 18, width: 30, height: 30)
            if topControlsArray.count > 0 {
                for i in 1...topControlsArray.count {
                    let view: UIView = topControlsArray[i - 1] as! UIView
                    topBar.addSubview(view)
                    view.frame = CGRect(x: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count - i) - topBar.frame.height, y: topBar.frame.height * 0.1, width: topBar.frame.height * 0.8, height: topBar.frame.height * 0.8)
                }
            }

            titleLabel.font = UIFont.systemFont(ofSize: fontSizeFull)
            // 导航栏右侧
            moreButton.frame = CGRect(x: topBar.frame.width - 32 - 50 - X_fullScreen, y: 0, width: 50, height: topBar.frame.height)
            moreButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeFull)
            separaterLineView1.frame = CGRect(x: moreButton.origin.x - 6, y: 0, width: 1, height: 8)
            shareButton.frame = CGRect(x: separaterLineView1.origin.x - 50, y: 0, width: 50, height: topBar.frame.height)
            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeFull)
            separaterLineView2.frame = CGRect(x: shareButton.origin.x - 6, y: 0, width: 1, height: 8)
            pushButton.frame = CGRect(x: separaterLineView2.origin.x - 50, y: 0, width: 50, height: topBar.frame.height)
            pushButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeFull)
            
            returnButton.center.y = topBar.center.y
            moreButton.center.y = topBar.center.y
            shareButton.center.y = topBar.center.y
            separaterLineView1.center.y = topBar.center.y
            separaterLineView2.center.y = topBar.center.y

            var curWidth = kScreenWidth
            var curHeight = kScreenHeight
            if kScreenWidth < kScreenHeight {
                curWidth = kScreenWidth
                curHeight = kScreenHeight
            }else {
                curWidth = kScreenHeight
                curHeight = kScreenWidth
            }

            titleLabel.frame = CGRect(x: returnButton.origin.x + returnButton.frame.size.width + 8, y: 0, width: curWidth - (returnButton.origin.x + returnButton.frame.size.width + 15) - (curWidth - (separaterLineView2.origin.x - 50)) - 5, height: topBar.frame.height)
            
            // 底部导航栏
            bottomBar.frame = CGRect(x: 0, y: self.frame.height * 5 / 6 - 16, width: self.frame.width, height: self.frame.height / 6 + 16)
            // 进度条
            playSlider.frame = CGRect(x: 75 + X_fullScreen, y: bottomBar.height * 2.0 / 3, width: bottomBar.frame.width - 160 - 80 - 2*X_fullScreen, height: 10)
            let insetH: CGFloat = playSlider.frame.height
            loadProgressView.frame = CGRect(x: 75 + X_fullScreen, y: bottomBar.height * 2.0 / 3 + insetH / 2, width: bottomBar.frame.width - 160 - 80 - 2*X_fullScreen, height: insetH)
            // 时间指示器
            currentTimeLabel.frame = CGRect(x: 16 + X_fullScreen, y: insetH - 2, width: 55, height: 14)
            totalTimeLabel.isHidden = false
            totalTimeLabel.frame = CGRect(x: loadProgressView.origin.x + loadProgressView.size.width + 12, y: insetH - 2, width: 55, height: 14)
            currentTimeLabel.center.y = loadProgressView.center.y // bottomBar.size.height * 2.0 / 3
            totalTimeLabel.center.y = loadProgressView.center.y //bottomBar.size.height * 2.0 / 3
            currentTimeLabel.textColor = UIColor.init("e7e8ed")
            currentTimeLabel.textAlignment = .center
            totalTimeLabel.textColor = UIColor.init("e7e8ed")
            totalTimeLabel.textAlignment = .center
            
            // 清晰度切换
            definitionButton.frame = CGRect(x: totalTimeLabel.origin.x + totalTimeLabel.size.width + 5, y: 0, width: 36, height: 20)
            definitionButton.center.y = totalTimeLabel.center.y - 5

            // 设置全屏时字体大小
            currentTimeLabel.font = UIFont.systemFont(ofSize: fontSizeFull*2/3)
            totalTimeLabel.font = UIFont.systemFont(ofSize: fontSizeFull*2/3)
            definitionButton.titleLabel!.font = UIFont.systemFont(ofSize: fontSizeFull*3/2)
            
            playOrPauseButton.removeFromSuperview()
            bottomBar.addSubview(playOrPauseButton)
            playOrPauseButton.frame = CGRect(x: 5 + X_fullScreen, y: currentTimeLabel.origin.y - 60, width: 50, height: 50)
            // 全屏/半屏 切换
            fullOrSmallButton.frame = CGRect(x: bottomBar.size.width - 16 - 30 - X_fullScreen, y: -15, width: 30, height: 30)
            fullOrSmallButton.center.y = loadProgressView.center.y
            // 锁屏按钮
            lockPlayScreenButton.frame = CGRect(x: 16 + X_fullScreen, y: self.frame.height/2-10, width: 30, height: 30)

            openVIPBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            let strTitle = openVIPBtn.titleLabel?.text ?? ""
            let widthTemp = strTitle.ga_widthForComment(fontSize: 15, height: 30)
            openVIPBtn.frame = CGRect(x: 20, y: 45, width: widthTemp, height: 35)
            playOrPauseButton.isHidden = false
        }

        if isPlayerLocked && !isPlayerScreenLocked  {
            lockPlayScreenButton.isHidden = true
            playOrPauseButton.isHidden = true
            print("屏幕已经锁定，隐藏锁屏按钮")
        }

        for view in bottomControlsArray {
            bottomBar.addSubview(view as! UIView)
        }
        loadingIndicator.center = CGPoint(x: self.center.x, y: self.center.y)
        dragHud.frame = CGRect(x: 0, y: 0, width: self.frame.height / 5, height: self.frame.height / 5)
        dragHud.center = self.center
        dragLabel.frame = CGRect(x: 0, y: dragHud.frame.height, width: dragHud.frame.width, height: dragHud.frame.height * 2 / 5)
        dragLabel.font = UIFont.systemFont(ofSize: dragLabel.frame.height)
        volumeControl.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        // 锁定播放器界面时，显示控件
        let TextY : CGFloat = self.frame.size.height/2 - 30
        lockMaskView.frame = CGRect(x: 0, y: TextY, width: self.frame.width - 30, height: 70)
        lockMessageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 40)

        openVIPBtn.titleLabel?.sizeToFit()
        openVIPBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        openVIPBtn.center.x = lockMessageView.center.x
        lockMaskView.addSubview(openVIPBtn)

        lockMaskView.addSubview(lockMessageView)
    }

    open func addAllViews() {
        self.addSubview(topBar)
        topBar.addSubview(titleLabel)
        topBar.addSubview(returnButton)
        topBar.addSubview(shareButton)
        topBar.addSubview(shareButtonHalf)
        topBar.addSubview(pushButton)
        topBar.addSubview(moreButton)
        topBar.addSubview(pushButtonHalf)
        topBar.addSubview(separaterLineView1)
        topBar.addSubview(separaterLineView2)
        self.addSubview(bottomBar)
        bottomBar.addSubview(loadProgressView)
        bottomBar.addSubview(playSlider)
//        self.addSubview(playOrPauseButton)
        bottomBar.addSubview(fullOrSmallButton)
        bottomBar.addSubview(currentTimeLabel)
        bottomBar.addSubview(totalTimeLabel)
        dragHud.addSubview(dragLabel)
        self.addSubview(loadingIndicator)
        self.addSubview(returnButtonHalfOnScreen)
        loadingIndicator.startAnimating()
        // 上一集 下一集按钮 聚好学3.3版本暂时不使用了，先保留着
        //        bottomBar.addSubview(previewsButton)
        //        bottomBar.addSubview(nextButton)
        //        bottomBar.addSubview(pushButton)
    }
    // 获取客服电话信息
    func getJHKPhoneNumInfo() -> String {
        var jhkPhoneNumPrefix = "详询"
        var jhkPhoneNum = "详询400-085-6006"
        let dicValue = UserDefaults.standard.value(forKey: "H5SavedDataKey")
        if let dictLocal = dicValue as? NSMutableDictionary {
            if let phoneNumInfo = dictLocal.object(forKey: "KEY_ACCOUNT_BIND_PHONE") as? String {

                var tempStr = phoneNumInfo.replacingOccurrences(of:"[", with: "")
                tempStr = tempStr.replacingOccurrences(of:"]", with: "")
                tempStr = tempStr.replacingOccurrences(of:"【", with: "")
                tempStr = tempStr.replacingOccurrences(of:"】", with: "")
                jhkPhoneNum = "详询\(tempStr)"
            }
        }
        return jhkPhoneNum
    }

    /// Add all gestures to control view
    private func addGuestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector((customizeGestureHandler ?? self).tapGestureHandler))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.delegate = self

        sliderGesture = UITapGestureRecognizer(target: self, action: #selector((customizeGestureHandler ?? self).sliderGestureHandler))
        sliderGesture!.numberOfTapsRequired = 1
        sliderGesture!.numberOfTouchesRequired = 1
        sliderGesture!.delegate = self
        playSlider.addGestureRecognizer(sliderGesture!)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector((customizeGestureHandler ?? self).panGestureHandler))
        panGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
    }

// MARK: - First response action
    /// Play or Pause video
    @objc public func playOrPauseAction() {
        // 点击了播放暂停按钮：发送通知检查用户设备超限
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playOrPauseBTNNotify"), object: nil)
        if isPlayerLocked {
            print("playOrPauseAction Clicked")
            
            
            return
        }
        
        JHKPlayerClosure.playOrPauseClosure?()

    }
    
    @objc public func lockPlayScreenAction() {
        JHKPlayerClosure.lockPlayScreenClosure?()
    }

    @objc func fullOrShrinkAction() {
        internalDelegate?.fullOrShrinkAction()
        isSideMenuShow = false
    }

    @objc func returnButtonAction() {
        internalDelegate?.returnButtonAction()
    }
    
    @objc func openVIPButtonAction() {
        internalDelegate?.openVIPButtonAction()
    }

    /// Push to remote screen
    @objc public func pushButtonAction() {
        customizeActionHandler?.pushScreenAction()
    }

    /// More infomation action
    @objc public func moreButtonAction() {
        if sideMenuForDefinition == false {
            isSideMenuShow = !isSideMenuShow
        } else {
            sideMenuForDefinition = false
            isSideMenuShow = true
        }
        JHKPlayerClosure.moreInfoClosure?()
    }
    
    /// More infomation action
    @objc public func shareButtonAction() {
    print("点击了 shareButtonAction")
        if sideMenuForDefinition == false {
            isSideMenuShow = !isSideMenuShow
        } else {
            sideMenuForDefinition = false
            isSideMenuShow = true
        }
        sideMenuForDefinition = false
        isSideMenuShow = false
        
        
        JHKPlayerClosure.shareInfoClosure?()
    }

    /// Previews action
    @objc public func previewsAction() {
        isSideMenuShow = false
        customizeActionHandler?.playPreviousAction()
    }

    /// Next action
    @objc public func nextAction() {
        isSideMenuShow = false
        customizeActionHandler?.playPreviousAction()
    }

    /// Change definition
    @objc public func changeDefinitionAction() {
        if sideMenuForDefinition == true {
            isSideMenuShow = !isSideMenuShow
        } else {
            sideMenuForDefinition = true
            isSideMenuShow = true
        }
        JHKPlayerClosure.changeDefinitionClosure?()
    }

    /// Progressor changing
    @objc func playSliderChanging(_ sender: AnyObject) {
        let slider = sender as! UISlider
        internalDelegate?.sliderValueChange(value: slider.value)
    }

    /// Slider touch up inside,
    @objc func playSliderDraged(_ sender: AnyObject) {
        if internalDelegate?.autoHiddenMenu == true {
            self.perform(#selector(hideMenu), with: nil, afterDelay: 5)
        }
        for gesture in self.gestureRecognizers! {
            gesture.isEnabled = true
        }
        sliderGesture?.isEnabled = true
        JHKPlayerClosure.sliderDragedClosure?()
    }
    
    /// Slider touch down, only affect touch on the thumb instead of track rect
    @objc func playSliderSeeked(_ sender: AnyObject) {
        JHKPlayerView.self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideMenu), object: nil)
        for gesture in self.gestureRecognizers! {
            gesture.isEnabled = false
        }
        sliderGesture?.isEnabled = false
    }

// MARK: - Dependant functions
    /// Function to hide all subviews
    @objc public func hideMenu() {
        self.isMenuHidden = true
    }

    func isFullOrHalfScreen() -> JHKPlayerFullScreenMode {
        return (internalDelegate?.isFullScreen())!
    }
    
    /// Reset all status and clean view
    func resetStatus() {
        playSlider.setValue(0, animated: false)
        loadProgressView.setProgress(0, animated: false)
        currentTimeLabel.text = "00:00"
    }

    /// Function to push side menu to screen
    public func pushSideMenu() {
        if sideMenu.superview == nil {
            self.addSubview(sideMenu)
            setNeedsLayout()
        }
        sideMenu.frame = CGRect(x: kScreenHeight, y: self.topBar.frame.height, width: kScreenHeight * 2 / 5, height: kScreenWidth - self.topBar.frame.height - self.bottomBar.frame.height)
        UIView.animate(withDuration: 0.25, animations: {
            let q: CGFloat
            if self.sideMenuForDefinition! { q = 4 } else { q = 3 }
            self.sideMenu.frame = CGRect(x: kScreenHeight * q / 5, y: self.topBar.frame.height, width: kScreenHeight * 2 / 5, height: kScreenWidth - self.topBar.frame.height - self.bottomBar.frame.height)
        })
    }

    /// Function to hide side menu from screen
    private func hideSideMenu() {
        UIView.animate(withDuration: 0.25, animations: {
            self.sideMenu.frame = CGRect(x: kScreenHeight, y: self.topBar.frame.height, width: kScreenHeight * 2 / 5, height: kScreenWidth - self.topBar.frame.height - self.bottomBar.frame.height)
        })
    }

    /// Add control to components array
    ///
    /// - Parameter action: (String) - UIView which is inserted into menu
    /// - Parameter isTop: (Bool) - If True then add to top bar, otherwise add to bottom bar
    public func addAction(action: UIView, toTop isTop: Bool) {
        if isTop {
            topControlsArray.add(action)
        } else {
            bottomControlsArray.add(action)
        }
    }

    /// Lock player screen with message and extra actions.
    ///
    /// - Parameters:
    ///   - message: message display on ground
    ///   - actions: extra action followed message
    public func setUpLockMask(message: String, BTNName: String, actions: [LockAction] = []) {
        let normalAttrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10.0),  NSAttributedStringKey.foregroundColor : UIColor.white]
        let attributedString = NSMutableAttributedString(string: message, attributes: normalAttrs)
        var index = 0
        for act in actions {
            let hyperRange: NSRange = NSMakeRange(attributedString.length, act.title.length)
            attributedString.append(act.title)
            attributedString.addAttribute(NSAttributedStringKey.link, value: "hyperLink\(index)", range: hyperRange)
            lockHandlerMap.updateValue(act.handler ?? { print("No interaction implemented") }, forKey: "hyperLink\(index)")
            index += 1
        }
        
        // Paragraph attributes, alignment in center and insert line space
        let paragraphAttre = NSMutableParagraphStyle()
        paragraphAttre.lineSpacing = 10
        paragraphAttre.alignment = .center
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphAttre, range: NSMakeRange(0, attributedString.length))
        lockMessageView.attributedText = attributedString
//        lockMessageView.isUserInteractionEnabled = true
        openVIPBtn.setTitle(BTNName, for: .normal)
        if lockMessageView.attributedText.string == "抱歉，您的账号超过教育VIP权益绑定数量" {
//            openVIPBtn.setTitle(getJHKPhoneNumInfo(), for: .normal) // "详询400-085-6006"
            openVIPBtn.setTitleColor(UIColor.white, for: .normal)
            openVIPBtn.setTitleColor(UIColor.white, for: .selected)
        }else if lockMessageView.attributedText.string == "在非wifi环境下，继续观看会耗费流量" {
//            openVIPBtn.setTitle("继续观看", for: .normal)
            openVIPBtn.setTitleColor(UIColor.init("18bc84"), for: .normal)
            openVIPBtn.setTitleColor(UIColor.init("18bc84"), for: .selected)
        }else {
//            openVIPBtn.setTitle("开通会员", for: .normal)
            openVIPBtn.setTitleColor(UIColor.init("18bc84"), for: .normal)
            openVIPBtn.setTitleColor(UIColor.init("18bc84"), for: .selected)
        }
        lockMessageView.contentSizeToFit()
        if lockMaskView.superview != self {
            self.insertSubview(lockMaskView, at: 0)
        }
    }
}

extension JHKPlayerView {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString.hasPrefix("hyperLink") {
            if let interaction = lockHandlerMap[URL.absoluteString] {
                interaction()
            }
        } else {
            print("Unexpected url: \(URL.absoluteString)")
        }
        return false
    }
}

// MARK: - Gesture Handler
// PS: @objc protocol can't be extension as swift protocol, like 'extension JHKPlayerGestureHandler'
@objc extension JHKPlayerView: UIGestureRecognizerDelegate, JHKPlayerGestureHandler  {
    /// Discard gesture responser if touch event is trying to make state possible
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if internalDelegate?.autoHiddenMenu == true {
            JHKPlayerView.self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideMenu), object: nil)
            self.perform(#selector(hideMenu), with: nil, afterDelay: 5)
        }
        let startPoint = touch.location(in: self)
        let hitView = self.hitTest(startPoint, with: nil)
        if self == hitView {
            return true
        } else if gestureRecognizer is UITapGestureRecognizer {
            if playSlider == hitView || lockMaskView == hitView {
                return true
            }
        }
        return false
    }

    func tapGestureHandler(_ tap: UITapGestureRecognizer) {
        print("tapGestureHandler")

        if isPlayerLocked && !isPlayerScreenLocked {
            print("屏幕已经锁定，左侧锁屏 tapGestureHandler")
            return
        }
        if isPlayerLocked && isPlayerScreenLocked {
            print("屏幕已经锁定，不做任何处理 tapGestureHandler")
            lockPlayScreenButton.isHidden = !lockPlayScreenButton.isHidden
            return
        }

        if tap.numberOfTapsRequired == 1 {
            isMenuHidden = !isMenuHidden
        }
        else {
            internalDelegate?.fullOrShrinkAction()
        }
    }

    func sliderGestureHandler(_ slide: UITapGestureRecognizer) {
        if isPlayerLocked {
            print("屏幕已经锁定，不做任何处理 sliderGestureHandler")
            return
        }

        let touchPoint = slide.location(in: self.playSlider)
        let value = (playSlider.maximumValue - playSlider.minimumValue) * Float(touchPoint.x / playSlider.frame.size.width)
        JHKPlayerClosure.scheduledPlayerClosure?(value)
    }

    func panGestureHandler(_ pan: UIPanGestureRecognizer) {
        let startPoint: CGPoint = pan.location(in: self)
        let velocityPoint: CGPoint = pan.velocity(in: self)
        
        if isPlayerLocked {
            print("屏幕已经锁定，不做任何手势处理 panGestureHandler")
            return
        }

        // Pesponse pan gesture with different patern
        switch pan.state {
        // Input gesture signal when touch began
        case .began:
            // 开始拖动时隐藏播放暂停按钮
            if isFullOrHalfScreen() == .normal {
                playOrPauseButton.isHidden = true
            }
            JHKPlayerView.self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideMenu), object: nil)
            let x: CGFloat = fabs(velocityPoint.x)
            let y: CGFloat = fabs(velocityPoint.y)

            // if moved horizontal
            self.horizontalSignal = x > y
            // change gesture location signal to determine left operation and right operation
            self.gestureLeftSignal = startPoint.x < self.bounds.size.width / 2
            self.addSubview(dragHud)
        case .changed:
            if isFullOrHalfScreen() == .normal {
                playOrPauseButton.isHidden = true
            }
            let valueX: CGFloat = velocityPoint.x
            let valueY: CGFloat = velocityPoint.y
            if horizontalSignal {
                // calculate movement
                var newValue = playSlider.value + Float(valueX) / 100
                if newValue > playSlider.maximumValue {
                    newValue = playSlider.maximumValue
                } else if newValue < 0 {
                    newValue = 0
                }
                // do horizontal action
                if valueX > 0 {
                    let image = UIImage.imageInBundle(named: "btn_forward")
                    dragHud.image = image
                } else {
                    let image = UIImage.imageInBundle(named: "btn_backward")
                    dragHud.image = image
                }
                dragLabel.text = currentTimeLabel.text
                playSlider.value = newValue
                internalDelegate?.sliderValueChange(value: newValue)
            } else if gestureLeftSignal {
                // do left gesture action
                let image = UIImage.imageInBundle(named: "icon_brightness")
                dragHud.image = image
                UIScreen.main.brightness -= valueY / 10000
                dragLabel.text = String(format: "%.0f%%", (UIScreen.main.brightness * 100))
            } else {
                // do right gesture action
                dragHud.image = UIImage.imageInBundle(named: "icon_sound")
                volumeViewSlider?.value -= Float(valueY) / 10000
                dragLabel.text = String(format: "%.0f%%", ((volumeViewSlider?.value)! * 100))
            }
        case .ended:
            if self.topBar.isHidden == false {
                self.playOrPauseButton.isHidden = false
            }else {
                self.playOrPauseButton.isHidden = true
            }
            if internalDelegate?.autoHiddenMenu == true {
                self.perform(#selector(hideMenu), with: nil, afterDelay: 5)
            }
            // 移动结束也需要判断垂直或者平移，比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            if horizontalSignal {
                JHKPlayerClosure.sliderDragedClosure?()
            }
            dragHud.removeFromSuperview()
        default: break
        }
    }
}

//  UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
// 计算文字高度或者宽度与weight参数无关
extension String {
    func ga_widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(rect.width)
    }
}

//extension UIColor{
//    
//    convenience init(_ hexColor: String) {
//        
//        // 存储转换后的数值
//        var red:UInt32 = 0, green:UInt32 = 0, blue:UInt32 = 0
//        
//        // 分别转换进行转换
//        Scanner(string: hexColor[0..<2]).scanHexInt32(&red)
//        
//        Scanner(string: hexColor[2..<4]).scanHexInt32(&green)
//        
//        Scanner(string: hexColor[4..<6]).scanHexInt32(&blue)
//        
//        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
//    }
//}
//
//extension String {
//    
//    /// String使用下标截取字符串
//    /// 例: "示例字符串"[0..<2] 结果是 "示例"
//    public subscript (r: Range<Int>) -> String {
//        get {
//            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
//            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
//            
//            return self[startIndex..<endIndex]
//        }
//    }
//}

