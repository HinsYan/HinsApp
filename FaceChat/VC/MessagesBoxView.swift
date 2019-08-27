//
//  MessagesBoxView.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/27.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM
import SDWebImage

class MessagesBoxView: UIView {

    var swipe: HinsEditCardTransition!
    var view1: VideoMessageView!
    var view2: VideoMessageView!
    
    var readMessages = [AVIMVideoMessage]()
    var messagesData = [AVIMVideoMessage]()
    var urls = [URL]()
    var currentIndex: Int = 0
    
    var controller: ChatVC!
    
    var conversation:AVIMConversation!
    var chatUser: AVUser!
    
    var videoURL: URL!
    var playerSpeed: Float = 1.0
    
    @IBOutlet weak var btnSend: BTNAvatarView!
    @IBOutlet weak var btnMessages: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var lbeStatus: UILabel!
    
    var cellStatus: BTNContactCellStatus = .normal {
        didSet {
            switch cellStatus {
            case .newMessages:
                lbeStatus.text = "📮点击查看新消息"
            case .noMessages:
                lbeStatus.text = "暂无最新消息"
            case  .cancel:
                lbeStatus.text = "点击取消发送"
            case .sending:
                lbeStatus.text = "消息正在发送中..."
            case .sendSuccess:
                lbeStatus.text = "消息发送成功"
            case .sendFail:
                lbeStatus.text = "消息发送失败"
            default:
                lbeStatus.text = "长按给他发消息"
            }
        }
    }

    
    
    lazy var miniCamera: BTNCameraView! = {
      
        let minCameraView = Bundle.main.loadNibNamed("BTNCameraView", owner: self, options: nil)?.first as! BTNCameraView
        minCameraView.layer.opacity = 0.0
        //注意这里是先先确定大小 再确定父视图 最后算位置
        let cameraWidth = self.bounds.width/3
        minCameraView.frame = CGRect(x: cameraWidth, y: self.bounds.height, width: cameraWidth, height: cameraWidth/kBTNScreenRatio)
        addSubview(minCameraView)
        minCameraView.layoutIfNeeded()
        minCameraView.filterView.layer.cornerRadius = kBTNWindowCornerRadii/3
        minCameraView.filterView.clipsToBounds = true
        minCameraView.backgroundColor = UIColor.clear
        minCameraView.addShadowWith(color: UIColor.black, opacity: nil, radius: nil, offset: CGSize.zero)
        return minCameraView
    }()
    
    
    var currentMessageView: VideoMessageView! {
        return subviews[1] as! VideoMessageView
    }
    
    var nextMessageView: VideoMessageView! {
        return subviews[0] as! VideoMessageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ininViews()
    }

    
    @IBAction func actionMessage(_ sender: Any) {
        swipe.startTransitionWith(direction: .swipeLeft)
    }
    @IBAction func actionMore(_ sender: Any) {
        if playerSpeed == 1.0 {
            playerSpeed = 1.5
            btnMore.setTitle("\(playerSpeed)x", for: .normal)
            currentMessageView.videoPreview.moviePlayer.rate = playerSpeed
            currentMessageView.videoPreview.moviePlayerRate = playerSpeed
            return
        }
        if playerSpeed == 1.5 {
            playerSpeed = 2.0
            btnMore.setTitle("\(Int(playerSpeed))x", for: .normal)
            currentMessageView.videoPreview.moviePlayer.rate = playerSpeed
            currentMessageView.videoPreview.moviePlayerRate = playerSpeed
            return
        }
        if playerSpeed == 2.0 {
            playerSpeed = 1.0
            btnMore.setTitle("\(Int(playerSpeed))x", for: .normal)
            currentMessageView.videoPreview.moviePlayer.rate = playerSpeed
            currentMessageView.videoPreview.moviePlayerRate = playerSpeed
            return
        }
        
    }
    
    func animationForSwipeBegin() {
        
    }
    
