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
    private var isMenuHidden: Bool = false {
        didSet{
            for subView in subviews {
                if subView != loadingIndicator && subView != lockMaskView {
                    subView.isHidden = isMenuHidden
                }
            }
            isSideMenuShow = false
        }
    }
    public var autoHiddenMenu: Bool = true

    // Signal of gesture directions
    public var horizontalSignal: Bool = false
    public var gestureLeftSignal: Bool = false
    public var sideMenuForDefinition: Bool?
    public var isSideMenuShow: Bool = false {
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

    internal var menuContentColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.7) {
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
        let image = UIImage.imageInBundle(named: "menu_quit")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
        return button
    }()

    /// Push button on top menu right side
    open lazy var pushButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "btn_pane")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(pushButtonAction), for: .touchUpInside)
        return button
    }()

    /// More button on top menu right side
    open lazy var moreButton: UIButton = {
        let button = UIButton()
        let image = UIImage.imageInBundle(named: "menu_more")
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(changeDefinitionAction), for: .touchUpInside)
        return button
    }()

    open lazy var lockMaskView: UIView = { [weak self] in
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    open lazy var lockMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()

    open lazy var lockTransButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .blue
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
        // TODO:  增添三元条件分支匹配最小值
        bottomBar.frame = CGRect(x: 0, y: self.frame.height * 5 / 6 - 16, width: self.frame.width, height: self.frame.height / 6 + 16)
        returnButton.frame = CGRect(x: topBar.frame.height * 0.2, y: topBar.frame.height * 0.2, width: topBar.frame.height * 0.6, height: topBar.frame.height * 0.6)
        if topControlsArray.count > 0 {
            for i in 1...topControlsArray.count {
                let view: UIView = topControlsArray[i - 1] as! UIView
                topBar.addSubview(view)
                view.frame = CGRect(x: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count - i) - topBar.frame.height, y: topBar.frame.height * 0.1, width: topBar.frame.height * 0.8, height: topBar.frame.height * 0.8)
            }
        }
        titleLabel.frame = CGRect(x: topBar.frame.height, y: 0, width: self.frame.width - topBar.frame.height * CGFloat(topControlsArray.count + 1) - 10, height: topBar.frame.height)
        titleLabel.font = UIFont.systemFont(ofSize: titleLabel.frame.height * 4 / 9)
        playSlider.frame = CGRect(x: 0, y: 0, width: bottomBar.frame.width, height: 10)
        let insetH: CGFloat = playSlider.frame.height
        loadProgressView.frame = CGRect(x: 0, y: insetH / 2, width: bottomBar.frame.width , height: insetH)
        playOrPauseButton.frame = CGRect(x: 0, y: 0, width: (bottomBar.frame.height - insetH) * 0.82, height: (bottomBar.frame.height - insetH) * 0.82)
        playOrPauseButton.center = CGPoint(x: bottomBar.frame.width / 2, y: (bottomBar.frame.height + insetH) / 2)
        previewsButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 0.7, height: playOrPauseButton.frame.height * 0.7)
        previewsButton.center = CGPoint(x: playOrPauseButton.center.x - playOrPauseButton.frame.width * 1.75, y: playOrPauseButton.center.y)
        nextButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 0.7, height: playOrPauseButton.frame.height * 0.7)
        nextButton.center = CGPoint(x: playOrPauseButton.center.x + playOrPauseButton.frame.width * 1.75, y: playOrPauseButton.center.y)
        fullOrSmallButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 0.58, height: playOrPauseButton.frame.height * 0.58)
        fullOrSmallButton.center = CGPoint(x: playOrPauseButton.center.x + playOrPauseButton.frame.width * 3, y: playOrPauseButton.center.y)
        pushButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 0.58, height: playOrPauseButton.frame.height * 0.58)
        pushButton.center = CGPoint(x: playOrPauseButton.center.x - playOrPauseButton.frame.width * 3, y: playOrPauseButton.center.y)
        definitionButton.frame = CGRect(x: 0, y: 0, width: playOrPauseButton.frame.height * 2 / 3, height: playOrPauseButton.frame.height * 2 / 5)
        definitionButton.center = CGPoint(x: playOrPauseButton.center.x - playOrPauseButton.frame.width * 4.5, y: playOrPauseButton.center.y)
        definitionButton.titleLabel!.font = UIFont.systemFont(ofSize: definitionButton.frame.height * 2 / 3)
        for view in bottomControlsArray {
            bottomBar.addSubview(view as! UIView)
        }
        currentTimeLabel.frame = CGRect(x: 5, y: insetH - 2, width: 55, height: 14)
        totalTimeLabel.frame = CGRect(x: bottomBar.frame.width - 60, y: insetH - 2, width: 55, height: 14)
        loadingIndicator.center = CGPoint(x: self.center.x, y: self.center.y)
        dragHud.frame = CGRect(x: 0, y: 0, width: self.frame.height / 5, height: self.frame.height / 5)
        dragHud.center = self.center
        dragLabel.frame = CGRect(x: 0, y: dragHud.frame.height, width: dragHud.frame.width, height: dragHud.frame.height * 2 / 5)
        dragLabel.font = UIFont.systemFont(ofSize: dragLabel.frame.height)
        volumeControl.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        lockMaskView.frame = CGRect(x: 0, y: topBar.frame.height, width: self.frame.width, height: self.frame.height - topBar.frame.height - bottomBar.frame.height)
        lockMessageLabel.frame = CGRect(x: self.frame.width / 4, y: 0, width: self.frame.width / 2, height: lockMaskView.frame.height)
        lockMaskView.addSubview(lockMessageLabel)
    }

    open func addAllViews() {
        self.addSubview(topBar)
        topBar.addSubview(titleLabel)
        topBar.addSubview(returnButton)
        self.addSubview(bottomBar)
        bottomBar.addSubview(loadProgressView)
        bottomBar.addSubview(playSlider)
        bottomBar.addSubview(previewsButton)
        bottomBar.addSubview(nextButton)
        bottomBar.addSubview(playOrPauseButton)
        bottomBar.addSubview(fullOrSmallButton)
        bottomBar.addSubview(pushButton)
        bottomBar.addSubview(currentTimeLabel)
        bottomBar.addSubview(totalTimeLabel)
        dragHud.addSubview(dragLabel)
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
        } else if let gesture = gestureRecognizer as? UITapGestureRecognizer {
            if playSlider == hitView || lockMaskView == hitView {
                return true
            }
        }
        return false
    }

    open func sliderGestureHandler(_ tap:UITapGestureRecognizer) {
        let touchPoint = tap.location(in: self.playSlider)
        let value = (playSlider.maximumValue - playSlider.minimumValue) * Float(touchPoint.x / playSlider.frame.size.width)
        if JHKPlayerClosure.scheduledPlayerClosure != nil {
            JHKPlayerClosure.scheduledPlayerClosure!(value)
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
                    dragHud.image = image
                } else {
                    let image = UIImage.imageInBundle(named: "btn_backward")
                    dragHud.image = image
                }
                dragLabel.text = currentTimeLabel.text
                playSlider.value = newValue
                if JHKPlayerClosure.sliderValueChangeClosure != nil {
                    JHKPlayerClosure.sliderValueChangeClosure!(newValue)
                }
            } else if gestureLeftSignal {
                // do left gesture action
                let image = UIImage.imageInBundle(named: "icon_brightness")
                dragHud.image = image
                UIScreen.main.brightness -= valueY / 8000
                dragLabel.text = String(format: "%.0f%%", (UIScreen.main.brightness * 100))
            } else {
                // do right gesture action
                let image = UIImage.imageInBundle(named: "icon_sound")
                dragHud.image = image
                volumeViewSlider?.value -= Float(valueY) / 8000
                dragLabel.text = String(format: "%.0f%%", ((volumeViewSlider?.value)! * 100))
            }
            self.addSubview(dragHud)
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
            dragHud.removeFromSuperview()
        default: break
        }
    }

