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

    fileprivate lazy var playerView: JHKVideoPlayer = {
        [unowned self] in
        let player = JHKVideoPlayer(frame:CGRect(x:10, y:40, width:300, height:180))
        player.actionDelegate = self
        player.backgroundColor = .black
        return player
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let url = URL(string: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4") else {
            fatalError("连接错误")
        }
        //let localUrl = Bundle.main.url(forResource: "music-box", withExtension: "mp4")

        playerView.mediaURL = url//(localUrl! as URL)
        playerView.videoTitle = "This is a temp title"
        playerView.actionDelegate = self
        playerView.autoDismissMenu = false
        playerView.controlView?.autoHiddenMenu = false
        self.view.addSubview(playerView)
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
        playerView.lockPlayer(with: "已成功锁定播放器", action: "开通Vip", handler: {
            print("暂无链接")
        })
    }
}
