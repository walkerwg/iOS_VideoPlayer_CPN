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
                if subView != loadingIndicator && subView != lockMaskView{
                    if subView.tag != 880221 && subView.tag != 100100 {
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
    internal var clearColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
    
    internal static var sliderMinColor = UIColor(red: 25/255.0, green: 207/255.0, blue: 141/255.0, alpha: 1)
    
    internal static var sliderMaxColor = UIColor.white
    
    internal var dragHudColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.7)

    /// Top menu of player
    public lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = self.menuContentColor
        let color1 = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.8)
        let color2 = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
        view.gradientColor(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), [color1.cgColor, color2.cgColor])
        return view
    }()

    /// Bottom menu of player
    public lazy var bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = self.menuContentColor
        let color1 = UIColor(red: 255/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0)
        let color2 = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.8)
        view.gradientColor(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), [color1.cgColor, color2.cgColor])
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
        let imageNormal = UIImage.imageInBundle(named: "Player_返回")
        button.setImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_返回按下")
        button.setImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsetsMake(-12, 0, 0, 0) //为了topbar排控件对齐
        return button
    }()

    /// 在主屏幕上的返回按钮，总是显示的，如果topBar显示则它隐藏，否则显示
    open lazy var returnButtonHalfOnScreen: UIButton = {
        let button = UIButton()
        // TODO: 暂时设置半屏
        let imageNormal = UIImage.imageInBundle(named: "Player_返回")
        button.setImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_返回按下")
        button.setImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
        button.tag = 880221
        button.imageEdgeInsets = UIEdgeInsetsMake(-12, 0, 0, 0) //为了topbar排控件对齐
        return button
    }()
    
    /// Download button on top menu right side
    open lazy var downloadButton: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_下载")
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_下载按下")
        button.setBackgroundImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        return button
    }()
    
    /// Push button on top menu right side
    open lazy var pushButton: UIButton = {
        let button = UIButton()
//        button.setTitle("投屏", for: .normal)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.setTitleColor(UIColor.init("18bc84"), for: .selected)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //        button.layer.borderColor = UIColor.white.cgColor
        //        button.layer.borderWidth = 1
        let imageNormal = UIImage.imageInBundle(named: "Player_投屏")
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_投屏按下")
        button.setBackgroundImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(pushButtonAction), for: .touchUpInside)
        return button
    }()
    
    /// Push button on top menu right side
    open lazy var pushButtonHalf: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_投屏")
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_投屏按下")
        button.setBackgroundImage(imagePressDown, for: .highlighted)
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
        button.setTitle("目录", for: .normal)
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
//        button.setTitle("分享", for: .normal)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.setTitleColor(UIColor.init("18bc84"), for: .selected)
//        button.setTitleColor(UIColor.init("18bc84"), for: .highlighted)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
        //        button.layer.borderColor = UIColor.white.cgColor
        //        button.layer.borderWidth = 1
        let imageNormal = UIImage.imageInBundle(named: "Player_分享")
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_分享按下")
        button.setBackgroundImage(imagePressDown, for: .highlighted)
        button.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
        return button
    }()

    /// Share button on top menu right side -- 小屏幕时的分享
    open lazy var shareButtonHalf: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_分享") // btn_pane  投屏
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_分享按下") // btn_pane  投屏
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
        label.font = UIFont.systemFont(ofSize: 10.0)
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
        progressView.progressTintColor =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue:255.0/255.0, alpha: 0.8)
        progressView.trackTintColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue:255.0/255.0, alpha: 0.4)
        progressView.progress = 0.0
        return progressView
    }()

    /// Playing slider
    open lazy var playSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        //wg:
        slider.setThumbImage(UIImage.imageInBundle(named: "player_slider"), for: .normal)
        slider.minimumTrackTintColor = JHKPlayerView.sliderMinColor
        slider.maximumTrackTintColor = UIColor.clear
        slider.addTarget(self, action: #selector(playSliderChanging(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(playSliderDraged(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(playSliderSeeked(_:)), for: .touchDown)
        return slider
    }()
    private var sliderGesture: UITapGestureRecognizer?

    /// Play or pause button
    open lazy var playOrPauseButton: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_播放") // btn_pane  投屏
        button.setBackgroundImage(imageNormal, for: .normal)
        button.addTarget(self, action: #selector(playOrPauseAction), for: .touchUpInside)
        return button
    }()
    
    /// Lock Play button 锁住播放屏幕
    open lazy var lockPlayScreenButton: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_解锁") // btn_pane  投屏
        button.setBackgroundImage(imageNormal, for: .normal)
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
    open lazy var nextButton: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_下一集") // btn_pane  投屏
        button.setBackgroundImage(imageNormal, for: .normal)

        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()

    /// Full screen button
    open lazy var fullOrSmallButton: UIButton = {
        let button = UIButton()
        let imageNormal = UIImage.imageInBundle(named: "Player_全屏") // btn_pane  投屏
        button.setBackgroundImage(imageNormal, for: .normal)
        let imagePressDown = UIImage.imageInBundle(named: "Player_全屏按下") // btn_pane  投屏
        button.setBackgroundImage(imagePressDown, for: .highlighted)
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
        imageView.backgroundColor = self.dragHudColor
        imageView.layer.cornerRadius = 6
        return imageView
    }()
    
    /// Drag label
    open lazy var dragLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = self.dragHudColor
        label.textColor = UIColor.white
        label.layer.cornerRadius = 6
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
        let fontSizeSmall : CGFloat = 14
        let imgWidth: CGFloat = 20.0
        var imgHorizontalSpace: CGFloat = 24 * kScreenWidth/375.0
        var space: CGFloat = 12.0
        let returnButtonTop: CGFloat = 28.0;
        let titleLableHeight : CGFloat = 18.0;
        let returnButtonHeight : CGFloat = 15.0;
        let returnButtonWidth : CGFloat = 15.0;
        
        let bottomBarHeightScale: CGFloat = 0.187
        let bottomBarHeight: CGFloat = self.frame.height * bottomBarHeightScale
        let playOrPauseButtonTop: CGFloat = 16.0
        let playOrPauseButtonWidth: CGFloat = 16.0
        let currentTimeLabelWidth: CGFloat = 80.0
        if isFullOrHalfScreen() == .normal { // 竖屏

            // 显示半屏所特有的
            pushButtonHalf.isHidden = false
            shareButtonHalf.isHidden = false
            pushButton.isHidden = true
            shareButton.isHidden = true
            separaterLineView1.isHidden = true
            separaterLineView2.isHidden = true
            definitionButton.isHidden = true
            totalTimeLabel.isHidden = true
            moreButton.isHidden = true
            fullOrSmallButton.isHidden = false
            titleLabel.isHidden = true

            returnButtonHalfOnScreen.isHidden = false
            // 暂时不加了
            lockPlayScreenButton.isHidden = true
            lockPlayScreenButton.removeFromSuperview()
            nextButton.isHidden = true
//
//            playOrPauseButton.removeFromSuperview()
//            self.addSubview(playOrPauseButton)

//            moreButton.removeFromSuperview()
            // 顶部导航栏
            topBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height / 4)
            returnButton.frame = CGRect(x: space, y: returnButtonTop - 2, width: returnButtonWidth * 2, height: returnButtonHeight * 2)
            returnButtonHalfOnScreen.frame = CGRect(x: space, y: returnButton.frame.minY, width: returnButton.frame.size.width, height: returnButton.frame.size.height)

            if topControlsArray.count > 0 {
                for i in 1...topControlsArray.count {
                    let view: UIView = topControlsArray[i - 1] as! UIView
                    topBar.addSubview(view)
                    view.frame = CGRect(x: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count - i) - topBar.frame.height, y: topBar.frame.height * 0.5, width: topBar.frame.height * 0.8, height: topBar.frame.height * 0.8)
                }
            }

