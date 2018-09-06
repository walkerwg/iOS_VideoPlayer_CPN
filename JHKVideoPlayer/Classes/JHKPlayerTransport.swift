//
//  JHKPlayerTransport.swift
//  JHKVideoPlayer
//
//  Created by LuisGin on 17/2/8.
//  Copyright © 2017 LuisGin. All rights reserved.
//

import Foundation
import UIKit

/// Closure, use struct and closure is because @optional protocol is not supported by Swift(only if with @objc class)
struct JHKPlayerClosure {
    static var sliderDragedClosure: (() -> ())?
    static var playOrPauseClosure: (() -> ())?
    static var lockPlayScreenClosure: (() -> ())?
    static var changeDefinitionClosure: (() -> ())?
    static var moreInfoClosure: (() -> ())?
    static var shareInfoClosure: (() -> ())?
    static var scheduledPlayerClosure: ((_ value: Float) -> ())?
    static var downloadClosure: (() -> ())?
    static var collectClosure: ((_ collectState: JHKPlayerCollectState) -> ())?
}

protocol JHKInternalTransport: class {
    var autoHiddenMenu: Bool { get set }
    func sliderValueChange(value: Float)
    func fullOrShrinkAction()
    func returnButtonAction()
    func openVIPButtonAction()
    func isFullScreen() -> JHKPlayerFullScreenMode
    func collagenScreen()
    func fullScreen()
}

/// Handler on screen guesture. if you plan on customize own intereaction, simply modify playerView.customizeGestureHandler which default as 'self'.
@objc protocol JHKPlayerGestureHandler {
    /// Handle tag gesture on main player screen.
    func tapGestureHandler(_ tap: UITapGestureRecognizer)
    /// Handle specific click on slider.
    func sliderGestureHandler(_ slide: UITapGestureRecognizer)
    /// Handle pan gesture on main player screen.
    func panGestureHandler(_ pan: UIPanGestureRecognizer)
    //func player(_ player: JHKVideoPlayer, movedHorizontal value: TimeInterval)
    //func player(_ player: JHKVideoPlayer, movedVerticalLeft value: TimeInterval)
    //func player(_ player: JHKVideoPlayer, movedVerticalRight value: TimeInterval)
}

/// Protocol to be implement by classes which have JHKVideoPlayer as property
public protocol JHKPlayerActionsDelegate: class {
    /// Primary listener, providing top level user defined manipulation.
    ///
    /// - Parameter time: playing rate
    func breakPointListener(time: CGFloat)

    /// Event of start playing, called every time player status change to 'play', whether from 'stop' or 'pause'.
    func startPlayingListener()

    /// Event of failed loading media resources.
    func failLoadListener()

    /// Intereaction of click previous button.
    func playPreviousAction()

    /// Intereaction of click pause button.
    func playPauseAction()

    /// Intereaction of click next button.
    func playNextAction()

    /// Intereaction of click quit button.
    func playerQuitAction()

    /// Intereaction of click push-screen button.
    func pushScreenAction()

    /// Intereaction of click more-menu button.
    func moreMenuAction() -> UIView

    /// Intereaction of click definition button.
    func determinedDefinition() -> UIView

    /// Intereaction of click share button.
    func shareAction()
    
    /// Intereaction of click download button.
    func downloadAction()
    
    /// Intereaction of click collect button
    func collectAction(collectState: JHKPlayerCollectState)
}

// Default intereaction of Events in protocol
extension JHKPlayerActionsDelegate {
    public func breakPointListener(time: CGFloat) {}
    public func failLoadListener() {
        print("###player fail load###")
    }
    public func startPlayingListener() {
        print("###player start playing###")
    }
    public func playPauseAction() {
        print("###player paused###")
    }
    public func playPreviousAction() {}
    public func playNextAction() {}
    public func playerQuitAction() {
        print("###quit player###")
    }
    public func pushScreenAction() {
        print("###push screen###")
    }
    public func moreMenuAction() -> UIView {
        let view = UIView()
        return view
    }
    public func determinedDefinition() -> UIView {
        let view = UIView()
        return view
    }
    public func downloadAction() {
        print("###player download###")

    }
}
