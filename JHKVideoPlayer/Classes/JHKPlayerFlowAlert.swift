//
//  JHKPlayerFlowAlert.swift
//  Alamofire
//
//  Created by keep on 2018/8/11.
//

import UIKit

enum JHKPlayerFlowClickType: Int {
    /** 点击取消 */
    case JHK_PLAYERFLOWALERT_CLICKBTN_CANCELTYPE = 0
    
    /** 点击确定 */
    case JHK_PLAYERFLOWALERT_CLICKBTN_PLAYTYPE = 1
}

@objc protocol JHKPlayerFlowAlertDelegate {
    func clickPlayerFlowAlert(type: Int)
}

class JHKPlayerFlowAlert: UIView {
    
    /** 屏幕宽 */
    let kScreenWidth: CGFloat = UIScreen.main.bounds.width
    /** 屏幕高 */
    let kScreenHeight: CGFloat = UIScreen.main.bounds.height
    
    /** alertView width */
    let kAlertViewWidth: CGFloat = 275.0
    /** alertView height */
    let kAlertViewHeight: CGFloat = 73.0
    
    
    /** 背景 */
    private var backView: UIView?
    /** 提示语 */
    private var titleLabel: UILabel?
    /** 取消button */
    private var cancelBtn: UIButton?
    /** 确定button */
    private var playBtn: UIButton?
    
    /** 代理 */
    var delegate: JHKPlayerFlowAlertDelegate?
    
    /** 流量大小text */
    private var titleText: String?
    
    
    //MARK: init
    init(frame: CGRect, flowBitStr: String) {
        titleText = flowBitStr
        super.init(frame: frame)
        self.setupSubViews(frame: frame)
    }
    
    //MARK: setupSubViews
    private func setupSubViews(frame: CGRect) {

        self.backgroundColor = UIColor.clear
        
        backView = UIView.init(frame: CGRect(x: (self.bounds.size.width - kAlertViewWidth) / 2, y: (self.bounds.size.height - kAlertViewHeight) / 2, width: kAlertViewWidth, height: kAlertViewHeight))
        backView?.backgroundColor = HexColor(rgbValue: 0x000000)
        backView?.alpha = 0.7
        self.addSubview(backView!)
        
        titleLabel = UILabel.init(frame: CGRect(x: (self.bounds.size.width - kAlertViewWidth) / 2, y: (self.bounds.size.height - kAlertViewHeight) / 2 + 12, width: kAlertViewWidth, height: 15))
        titleLabel?.textColor = self.HexColor(rgbValue: 0xFFFFFF)
        titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel?.text = "正在使用非WiFi网络，播放将产生流量"
        titleLabel?.textAlignment = .center
        self.addSubview(titleLabel!)
        
        cancelBtn = UIButton.init(type: .contactAdd)
        cancelBtn = UIButton.init(frame: CGRect(x: (self.bounds.size.width - kAlertViewWidth) / 2 + 33.5, y: (self.bounds.size.height - kAlertViewHeight) / 2 + 37.0, width: 90.0, height: 24.0))
        cancelBtn?.alpha = 0.9
        cancelBtn?.layer.cornerRadius = 10.0
        cancelBtn?.setTitle("取消", for: .normal)
        cancelBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cancelBtn?.backgroundColor = self.HexColor(rgbValue: 0xFFFFFF)
        cancelBtn?.setTitleColor(HexColor(rgbValue: 0x000000), for: .normal)
        cancelBtn?.addTarget(self, action: #selector(clickBtn(button:)), for: .touchUpInside)
        self.addSubview(cancelBtn!)
        
        playBtn = UIButton.init(type: .contactAdd)
        playBtn = UIButton.init(frame: CGRect(x: (self.bounds.size.width - kAlertViewWidth) / 2 + 147.5, y: (self.bounds.size.height - kAlertViewHeight) / 2 + 37.0, width: 90.0, height: 24.0))
        playBtn?.alpha = 0.9
        playBtn?.layer.cornerRadius = 10.0
        playBtn?.setTitle(titleText!, for: .normal)
        playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        playBtn?.backgroundColor = self.HexColor(rgbValue: 0x18BC84)
        playBtn?.setTitleColor(HexColor(rgbValue: 0xFFFFFF), for: .normal)
        playBtn?.setImage(UIImage.imageInBundle(named: "player_volume"), for: .normal)
        playBtn?.addTarget(self, action: #selector(clickBtn(button:)), for: .touchUpInside)
        playBtn?.titleEdgeInsets = UIEdgeInsetsMake(4.5, -8, 4.5, 0)
        playBtn?.imageEdgeInsets = UIEdgeInsetsMake(5.7, 11.5, 5.7, 66.5)
        self.addSubview(playBtn!)
    }
    
    @objc func clickBtn(button: UIButton) {
        if button == cancelBtn {
            self.delegate?.clickPlayerFlowAlert(type: JHKPlayerFlowClickType.JHK_PLAYERFLOWALERT_CLICKBTN_CANCELTYPE.rawValue)
        } else {
            self.delegate?.clickPlayerFlowAlert(type: JHKPlayerFlowClickType.JHK_PLAYERFLOWALERT_CLICKBTN_PLAYTYPE.rawValue)
        }
    }
    
    private func HexColor(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