//            titleLabel.font = UIFont.systemFont(ofSize: fontSizeSmall)
//          topBar.addSubview(titleLabel) 竖屏标题需求去掉
            topBar.addSubview(returnButton)

            shareButtonHalf.frame = CGRect(x: topBar.width - imgWidth - space, y: returnButton.frame.minY - 2, width: imgWidth, height: imgWidth)
            pushButtonHalf.frame = CGRect(x: topBar.width - imgWidth * 2 - space - imgHorizontalSpace, y: returnButton.frame.minY - 2, width: imgWidth, height: imgWidth)
            downloadButton.frame = CGRect(x: topBar.width - imgWidth * 3 - space - imgHorizontalSpace * 2, y:returnButton.frame.minY - 2, width: imgWidth, height: imgWidth)
            //竖屏标题需求去掉
//            var curWidth = kScreenWidth
//            if kScreenWidth < kScreenHeight {
//                curWidth = kScreenWidth
//            }else {
//                curWidth = kScreenHeight
//            }
//            titleLabel.frame = CGRect(x: returnButton.frame.maxX + space, y: returnButton.frame.minY - 2, width: curWidth - (returnButton.origin.x + returnButton.frame.size.width + 5) - (curWidth - (topBar.width - imgWidth - imgWidth)) - 5, height: titleLableHeight)

            // 底部导航栏
            bottomBar.frame = CGRect(x: 0, y: self.frame.height - bottomBarHeight, width: self.frame.width, height: bottomBarHeight)
            playOrPauseButton.frame = CGRect(x: space, y: playOrPauseButtonTop, width: playOrPauseButtonWidth, height: playOrPauseButtonWidth)
            fullOrSmallButton.frame = CGRect(x: bottomBar.frame.width - space - playOrPauseButtonWidth, y: playOrPauseButton.frame.minY, width: playOrPauseButtonWidth, height: playOrPauseButtonWidth)

            currentTimeLabel.frame = CGRect(x: bottomBar.frame.width - 2 * space - playOrPauseButtonWidth - currentTimeLabelWidth, y: playOrPauseButton.frame.minY, width: currentTimeLabelWidth, height: playOrPauseButtonWidth)
            currentTimeLabel.font = UIFont.systemFont(ofSize: 10)
            currentTimeLabel.textColor = UIColor.init("e7e8ed")
            currentTimeLabel.textAlignment = .right

            playSlider.frame = CGRect(x: playOrPauseButton.frame.maxX + space, y: playOrPauseButton.frame.minY + playOrPauseButtonWidth * 0.5 , width: currentTimeLabel.frame.minX - space - (playOrPauseButton.frame.maxX + space), height: 2)
            loadProgressView.frame = CGRect(x: playOrPauseButton.frame.maxX + space + 2, y: playOrPauseButton.frame.minY + playOrPauseButtonWidth * 0.5, width: currentTimeLabel.frame.minX - space - (playOrPauseButton.frame.maxX + space), height:0.5)
            loadProgressView.layer.cornerRadius = 1;
            loadProgressView.layer.masksToBounds = true

    
