//
//  ChatVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/20.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM

class ChatVC: UIViewController {

    var messagesView: MessagesBoxView!
    
    var conversation: AVIMConversation!
    var messagesDataSource = [AVIMVideoMessage]()
    
    var chatUser: AVUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        messagesView = Bundle.main.loadNibNamed("MessagesBoxView", owner: self, options: nil)?.first as! MessagesBoxView
        messagesView.frame = self.view.bounds
        messagesView.layoutIfNeeded()
        view.addSubview(messagesView)
        view.sendSubviewToBack(messagesView)
        messagesView.messagesData = messagesDataSource
        messagesView.conversation = conversation
        messagesView.chatUser = chatUser
        messagesView.controller = self
        messagesView.configBox(currentIndex: messagesView.currentIndex)
        print("消息数量")
        print(messagesView.messagesData.count)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesView.currentMessageView.videoPreview.startPlayVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("cache的大小：")
        print(ShortMediaManager.share()!.totalCachedSizeStr())
        messagesView.currentMessageView.removeGestureRecognizer(messagesView.swipe.panGesture)
        messagesView.currentMessageView.videoPreview.stopPlayVideo()
        handleForUpdataUnreadMessages()

    }
    
    func handleForUpdataUnreadMessages() {
        var unReadMessageArry = [String]()
        for unReadMessage in messagesView.messagesData {
            unReadMessageArry.append(unReadMessage.messageId!)
        }
        var allDataUnreadDic = conversation.object(forKey: "unReadMessDic") as! [String:[String]]
        allDataUnreadDic[BTNUserManager.shard.currentUser.username!] = unReadMessageArry
        conversation.setObject(allDataUnreadDic, forKey: "unReadMessDic")
        conversation.update { (success, error) in
            if error == nil {
                print("更新当前用户在会话：\(self.conversation.name)中的未读消息成功")                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotifactionNameUpdateUnreadMessages), object: self, userInfo: ["conversationID": self.conversation.conversationId!])
            } else { print(error!.localizedDescription) }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


