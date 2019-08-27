//
//  BNTContactCollCell.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/29.
//  Copyright © 2016年 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM
import SDWebImage

let kBTNContactCollCellIdentifier = "kBTNContactCollCellIdentifier"

public enum BTNContactCellStatus: Int {
    case normal = 0
    case newMessages
    case noMessages
    case cancel
    case sending
    case sendSuccess
    case sendFail
}


class BTNContactCollCell: UICollectionViewCell {
    
  
    @IBOutlet weak var contactAvatar: BTNAvatarView!
    @IBOutlet weak var bgMaskView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var btnContactName: UIButton!
    @IBOutlet weak var lbeTime: UILabel!
    
    lazy var videoPreview: HinsVideoMessagePreView = {
        let preView = HinsVideoMessagePreView(frame: bgView.bounds)
            bgView.addSubview(preView)
        preView.progressLine.isHidden = true
        preView.layer.opacity = 0.0
        preView.videoPreviewView.backgroundColor = UIColor.clear
        
        return preView
    }()
    
    var viscousButton: MRViscousButton?
    // MARK: - !!! Todo
    var controller = UIViewController()
    
    
    lazy var tapToViewMessageGesture: UITapGestureRecognizer = {
        let gestuer = UITapGestureRecognizer(target: self, action: #selector(self.actionGotoChatting(_:)))
        self.contactAvatar.addGestureRecognizer(gestuer)
        return gestuer
    }()
    
    var videoURL: URL?
    
    var cellStatus: BTNContactCellStatus = .normal {
        didSet {
            switch cellStatus {
            case .newMessages:
                btnStatus.setTitle("📮点击查看新消息", for: .normal)
            case .noMessages:
                btnStatus.setTitle("暂无最新消息", for: .normal)
            case  .cancel:
                btnStatus.setTitle("点击取消发送", for: .normal)
            case .sending:
                btnStatus.setTitle("消息正在发送中...", for: .normal)
            case .sendSuccess:
                btnStatus.setTitle("消息发送成功.", for: .normal)
            case .sendFail:
                btnStatus.setTitle("消息发送失败", for: .normal)
            default:
                btnStatus.setTitle("长按发送消息", for: .normal)
            }
        }
    }
    
    var messagesDataSource: [AVIMVideoMessage] = [] {
        didSet {
            self.tapToViewMessageGesture.isEnabled = true
            if messagesDataSource.count != 0 {
                viscousButton?.isHidden = false
                viscousButton?.setTitle(String(messagesDataSource.count), for: .normal)
                self.cellStatus = .newMessages
                self.lbeTime.text = BTNHelper.shard.updateTimeToCurrennTime(timeStamp: Double(messagesDataSource.first!.sendTimestamp))
            } else {
                viscousButton?.isHidden = true
                self.cellStatus = .normal
            }
        }
    }
    
    var chatUser: AVUser? {
        didSet {
            if let user = chatUser {
                btnContactName.setTitle(user.object(forKey: "nickName") as! String, for: .normal)
                let avatarURL = URL(string: user.object(forKey: "avatar") as! String)
                contactAvatar.imgViewAvatar!.sd_setImage(with: avatarURL, placeholderImage: nil)
            } else {
                btnContactName.setTitle("", for: .normal)
                contactAvatar.imgViewAvatar!.sd_setImage(with: nil, completed: nil)
            }
        }
    }
    
    var conversation: AVIMConversation? {
        didSet {

            if let con = conversation {
                
                self.infoContainerView.isHidden = false
                self.contactAvatar.isHidden = false
                
                let formater = DateFormatter()
                formater.dateFormat = "HH:mm"
                self.lbeTime.text = formater.string(from: con.updateAt!)
                
                for clientID in con.members! {
                    if clientID != BTNUserManager.shard.client.clientId {
                        let chatUserQuery = AVQuery(className: "_User")
                        chatUserQuery.whereKey("username", equalTo: clientID)
                        chatUserQuery.findObjectsInBackground { (users, error) in
                            if error == nil && users!.count == 1 {
                                let user = users!.first as! AVUser
                                self.chatUser = user
                                print("开始为会话Id：\(con.name)查询用户ID：\(BTNUserManager.shard.currentUser.username!)的未读消息")
                                print("-----------------------------------")
                                BTNUserManager.shard.getUnReadMessageFor(con: con, completed: { (messages) in
                                    self.messagesDataSource = messages!
                                    print("更新当前会话ID：\(con.name)，UI显示的\(self.messagesDataSource.count)条未读消息")
                                    print("-----------------------------------")
                                })

                            }
                        }
                    }
                }
                
                
            } else {
                self.infoContainerView.isHidden = true
                viscousButton?.isHidden = true
                self.contactAvatar.isHidden = true
            }
            
        }
    }
    //改颜色
    var bgColor = UIColor() {
        didSet {
            self.backgroundColor = bgColor
            self.bgView.backgroundColor = bgColor
            self.contactAvatar.backgroundColor = bgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.conversation = nil
        self.chatUser = nil
        self.messagesDataSource = []
        
    }
    
    // 此处刷新后为正确的约束，在此修改UI相关
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
        
        contactAvatar.delegate = self
        initViews()
        
        // MARK: - Todo： 待优化 刷新布局
        contactAvatar.layoutSubviews()
        self.addViscousNotification()
        
        
    }

    func initViews(){
    
        bgMaskView.backgroundColor = UIColor.black
        bgMaskView.layer.opacity = 0.3
        
        self.infoContainerView.isHidden = true
        btnContactName.setTitle("", for: .normal)
        lbeTime.text = ""
        btnStatus.setTitle("", for: .normal)

    }
    
}

// MARK: -IBActionS
extension BTNContactCollCell {

