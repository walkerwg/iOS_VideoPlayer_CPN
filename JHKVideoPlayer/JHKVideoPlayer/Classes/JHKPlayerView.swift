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

/// The view components of JHKVideoPlayer, and can be expanded in further
///
/// - Author: Luis Gin
/// - Version: v0.1.1
open class JHKPlayerView: UIView, UIGestureRecognizerDelegate {

// MARK: - Signal
    /// Signal of whether hide all the menu
    public var isMenuHidden: Bool = false {
        didSet{
            for subView in subviews {
                subView.isHidden = isMenuHidden
            }
        }
    }
    public var autoHiddenMenu: Bool = true

    // Signal of gesture directions
    public var horizontalSignal: Bool = false
    public var gestureLeftSignal: Bool = false

// MARK: - UIControls
    // Collect views into arrays to fit auto layout
    public var topControlsArray = NSMutableArray()
    public var bottomControlsArray = NSMutableArray()

    internal var menuContentColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.7) {
        didSet {
            for subView in subviews {
                subView.backgroundColor = menuContentColor
            }
        }
    }
    /// Top menu of player
    public lazy var topBar: UIView = {
        let topBar = UIView()
        topBar.backgroundColor = self.menuContentColor
        return topBar
    }()

    /// Bottom menu of player
    public lazy var bottomBar: UIView = {
        let bottomBar = UIView()
        bottomBar.backgroundColor = self.menuContentColor
        return bottomBar
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
        let image = UIImage.imageInBundle(named: "menu_quit")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
        return button
    }()

    /// Push button on top menu right side
    open lazy var pushButton: UIButton = {
        let button = UIButton()
        button.setTitle("投屏", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(pushButtonAction), for: .touchUpInside)
        return button
    }()

    /// More button on top menu right side
    open lazy var moreButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "menu_more")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        return button
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
    open var sliderGesture: UITapGestureRecognizer?

    /// Play or pause button
    open lazy var playOrPauseButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "btn_play")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(playOrPauseAction), for: .touchUpInside)
        return button
    }()

    /// Previews video button on bottom mune
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
        let image = UIImage.imageInBundle(named: "btn_next")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()

    /// Full screen button
    open lazy var fullOrSmallButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "player_full")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(fullOrShrinkAction), for: .touchUpInside)
        return button
    }()

    /// Indicator
    open lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.startAnimating()
        return indicator
    }()

    /// Drag hub
    open lazy var dragHub: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = self.menuContentColor
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
        button.setTitle("高清", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(changeDefinitionAction), for: .touchUpInside)
        return button
    }()