//            // 播放按钮，停止 播放  上一集/下一集
//            playOrPauseButton.center = CGPoint(x: self.frame.width / 2, y: (self.frame.height) / 2)
            // 上一集 下一集按钮 聚好学3.3版本暂时不使用了，先保留着

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
            space = 16
            imgHorizontalSpace = 24.0
            let m_space: CGFloat = 24
            let b_space: CGFloat = 36
            let img_w: CGFloat = 22
            // 隐藏半屏所特有的
//            pushButtonHalf.isHidden = true
//            shareButtonHalf.isHidden = true
//            pushButton.isHidden = false
//            shareButton.isHidden = false
//            separaterLineView1.isHidden = false
//            separaterLineView2.isHidden = false
            definitionButton.isHidden = false
            lockPlayScreenButton.isHidden = false
            fullOrSmallButton.isHidden = true
            moreButton.isHidden = false
            returnButtonHalfOnScreen.isHidden = true
            nextButton.isHidden = false
            titleLabel.isHidden = false

//            topBar.addSubview(moreButton)
            // 添加锁屏按钮
            self.addSubview(lockPlayScreenButton)

            // 顶部导航栏
            topBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 80)
            // TODO:  增添三元条件分支匹配最小值
            returnButton.frame = CGRect(x: space, y: returnButtonTop, width: returnButtonWidth*2, height: returnButtonHeight*2)
            returnButtonHalfOnScreen.frame = returnButton.frame
            if topControlsArray.count > 0 {
                for i in 1...topControlsArray.count {
                    let view: UIView = topControlsArray[i - 1] as! UIView
                    topBar.addSubview(view)
                    view.frame = CGRect(x: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count - i) - topBar.frame.height, y: topBar.frame.height * 0.1, width: topBar.frame.height * 0.8, height: topBar.frame.height * 0.8)
                }
            }

            shareButtonHalf.frame = CGRect(x: topBar.width - imgWidth - m_space, y: returnButton.frame.minY - 2, width: imgWidth, height: imgWidth)
            pushButtonHalf.frame = CGRect(x: topBar.width - imgWidth * 2 - m_space - b_space, y: returnButton.frame.minY - 2, width: imgWidth, height: imgWidth)
            downloadButton.frame = CGRect(x: topBar.width - imgWidth * 3 - m_space - b_space * 2, y:returnButton.frame.minY - 2, width: imgWidth, height: imgWidth)

