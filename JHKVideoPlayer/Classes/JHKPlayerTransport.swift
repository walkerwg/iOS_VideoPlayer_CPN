//
//  JHKPlayerTransport.swift
//  JHKVideoPlayer
//
//  Created by LuisGin on 17/2/8.
//  Copyright © 2017 LuisGin. All rights reserved.
//

import Foundation
import UIKit

/// Delegate on video processing
@objc public protocol JHKPlayerCallBack: NSObjectProtocol {
    @objc optional func videoDidReadyPlay()
    @objc optional func videoWillBeginPlay()
    @objc optional func videoPlayDidEnd()
    @objc optional func videoPlayDidPause()
    @objc optional func videoPlayWillContinue()
    @objc optional func playerDidFull()
    @objc optional func playerDidShrink()
}

/// Handler on screen guesture
@objc public protocol JHKPlayerGestureHandler: NSObjectProtocol {
    @objc optional func player(_ player: JHKVideoPlayer, singleTapGesture singleTap: UITapGestureRecognizer)
    @objc optional func player(_ player: JHKVideoPlayer, doubleTapGesture doubleTap: UITapGestureRecognizer)
    @objc optional func player(_ player: JHKVideoPlayer, movedHorizontal value: TimeInterval)
    @objc optional func player(_ player: JHKVideoPlayer, movedVerticalLeft value: TimeInterval)
    @objc optional func player(_ player: JHKVideoPlayer, movedVerticalRight value: TimeInterval)
}

/// Closure, use struct and closure is because @optional protocol is not supported by Swift(only if with @objc class)
public struct JHKPlayerClosure {
    static var playerSuccessClosure: (() ->())?
    static var playerFailClosure: (() ->())?
    static var playerFinishClosure: (() ->())?
    static var playerStopClosure: (() ->())?
    static var deviceOrientClosure: ((_ origent: UIDeviceOrientation) -> ())?
    static var playerDelayClosure: ((_ flag: Bool) -> ())?
    static var sliderValueChangeClosure: ((_ value: Float) -> ())?
    static var sliderDragedClosure: (() -> ())?
}

public struct JHKPlayerActionClosure {
    static var turnBackClosure: (() -> ())?
    static var playOrPauseClosure: (() -> ())?
    static var fullOrShrinkClosure: (() -> ())?
    static var changeDefinitionClosure: (() -> ())?
    static var playPreviousClosure: (() -> ())?
    static var playNextClosure: (() -> ())?
    static var pushScreenClosure: (() -> ())?
    static var moreInfoClosure: (() -> ())?
    static var scheduledPlayerClosure: ((_ value: Float) -> ())?
}

/// Exposed delegate to instance
@objc public protocol JHKPlayerActionsDelegate: NSObjectProtocol {
    @objc optional func playNextVideo()
    @objc optional func playPreviewsVideo()
    @objc optional func quitVideoPlayer()
    @objc optional func pushScreenAction()
    @objc optional func moreMenuAction() -> UIView
    @objc optional func determinedDefinition() -> UIView
}

public protocol JHKPlayerDelegate: JHKPlayerActionsDelegate, JHKPlayerGestureHandler, JHKPlayerCallBack {}