    func ininViews() {
        
        self.backgroundColor = UIColor.black
        btnMessages.layer.cornerRadius = btnMessages.bounds.width/2
        btnMessages.layer.masksToBounds = true
        
        btnMore.layer.cornerRadius = btnMore.bounds.width/2
        btnMore.layer.masksToBounds = true
        btnMore.setTitle("1x", for: .normal)
       
        btnSend.delegate = self
        
        view1 = Bundle.main.loadNibNamed("VideoMessageView", owner: self, options: nil)?.first as! VideoMessageView
        view1.frame = self.bounds
        view1.layoutIfNeeded()
        addSubview(view1)
        sendSubviewToBack(view1)
        
        view2 = Bundle.main.loadNibNamed("VideoMessageView", owner: self, options: nil)?.first as! VideoMessageView
        view2.frame = self.bounds
        view2.layoutIfNeeded()
        addSubview(view2)
        sendSubviewToBack(view2)
        
        let url1 = URL(string: "http://lc-bt74kuq7.cn-n1.lcfile.com/PBj1dQQNL08VNCDGAUp3LIA.mov")!
        let url2 = URL(string: "http://lc-bt74kuq7.cn-n1.lcfile.com/CWcYeMNZjIeKhB16nrvbDfA.mov")!
        let url3 = URL(string: "http://lc-bt74kuq7.cn-n1.lcfile.com/PBj1dQQNL08VNCDGAUp3LIA.mov")!
        let url4 = URL(string: "http://lc-bt74kuq7.cn-n1.lcfile.com/CWcYeMNZjIeKhB16nrvbDfA.mov")!
        
        urls = [url1,url2,url3,url4]

        cellStatus = .normal
        
        print(self.subviews)
    
    }
    
    func getPreLoadVideoMessagesURL(maxCount: Int) -> [URL] {
        var urls = [URL]()
        
        if messagesData.count == 2 || messagesData.count == 1 || messagesData.count == 0 {
            return urls
        }
        
        for message in messagesData {
            urls.append(URL(string: (message.file?.url())!)!)
        }
        
        if maxCount < urls.count {
            let a = Array(urls[2...maxCount])
            print(a)
            return Array(urls[2...maxCount])
        } else {
            let arrayCount =  urls.count
            let a = Array(urls[2..<arrayCount])
            print(a)
            return Array(urls[2..<arrayCount])
        }

    }
    
    func configBox(currentIndex: Int) {
        
        let dataCount =  messagesData.count
        btnMessages.setTitle(String(dataCount), for: .normal)

        ShortMediaManager.share()!.resetPreloading(withMediaUrls: getPreLoadVideoMessagesURL(maxCount: 3))

        if currentIndex == 0 && currentIndex < dataCount {
            if dataCount == 1 {
                if let presentingVC = controller.presentingViewController {
                    swipe = HinsEditCardTransition(fromView: currentMessageView, toView: presentingVC.view, scaleView: nil)
                    swipe.transitionDelegate = self
                    nextMessageView.layer.opacity = 0.0
                    self.backgroundColor = UIColor.clear
                }
            } else {
                swipe = HinsEditCardTransition(fromView: currentMessageView, toView: nextMessageView, scaleView: nil)
                swipe.transitionDelegate = self
            }
        
            currentMessageView.videoPreview.assetVideo = HinsAssetVideo(cacheURL: URL(string: (messagesData.first!.file?.url())!)!)
            print("为第一个Player配置了播放URL")
            print(currentMessageView.videoPreview.assetVideo?.cacheURL)
            
            let avatarURL = URL(string: chatUser.object(forKey: "avatar") as! String)
            btnSend.imgViewAvatar!.sd_setImage(with: avatarURL, placeholderImage: nil)
            currentMessageView.btnAvatar.sd_setImage(with: avatarURL, for: .normal, completed: nil)
            currentMessageView.lbeName.text = chatUser.object(forKey: "nickName") as? String
            currentMessageView.lbeTime.text = updateTimeToCurrennTime(timeStamp: Double(messagesData.first!.sendTimestamp))
      
        }
        
        if 1 < dataCount {
            
            nextMessageView.videoPreview.assetVideo = HinsAssetVideo(cacheURL: URL(string: (messagesData[1].file?.url()!)!)!)
            print("为第一个Player配置了播放URL")
            print(nextMessageView.videoPreview.assetVideo?.cacheURL)
            let avatarURL = URL(string: chatUser.object(forKey: "avatar") as! String)
            btnSend.imgViewAvatar!.sd_setImage(with: avatarURL, placeholderImage: nil)
            nextMessageView.btnAvatar.sd_setImage(with: avatarURL, for: .normal, completed: nil)
            nextMessageView.lbeName.text = chatUser.object(forKey: "nickName") as? String
            nextMessageView.lbeTime.text = updateTimeToCurrennTime(timeStamp: Double(messagesData.first!.sendTimestamp))
        }
        
    }
    
