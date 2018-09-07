//
//  File.swift
//  JHKVideoPlayer
//
//  Created by LuisGin on 17/3/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import JHKVideoPlayer

class MenuController: UIViewController, JHKPlayerActionsDelegate {
    func collectAction(collectState: JHKPlayerCollectState) {
        if collectState == .JHK_PLAYERVIEW_CANCELCOLLERCTSTATE {
            print("取消收藏")
        } else {
            print("点击收藏")
        }
    }
    
    func shareAction() {
        print("点击了 shareAction")
    }
    

    fileprivate lazy var playerView: JHKVideoPlayer = {
        [unowned self] in
        let player = JHKVideoPlayer(frame:CGRect(x:10, y:40, width:300, height:180))
        player.actionDelegate = self
        player.backgroundColor = .black
        player.setPlayer(playerType: .JHK_PLAYERVIEW_JHKTYPE, collectState: .JHK_PLAYERVIEW_COLLECTSTATE)
//        player.playerType = .JHK_PLAYERVIEW_JHKTYPE
//        player.playerCollectState = .JHK_PLAYERVIEW_COLLECTSTATE
        return player
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let url = URL(string: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4") else {
            fatalError("连接错误")
        }
        //let localUrl = Bundle.main.url(forResource: "music-box", withExtension: "mp4")
        //playerView = JHKVideoPlayer.init(url: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4")
        playerView.mediaURL = url//(localUrl! as URL)
        playerView.videoTitle = "This is a temp title"
        playerView.actionDelegate = self
        playerView.startPoint = CGFloat.init(15)
        playerView.cutCollectState(collectState: .JHK_PLAYERVIEW_CANCELCOLLERCTSTATE)
        self.view.addSubview(playerView)
//        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension JHKPlayerActionsDelegate where Self: MenuController {
    func breakPointListener(time: CGFloat) -> Bool {
        return true
    }

    func playerQuitAction() {
        self.dismiss(animated: false, completion: nil)
    }

    func pushScreenAction() {
        playerView.lockPlayer(with: "已成功锁定播放器\n若继续播放请开通Vip\n", isStopPlaying: false, actions: [LockAction.action(title: "立即开通\n", attributes: [:], handler: { print("外部打印")})])
    }
}