//            separaterLineView1.frame = CGRect(x: moreButton.origin.x - 6, y: 0, width: 1, height: 8)
//            shareButton.frame = CGRect(x: separaterLineView1.origin.x - 50, y: 0, width: 50, height: topBar.frame.height)
//            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeFull)
//            separaterLineView2.frame = CGRect(x: shareButton.origin.x - 6, y: 0, width: 1, height: 8)
//            pushButton.frame = CGRect(x: separaterLineView2.origin.x - 50, y: 0, width: 50, height: topBar.frame.height)
//            pushButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeFull)
            
//            returnButton.center.y = topBar.center.y
//            moreButton.center.y = topBar.center.y
//            shareButton.center.y = topBar.center.y
//            separaterLineView1.center.y = topBar.center.y
//            separaterLineView2.center.y = topBar.center.y

            var curWidth = kScreenWidth
            var curHeight = kScreenHeight
            if kScreenWidth < kScreenHeight {
                curWidth = kScreenWidth
                curHeight = kScreenHeight
            }else {
                curWidth = kScreenHeight
                curHeight = kScreenWidth
            }

            titleLabel.font = UIFont.systemFont(ofSize: fontSizeFull)
            titleLabel.frame = CGRect(x: returnButton.frame.maxX + space, y: returnButton.frame.minY, width: curWidth - (returnButton.origin.x + returnButton.frame.size.width + 5) - (curWidth - (topBar.width - imgWidth - imgWidth)) - 5, height: titleLableHeight)
            
            let bottom_height:CGFloat = 84.0/375 * self.frame.height
            // 底部导航栏
            bottomBar.frame = CGRect(x: 0, y: self.frame.height - bottom_height, width: self.frame.width, height: bottom_height)
            // 进度条
            playSlider.frame = CGRect(x: space, y: bottomBar.height * 26.0 / 84.0 , width: bottomBar.frame.width - 2 * space - 2 * X_fullScreen, height:2)
            loadProgressView.frame = CGRect(x: space + 2, y: bottomBar.height * 26.0 / 84.0, width: bottomBar.frame.width - 2 * space - 2 * X_fullScreen, height: 0.5)
            loadProgressView.layer.cornerRadius = 1;
            loadProgressView.layer.masksToBounds = true

            // 时间指示器