    deinit {
        print("xi懊悔了")
    }
    
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    func updateTimeToCurrennTime(timeStamp: Double) -> String {
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        print(currentTime,   timeStamp, "sdsss")
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        //时间差
        let reduceTime : TimeInterval = currentTime - timeSta
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        //不满足上述条件---或者是未来日期-----直接返回日期
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
        return dfmatter.string(from: date as Date)
    }
}

extension MessagesBoxView: HinsEditCardTransitionDelegate {
    
    func willBgeinTransition(transition: HinsEditCardTransition, direction: HinsViewSwipeDirection) {
        UIView.animate(withDuration: 0.3, animations: {
            let transY = self.bounds.height - self.bottomContainer.frame.origin.y
            self.bottomContainer.transform = CGAffineTransform.init(translationX: 0, y: transY)
        }, completion: nil)
    }
    
    
    func didEndTransition(transition: HinsEditCardTransition, isSuccess: Bool) {

        if isSuccess {
            if transition.swipeDirection == .swipeLeft {
                //messagesData.remove(at: currentIndex)
                print("shanchu")
                messagesData.removeFirst()
                btnMessages.setTitle(String(messagesData.count), for: .normal)
                btnMore.setTitle("1x", for: .normal)
                currentMessageView.layoutIfNeeded()
                nextMessageView.layoutIfNeeded()
            }
        }
        
        if isSuccess {
            if messagesData.count == 0 {
                ShortMediaManager.share()!.cleanCache()
                controller.dismiss(animated: true, completion: nil)
                return
            }
            currentMessageView.videoPreview.stopPlayVideo()
            currentMessageView.removeGestureRecognizer(swipe.panGesture)
            exchangeSubview(at: 0, withSubviewAt: 1)
            
            if messagesData.count == 1 {
                if let presentingVC = controller.presentingViewController {
                    transition.fromView = currentMessageView
                    transition.toView = presentingVC.view
                    nextMessageView.layer.opacity = 0.0
                    self.backgroundColor = UIColor.clear
                }
                
            }else{
                transition.fromView = currentMessageView
                transition.toView = nextMessageView
            }
            
            currentIndex += 1
            configBox(currentIndex: currentIndex)
            currentMessageView.videoPreview.startPlayVideo()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomContainer.transform = CGAffineTransform.identity

        }, completion: nil)
        
        print(swipe.panGesture.isEnabled)
        print(swipe.panGesture)
        
    }
}

extension MessagesBoxView: BTNAvatarViewDelegate {
    
    func willStartScaleAnimation(avatarView: BTNAvatarView) {
        currentMessageView.videoPreview.pausePlayVideo()
        UIView.animate(withDuration: 0.3, animations: {
            self.miniCamera.layer.position = self.center
            self.miniCamera.layer.opacity = 1.0
        }) { (success) in
        }
        self.miniCamera.startAnimation()
        HinsCamera.shared.startToRecord(Orientation: UIDeviceOrientation.portrait)
    }
    
    func WillEndScaleAnimation(avatarView: BTNAvatarView) {
        cellStatus = .cancel
        currentMessageView.videoPreview.resumePlayVideo()
        UIView.animate(withDuration: 0.3, animations: {
            let cameraWidth = self.bounds.width/3
            self.miniCamera.frame = CGRect(x: cameraWidth, y: self.bounds.height, width: cameraWidth, height: cameraWidth/kBTNScreenRatio)
            self.miniCamera.layer.opacity = 0.0
        }) { (success) in
        }
        self.miniCamera.endAnimation()
        HinsCamera.shared.endToRecoed { (url) in
            self.videoURL = url
        }
    }
    
    func didEndAllAniamtion(avatarView: BTNAvatarView, success: Bool) {
        if success {
            print("发送")
            if let url = self.videoURL {
                self.actionSendMessage(url: url)
            }
        }else{
            print("取消发送")
            self.cellStatus = .normal
            if let url = self.videoURL {
                HinsCamera.shared.checkWriteFileURLCorrect(url: url)
            }
        }
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
                self.cellStatus = .normal
            })
            
        }
        
    }

}
