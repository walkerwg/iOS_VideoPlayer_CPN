//
//  File.swift
//  JHKVideoPlayer
//
//  Created by LuisGin on 17/3/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import JHKVideoPlayer

class MenuController: UIViewController, JHKPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = NSURL(string: "http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4") else {
            fatalError("连接错误")
        }

        let localUrl = Bundle.main.url(forResource: "music-box", withExtension: "mp4")
        
        let playerView = JHKVideoPlayer(frame:CGRect(x:10, y:40, width:300, height:180))
        playerView.mediaURL = (localUrl! as URL)
        playerView.videoTitle = "This is a temp title"
        playerView.playerDelegate = self
        self.view.addSubview(playerView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func quitVideoPlayer() {
        self.dismiss(animated: true, completion: nil)
        print("#####################")
    }
}