//            currentTimeLabel.frame = CGRect(x: 16 + X_fullScreen, y: insetH - 2, width: 55, height: 14)
//            totalTimeLabel.isHidden = false
//            currentTimeLabel.center.y = loadProgressView.center.y // bottomBar.size.height * 2.0 / 3
//            totalTimeLabel.center.y = loadProgressView.center.y //bottomBar.size.height * 2.0 / 3
//            currentTimeLabel.textColor = UIColor.init("e7e8ed")
//            currentTimeLabel.textAlignment = .center
//            totalTimeLabel.textColor = UIColor.init("e7e8ed")
//            totalTimeLabel.textAlignment = .center
            
            playOrPauseButton.isHidden = false
            playOrPauseButton.frame = CGRect(x: space, y: playSlider.frame.maxY + 18/84.0 * bottomBar.height, width: img_w, height: img_w)
            
            nextButton.frame = CGRect(x: playOrPauseButton.frame.maxX + space, y: playOrPauseButton.frame.minY, width: img_w, height: img_w)
            
            // 设置全屏时字体大小
            currentTimeLabel.font = UIFont.systemFont(ofSize: fontSizeFull)
            currentTimeLabel.frame = CGRect(x: nextButton.frame.maxX + space , y:  playOrPauseButton.frame.minY, width: 200, height: img_w)
            currentTimeLabel.textAlignment = .left

            moreButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSizeFull)
            moreButton.frame = CGRect(x: bottomBar.frame.width - 35 - m_space  , y:  playOrPauseButton.frame.minY, width: 35, height: nextButton.frame.height)
            // 清晰度切换
            definitionButton.titleLabel!.font = UIFont.systemFont(ofSize: fontSizeFull)
            definitionButton.frame = CGRect(x: bottomBar.frame.width - 30 - m_space - b_space - 30 , y: playOrPauseButton.frame.minY, width: moreButton.frame.width, height: nextButton.frame.height)
            
//            totalTimeLabel.font = UIFont.systemFont(ofSize: fontSizeFull)
            // 导航栏右侧
     
//
//            playOrPauseButton.removeFromSuperview()
//            bottomBar.addSubview(playOrPauseButton)