// MARK: - First response action
    /// Full or shrink screen
    public func fullOrShrinkAction() {
        if JHKPlayerClosure.fullOrShrinkClosure != nil {
            JHKPlayerClosure.fullOrShrinkClosure!()
        }
    }

    /// Play or Pause video
    public func playOrPauseAction() {
        if JHKPlayerClosure.playOrPauseClosure != nil {
            JHKPlayerClosure.playOrPauseClosure!()
        }
    }

    /// Push to remote screen
    public func pushButtonAction() {
        if JHKPlayerClosure.pushScreenClosure != nil {
            JHKPlayerClosure.pushScreenClosure!()
        }
    }

    /// Return back action
    public func returnButtonAction() {
        if JHKPlayerClosure.turnBackClosure != nil {
            JHKPlayerClosure.turnBackClosure!()
        }
    }

    /// More infomation action
    public func moreButtonAction() {
        if sideMenuForDefinition == false {
            isSideMenuShow = !isSideMenuShow
        } else {
            sideMenuForDefinition = false
            isSideMenuShow = true
        }
        if JHKPlayerClosure.moreInfoClosure != nil {
            JHKPlayerClosure.moreInfoClosure!()
        }
    }

    /// Previews action
    public func previewsAction() {
        isSideMenuShow = false
        if JHKPlayerClosure.playPreviousClosure != nil {
            JHKPlayerClosure.playPreviousClosure!()
        }
    }

    /// Next action
    public func nextAction() {
        isSideMenuShow = false
        if JHKPlayerClosure.playNextClosure != nil {
            JHKPlayerClosure.playNextClosure!()
        }
    }

    /// Change definition
    public func changeDefinitionAction() {
        if sideMenuForDefinition == true {
            isSideMenuShow = !isSideMenuShow
        } else {
            sideMenuForDefinition = true
            isSideMenuShow = true
        }
        if JHKPlayerClosure.changeDefinitionClosure != nil {
            JHKPlayerClosure.changeDefinitionClosure!()
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

    /// Reset all status and clean view
    public func resetStatus() {
        playSlider.setValue(0, animated: true)
        loadProgressView.setProgress(0, animated: false)
        currentTimeLabel.text = "00:00"
    }

    /// Function to push side menu to screen
    public func pushSideMenu() {
        if sideMenu.superview == nil {
            self.addSubview(sideMenu)
            setNeedsLayout()
        }
        sideMenu.frame = CGRect(x: self.frame.width, y: self.topBar.frame.height, width: self.frame.width * 2 / 5, height: self.frame.height - self.topBar.frame.height - self.bottomBar.frame.height)
        UIView.animate(withDuration: 0.25, animations: {
            let q: CGFloat
            if self.sideMenuForDefinition! { q = 4 } else { q = 3 }
            self.sideMenu.frame = CGRect(x: self.frame.width * q / 5, y: self.topBar.frame.height, width: self.frame.width * 2 / 5, height: self.frame.height - self.topBar.frame.height - self.bottomBar.frame.height)
        })
    }

    /// Function to hide side menu from screen
    private func hideSideMenu() {
        UIView.animate(withDuration: 0.25, animations: {
            self.sideMenu.frame = CGRect(x: self.frame.width, y: self.topBar.frame.height, width: self.frame.width * 2 / 5, height: self.frame.height - self.topBar.frame.height - self.bottomBar.frame.height)
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

    public func setUpLockMask(message: String, button: String?) {
        let normalAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 10.0),  NSForegroundColorAttributeName : UIColor.white]
        var attributedString = NSMutableAttributedString(string: message, attributes: normalAttrs)
        let hyperAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 11.0),  NSForegroundColorAttributeName : UIColor.blue]
        attributedString.append(NSAttributedString(string: button!, attributes: hyperAttrs))
        lockMessageLabel.attributedText = attributedString
    }
}