// MARK: - Init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addAllViews()
        self.addGuestures()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        topBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height / 8)
        // FIXME:  增添三元条件分支匹配最小值
        bottomBar.frame = CGRect(x: 0, y: self.frame.height * 6 / 7 - 16, width: self.frame.width, height: self.frame.height / 7 + 16)
        returnButton.frame = CGRect(x: 5, y: 5, width: topBar.frame.height - 10, height: topBar.frame.height - 10)
        titleLabel.frame = CGRect(x: topBar.frame.height + 5, y: 0, width: self.frame.width - topBar.frame.height * 2 - 10, height: topBar.frame.height)
        titleLabel.font = UIFont.systemFont(ofSize: titleLabel.frame.height * 2 / 3)
        pushButton.frame = CGRect(x: self.frame.width - topBar.frame.height * 3 / 2, y: 0, width: topBar.frame.height, height: topBar.frame.height)
        for i in 1...topControlsArray.count {
            let view: UIView = topControlsArray[i - 1] as! UIView
            topBar.addSubview(view)
            view.frame = CGRect(x: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count - i) - topBar.frame.height * 1.3, y: 0, width: topBar.frame.height, height: topBar.frame.height)
        }
        playSlider.frame = CGRect(x: 0, y: 0, width: bottomBar.frame.width, height: 10)
        let insetH: CGFloat = playSlider.frame.height
        loadProgressView.frame = CGRect(x: 0, y: insetH / 2, width: bottomBar.frame.width , height: insetH)
        playOrPauseButton.frame = CGRect(x: 0, y: 0, width: (bottomBar.frame.height - insetH) * 0.82, height: (bottomBar.frame.height - insetH) * 0.82)
        playOrPauseButton.center = CGPoint(x: bottomBar.frame.width / 2, y: (bottomBar.frame.height + insetH) / 2)
        fullOrSmallButton.frame = CGRect(x: bottomBar.frame.width - bottomBar.frame.height * 3 / 4, y: insetH + 10, width: bottomBar.frame.height / 2, height: bottomBar.frame.height / 2)
        previewsButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 2 / 3, height: playOrPauseButton.frame.height * 2 / 3)
        previewsButton.center = CGPoint(x: playOrPauseButton.center.x - playOrPauseButton.frame.width * 2, y: playOrPauseButton.center.y)
        nextButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 2 / 3, height: playOrPauseButton.frame.height * 2 / 3)
        nextButton.center = CGPoint(x: playOrPauseButton.center.x + playOrPauseButton.frame.width * 2, y: playOrPauseButton.center.y)
        for view in bottomControlsArray {
            bottomBar.addSubview(view as! UIView)
        }
        definitionButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 2 / 3, height: playOrPauseButton.frame.height * 2 / 5)
        definitionButton.center = CGPoint(x: playOrPauseButton.center.x - playOrPauseButton.frame.width * 4, y: playOrPauseButton.center.y)
        definitionButton.titleLabel!.font = UIFont.systemFont(ofSize: definitionButton.frame.height * 2 / 3)
        currentTimeLabel.frame = CGRect(x: 5, y: insetH - 2, width: 55, height: 14)
        totalTimeLabel.frame = CGRect(x: bottomBar.frame.width - 60, y: insetH - 2, width: 55, height: 14)
        loadingIndicator.center = CGPoint(x: self.center.x, y: self.center.y)
        dragHub.frame = CGRect(x: 0, y: 0, width: self.frame.height / 5, height: self.frame.height / 5)
        dragHub.center = self.center
        dragLabel.frame = CGRect(x: 0, y: dragHub.frame.height, width: dragHub.frame.width, height: dragHub.frame.height * 2 / 5)
        dragLabel.font = UIFont.systemFont(ofSize: dragLabel.frame.height)
        volumeControl.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    open func addAllViews() {
        self.addSubview(topBar)
        topBar.addSubview(titleLabel)
        topBar.addSubview(returnButton)
        topControlsArray.add(pushButton)
        self.addSubview(bottomBar)
        bottomBar.addSubview(loadProgressView)
        bottomBar.addSubview(playSlider)
        bottomBar.addSubview(previewsButton)
        bottomBar.addSubview(nextButton)
        bottomBar.addSubview(playOrPauseButton)
        bottomBar.addSubview(fullOrSmallButton)
        bottomBar.addSubview(currentTimeLabel)
        bottomBar.addSubview(totalTimeLabel)
        dragHub.addSubview(dragLabel)
        self.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }

    public weak var gestureHandler: JHKPlayerGestureHandler?
    // Add all gestures to control view
    open func addGuestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.delegate = self

        sliderGesture = UITapGestureRecognizer(target: self, action: #selector(sliderGestureHandler))
        sliderGesture!.numberOfTapsRequired = 1
        sliderGesture!.numberOfTouchesRequired = 1
        sliderGesture!.delegate = self
        playSlider.addGestureRecognizer(sliderGesture!)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
        panGesture.delegate = self;
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
    }

// MARK: - Gesture Handler
    // Discard gesture responser if touch event is tring to make state possible
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if autoHiddenMenu {
            JHKPlayerView.self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideMenu), object: nil)
            self.perform(#selector(hideMenu), with: nil, afterDelay: 5)
        }
        let startPoint = touch.location(in: self)
        let hitView = self.hitTest(startPoint, with: nil)
        if self == hitView {
            return true
        } else if let panGesture = gestureRecognizer as? UITapGestureRecognizer {
            if playSlider == hitView {
                return true
            }
        }
        return false
    }

    open func sliderGestureHandler(_ tap:UITapGestureRecognizer) {
        let touchPoint = tap.location(in: self.playSlider)
        let value = (playSlider.maximumValue - playSlider.minimumValue) * Float(touchPoint.x / playSlider.frame.size.width)
        if JHKPlayerActionClosure.scheduledPlayerClosure != nil {
            JHKPlayerActionClosure.scheduledPlayerClosure!(value)
        }
    }

    open func tapGestureHandler(_ tap:UITapGestureRecognizer) {
        if tap.numberOfTapsRequired == 1 {
            // Do single tap action
            isMenuHidden = !isMenuHidden
        } else {
            // Do double tap action
            fullOrShrinkAction()
        }
    }

    open func panGestureHandler(_ pan:UIPanGestureRecognizer) {
        let startPoint: CGPoint = pan.location(in: self)
        let velocityPoint: CGPoint = pan.velocity(in: self)

        // Pesponse pan gesture with different patern
        switch pan.state {
        // Input gesture signal when touch began
        case .began:
            JHKPlayerView.self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideMenu), object: nil)
            let x: CGFloat = fabs(velocityPoint.x);
            let y: CGFloat = fabs(velocityPoint.y);

            // if moved horizontal
            if x > y {
                self.horizontalSignal = true
            } else {
                self.horizontalSignal = false
                // change gesture location signal to determine left operation and right operation
                if (startPoint.x > self.bounds.size.width / 2) {
                    self.gestureLeftSignal = false
                } else {
                    self.gestureLeftSignal = true
                }
            }
        case .changed:
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
                    dragHub.image = image
                } else {
                    let image = UIImage.imageInBundle(named: "btn_backward")
                    dragHub.image = image
                }
                dragLabel.text = currentTimeLabel.text
                if JHKPlayerClosure.sliderValueChangeClosure != nil {
                    JHKPlayerClosure.sliderValueChangeClosure!(newValue)
                }
            } else if gestureLeftSignal {
                // do left gesture action
                let image = UIImage.imageInBundle(named: "icon_brightness")
                dragHub.image = image
                UIScreen.main.brightness -= valueY / 8000
                dragLabel.text = String(format: "%.0f%%", (UIScreen.main.brightness * 100))
            } else {
                // do right gesture action
                let image = UIImage.imageInBundle(named: "icon_sound")
                dragHub.image = image
                volumeViewSlider?.value -= Float(valueY) / 8000
                dragLabel.text = String(format: "%.0f%%", ((volumeViewSlider?.value)! * 100))
            }
            self.addSubview(dragHub)
        case .ended:
            if autoHiddenMenu {
                self.perform(#selector(hideMenu), with: nil, afterDelay: 5)
            }
            // 移动结束也需要判断垂直或者平移，比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            if horizontalSignal {
                if JHKPlayerClosure.sliderDragedClosure != nil {
                    JHKPlayerClosure.sliderDragedClosure!()
                }
            } else if gestureLeftSignal{
                // TODO: do left gesture action
            } else {
                // TODO: do right gesture action
            }
            dragHub.removeFromSuperview()
        default: break
        }
    }

