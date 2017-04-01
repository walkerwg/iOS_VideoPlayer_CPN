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
public struct JHKPlayerClosure {
    static var sliderValueChangeClosure: ((_ value: Float) -> ())?
    static var sliderDragedClosure: (() -> ())?
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

/// Handler on screen guesture
public protocol JHKPlayerGestureHandler: class {
    func player(_ player: JHKVideoPlayer, singleTapGesture singleTap: UITapGestureRecognizer)
    func player(_ player: JHKVideoPlayer, doubleTapGesture doubleTap: UITapGestureRecognizer)
    func player(_ player: JHKVideoPlayer, movedHorizontal value: TimeInterval)
    func player(_ player: JHKVideoPlayer, movedVerticalLeft value: TimeInterval)
    func player(_ player: JHKVideoPlayer, movedVerticalRight value: TimeInterval)
}

/// Protocol to be implement by classes which have JHKVideoPlayer as property
public protocol JHKPlayerActionsDelegate: class {
    func breakPointListener(time: CGFloat)
    func startPlayingListener()
    func playPreviousAction()
    func playNextAction()
    func playerQuitAction()
    func pushScreenAction()
    func moreMenuAction() -> UIView
    func determinedDefinition() -> UIView
}

// Swift建议写法，不破坏封装可以直接写在module外
extension JHKPlayerActionsDelegate {
    public func breakPointListener(time: CGFloat) {
        print("###defult implement###")
    }
    public func startPlayingListener() {
        print("###player start playing###")
    }
    public func playPreviousAction() {
        print("###play previous video###")
    }
    public func playNextAction() {
        print("###play next video###")
    }
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
}
