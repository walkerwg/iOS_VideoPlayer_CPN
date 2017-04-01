//
//  ViewController.swift
//  JHKVideoPlayer
//
//  Created by dinghanqing on 02/14/2017.
//  Copyright (c) 2017 dinghanqing. All rights reserved.
//

import UIKit
import JHKVideoPlayer

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRect(x: 20, y: 100, width: 120, height: 44))
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(pushView), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pushView() {
        let view2 = MenuController(nibName: nil, bundle: nil)
        self.present(view2, animated: true, completion: nil)
    }
}