// MARK: - First response action
    /// Full or shrink screen
    public func fullOrShrinkAction() {
        if JHKPlayerActionClosure.fullOrShrinkClosure != nil {
            JHKPlayerActionClosure.fullOrShrinkClosure!()
        }
    }

    /// Play or Pause video
    public func playOrPauseAction() {
        if JHKPlayerActionClosure.playOrPauseClosure != nil {
            JHKPlayerActionClosure.playOrPauseClosure!()
        }
    }

    /// Push to remote screen
    public func pushButtonAction() {
        if JHKPlayerActionClosure.pushScreenClosure != nil {
            JHKPlayerActionClosure.pushScreenClosure!()
        }
    }

    /// Return back action
    public func returnButtonAction() {
        if JHKPlayerActionClosure.turnBackClosure != nil {
            JHKPlayerActionClosure.turnBackClosure!()
        }
    }

    /// More infomation action
    public func moreButtonAction() {
        if JHKPlayerActionClosure.moreInfoClosure != nil {
            JHKPlayerActionClosure.moreInfoClosure!()
        }
    }

    /// Previews action
    public func previewsAction() {
        if JHKPlayerActionClosure.playPreviousClosure != nil {
            JHKPlayerActionClosure.playPreviousClosure!()
        }
    }

    /// Next action
    public func nextAction() {
        if JHKPlayerActionClosure.playNextClosure != nil {
            JHKPlayerActionClosure.playNextClosure!()
        }
    }

    /// Change definition
    public func changeDefinitionAction() {
        if JHKPlayerActionClosure.changeDefinitionClosure != nil {
            JHKPlayerActionClosure.changeDefinitionClosure!()
        }
    }

    /// Progressor changing
    func playSliderChanging(_ sender: AnyObject) {
        let slider = sender as! UISlider
        if JHKPlayerClosure.sliderValueChangeClosure != nil {
            JHKPlayerClosure.sliderValueChangeClosure!(slider.value)
        }
    }

    /// Slider touch up inside,
    func playSliderDraged(_ sender: AnyObject) {
        if autoHiddenMenu {
            self.perform(#selector(hideMenu), with: nil, afterDelay: 5)
        }
        for gesture in self.gestureRecognizers! {
            gesture.isEnabled = true
        }
        sliderGesture?.isEnabled = true
        if JHKPlayerClosure.sliderDragedClosure != nil {
            JHKPlayerClosure.sliderDragedClosure!()
        }
    }
    
    /// Slider touch down, only affect touch on the thumb instead of track rect
    func playSliderSeeked(_ sender: AnyObject) {
        JHKPlayerView.self.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideMenu), object: nil)
        for gesture in self.gestureRecognizers! {
            gesture.isEnabled = false
        }
        sliderGesture?.isEnabled = false
    }

// MARK: - Dependant functions
    /// Function to hide all subviews
    public func hideMenu() {
        self.isMenuHidden = true
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
}