    @objc func actionGotoChatting(_ sender: UIButton) {
        
        if messagesDataSource.isEmpty {
            let lastTitle = self.btnStatus.title(for: .normal)
            self.cellStatus = .noMessages
            self.tapToViewMessageGesture.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(Int(3.0)), execute: {
                self.cellStatus = .normal
                self.tapToViewMessageGesture.isEnabled = true
            })
            return
        }
        
        let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatVC
        destinVC.modalPresentationStyle = .overCurrentContext
        destinVC.messagesDataSource = self.messagesDataSource.reversed()
        destinVC.conversation = self.conversation
        destinVC.chatUser = self.chatUser
        self.controller.present(destinVC, animated: true, completion: nil)
    }
    
    @IBAction func actionShowContactInfo(_ sender: UIButton) {
        
        let userName = self.btnContactName.title(for: .normal)!
        
        let actionSheet = UIAlertController(title: "@\(userName)", message: "Info", preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.black
        let actionHide = UIAlertAction(title: "Hide", style: .default) { (action) in
            
        }
        
        let actionDelete = UIAlertAction(title: "Delete\(userName)?", style: .destructive) { (action) in
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        actionSheet.addAction(actionHide)
        actionSheet.addAction(actionDelete)
        actionSheet.addAction(actionCancel)
        controller.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func actionSendMessage(url: URL!) {
        
        let videoData = try? Data(contentsOf: url)
        
        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "YYYY-MM-dd-HH-mm-ss"
        let videoName = BTNUserManager.shard.currentUser.username! + "-" + formater.string(from: date) + ".mp4"
        let videoFile = AVFile(data: videoData!, name: videoName)
        let attr: [String : Any] = ["isRead" : false]
        let videoMessage = AVIMVideoMessage(text: nil, file: videoFile, attributes: nil)
        self.cellStatus = .sending
        self.conversation!.send(videoMessage, option: nil) { (success, error) in
            if error == nil {
                print("消息的放松成功对象为、\(self.conversation!.name)")
                print("消息的发松方为：\(videoMessage.clientId)")
                BTNUserManager.shard.sendUnReadCountMarkForConversation(con: self.conversation!, message: videoMessage)
                HinsCamera.shared.checkWriteFileURLCorrect(url: url)
                self.cellStatus = .sendSuccess
                
            } else {
                print("消息发送失败：\(error!.localizedDescription)")
                self.cellStatus = .sendFail
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(Int(3.0)), execute: {
                self.cellStatus = self.messagesDataSource.isEmpty ? .normal : .newMessages
            })

        }
        
    }
    
    
    
}

// MARK: - 录制相关准备（动画）
extension BTNContactCollCell: BTNAvatarViewDelegate {

    func readyForCapture() {
        infoContainerView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            
            self.bgView.transform = CGAffineTransform.init(a: 0.8, b: 0, c: 0, d: 0.8, tx: 0, ty: 0)
            
            self.infoContainerView.transform = CGAffineTransform.init(a: 1.3, b: 0, c: 0, d: 1.3, tx: 0, ty: 0)
            self.infoContainerView.layer.opacity = 0.0
            
            if let btnViscous = self.viscousButton {
                btnViscous.transform = CGAffineTransform.init(a: 0.8, b: 0, c: 0, d: 0.8, tx: btnViscous.bounds.width/2, ty: 0)
                btnViscous.layer.opacity = 0.0
            }
            
        }, completion: { (success) in
        })
        //开始录制
        let con = self.controller as! MainVC
        con.minCameraView.startAnimation()
        HinsCamera.shared.startToRecord(Orientation: UIDeviceOrientation.portrait)
        
    }
    
    func finishCapture(){
        //结束录制
        let con = self.controller as! MainVC
        con.minCameraView.endAnimation()
        HinsCamera.shared.endToRecoed { (url) in
            self.videoURL = url
            DispatchQueue.main.async {
                
                let video = HinsAssetVideo(cacheURL: url)
                self.videoPreview.assetVideo = video
                self.videoPreview.moviePlayer.volume = 0.0
                self.videoPreview.startPlayVideo()
                
                self.infoContainerView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
                    
                    self.bgView.transform = CGAffineTransform.identity
                    
                    self.infoContainerView.transform = CGAffineTransform.identity
                    self.infoContainerView.layer.opacity = 1.0
                    self.videoPreview.layer.opacity = 1.0
                    
                    if let btnViscous = self.viscousButton {
                        btnViscous.transform = CGAffineTransform.identity
                        btnViscous.layer.opacity = 1.0
                    }
                    
                }, completion: { (success) in
                    
                })

            }
        }

    }
    
    func willStartScaleAnimation(avatarView: BTNAvatarView) {
        self.tapToViewMessageGesture.isEnabled = false
        readyForCapture()
    }
    
    func WillEndScaleAnimation(avatarView: BTNAvatarView) {
        self.cellStatus = .cancel
        finishCapture()
    }
    
    func didEndAllAniamtion(avatarView: BTNAvatarView, success: Bool) {
        self.tapToViewMessageGesture.isEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.videoPreview.layer.opacity = 0.0
            self.videoPreview.stopPlayVideo()
        }
        if success {
            print("发送")
            if let url = self.videoURL {
               self.actionSendMessage(url: url)
            }
        }else{
            print("取消发送")
            self.cellStatus = self.messagesDataSource.isEmpty ? .normal : .newMessages
            if let url = self.videoURL {
                HinsCamera.shared.checkWriteFileURLCorrect(url: url)
            }
        }
        
    }
    
}


// MARK: - MRViscousButtonDelegate(消息提示圈相关)
extension BTNContactCollCell: MRViscousButtonDelegate {

    //添加
    func addViscousNotification(){
    
        // MARK: - Todo 细化
        let centerFrame = CGRect(x: contactAvatar.frame.maxX, y: contactAvatar.frame.maxY - contactAvatar.bounds.height/2, width: 25, height: 25)
        
        viscousButton = MRViscousButton(frame: centerFrame)
        viscousButton?.center = centerFrame.origin
        viscousButton?.delegate = self
        viscousButton?.setTitle("0", for: .normal)
        viscousButton?.backgroundColor = UIColor.red
        viscousButton?.setTitleColor(UIColor.white, for: .normal)
        viscousButton?.isHidden = true
        avatarContainerView.addSubview(viscousButton!)
        
    }
    //Delegate
    // MARK: - Todo 细化处理
    func viscousButtonDismissed(_ btn: MRViscousButton!) {
        print("清除了消息提示")
        print(btn.frame)
        btn.removeFromSuperview()
    }
}