//            // 全屏/半屏 切换
//            fullOrSmallButton.frame = CGRect(x: bottomBar.size.width - 16 - 30 - X_fullScreen, y: -15, width: 30, height: 30)
//            fullOrSmallButton.center.y = loadProgressView.center.y
            // 锁屏按钮
            lockPlayScreenButton.frame = CGRect(x: bottomBar.frame.width - m_space - 40, y: self.frame.height/2 - 20, width: 40, height: 40)
            
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
                //wg:因新版去掉进度指示img
        dragHud.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        dragHud.center = self.center
        dragLabel.frame = CGRect(x: -75, y: -20, width: 150, height: 40)

        dragLabel.font = UIFont.systemFont(ofSize: 15)
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
        // 与第三方视频源进行适配
        if let appType = UserDefaults.standard.object(forKey: "kCurDetailPageWebViewType") as? String {
            if appType != "0" { // 如果不是教育，隐藏播放器上很多按钮
                lockPlayScreenButton.isHidden = true
                pushButtonHalf.isHidden = true
                shareButton.isHidden = true
                shareButtonHalf.isHidden = true
                moreButton.isHidden = true
                pushButton.isHidden = true
                separaterLineView1.isHidden = true
                separaterLineView2.isHidden = true
                lockMaskView.isHidden = true
                lockPlayScreenButton.isHidden = true
                definitionButton.isHidden = true
                lockPlayScreenButton.isHidden = true
                downloadButton.isHidden = true
                // 下一集置灰
                nextButton.isUserInteractionEnabled = false
                nextButton.alpha = 0.4
            }else {
                // 下一集恢复正常
            nextButton.isUserInteractionEnabled = true
                nextButton.alpha = 1
            }
        }
    }

    open func addAllViews() {
        self.addSubview(topBar)
        topBar.addSubview(titleLabel)
        topBar.addSubview(returnButton)
        topBar.addSubview(downloadButton)
        topBar.addSubview(shareButton)
        topBar.addSubview(shareButtonHalf)
        topBar.addSubview(pushButton)
        topBar.addSubview(pushButtonHalf)
//        topBar.addSubview(separaterLineView1)
//        topBar.addSubview(separaterLineView2)
        self.addSubview(bottomBar)
        bottomBar.addSubview(loadProgressView)
        bottomBar.addSubview(playSlider)
        bottomBar.addSubview(playOrPauseButton)
        bottomBar.addSubview(fullOrSmallButton)
        bottomBar.addSubview(currentTimeLabel)
        bottomBar.addSubview(totalTimeLabel)
        bottomBar.addSubview(moreButton)
        dragHud.addSubview(dragLabel)
        self.addSubview(loadingIndicator)
        self.addSubview(returnButtonHalfOnScreen)
        loadingIndicator.startAnimating()
        // 上一集 下一集按钮 聚好学3.3版本暂时不使用了，先保留着
        //        bottomBar.addSubview(previewsButton)
                bottomBar.addSubview(nextButton)
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
    
    @objc public func downloadAction() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downLoadVideoFromCurrentPlayerNotify"), object: nil)
        JHKPlayerClosure.downloadClosure?()
    }
    /// Play or Pause video
    @objc public func playOrPauseAction() {
        // 点击了播放暂停按钮：发送通知检查用户设备超限
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playOrPauseBTNNotify"), object: nil)
        if isPlayerLocked {
            print("用户点击了播放器上的播放或者暂停按钮 playOrPauseAction")
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
        topBar.isHidden = true
        bottomBar.isHidden = true
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
        customizeActionHandler?.playNextAction()
    }

    /// Change definition
    @objc public func changeDefinitionAction() {
        if sideMenuForDefinition == true {
            isSideMenuShow = !isSideMenuShow
        } else {
            sideMenuForDefinition = true
            isSideMenuShow = true
        }
        topBar.isHidden = true
        bottomBar.isHidden = true
        lockPlayScreenButton.isHidden = true
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

    ///add gradient layer
    private func addGradientLayer(in view: UIView) {
        //定义渐变的颜色
        let color1 = menuContentColor.cgColor
        let color2 = clearColor.cgColor
        let gradientColors = [color1, color2]
        //定义每种颜色所在的位置
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        //创建CAGradientLayer对象并设置参数
        let layer = CAGradientLayer()
        layer.colors = gradientColors
        layer.locations = gradientLocations
        //设置渲染的起始结束位置（横向渐变）
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        view.layer.addSublayer(layer)
    }
    
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
        sideMenu.frame = CGRect(x: kScreenHeight, y: 0, width: kScreenHeight * 2 / 5, height: kScreenWidth)
        UIView.animate(withDuration: 0.25, animations: {
            let q: CGFloat
            if self.sideMenuForDefinition! { q = 4 } else { q = 3 }
            self.sideMenu.frame = CGRect(x: kScreenHeight * q / 5, y: 0, width: kScreenHeight * 2 / 5, height: kScreenWidth)
        })
    }

    /// Function to hide side menu from screen
    private func hideSideMenu() {
        UIView.animate(withDuration: 0.25, animations: {
            self.sideMenu.frame = CGRect(x: kScreenHeight, y: 0, width: kScreenHeight * 2 / 5, height: kScreenWidth)
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
        return true
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
//                if valueX > 0 {
//                    let image = UIImage.imageInBundle(named: "btn_forward")
//                    dragHud.image = image
//                } else {
//                    let image = UIImage.imageInBundle(named: "btn_backward")
//                    dragHud.image = image
//                }
                
                //wg:修复
                let string = currentTimeLabel.text
                if (string == nil) {return}
                let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:string!)
                let str = NSString(string: string!)
                let theRange = str.range(of: "/")
                let range = NSRange.init(location: 0, length: theRange.location)
                attrstring.addAttribute(.foregroundColor, value: UIColor.init("19cf8d"), range: range)
                attrstring.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: theRange)
                dragLabel.attributedText = attrstring
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

public extension UIView {
    
    // MARK: 添加渐变色图层
    public func gradientColor(_ startPoint: CGPoint, _ endPoint: CGPoint, _ colors: [Any]) {
        
        guard startPoint.x >= 0, startPoint.x <= 1, startPoint.y >= 0, startPoint.y <= 1, endPoint.x >= 0, endPoint.x <= 1, endPoint.y >= 0, endPoint.y <= 1 else {
            return
        }
        
        // 外界如果改变了self的大小，需要先刷新
        layoutIfNeeded()
        
        var gradientLayer: CAGradientLayer!
        
        removeGradientLayer()
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        // 渐变图层插入到最底层，避免在uibutton上遮盖文字图片
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.backgroundColor = UIColor.clear
        // self如果是UILabel，masksToBounds设为true会导致文字消失
        self.layer.masksToBounds = false
    }
    
    // MARK: 移除渐变图层
    // （当希望只使用backgroundColor的颜色时，需要先移除之前加过的渐变图层）
    public func removeGradientLayer() {
        if let sl = self.layer.sublayers {
            for layer in sl {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
}

