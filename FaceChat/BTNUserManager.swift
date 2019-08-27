//
//  BTNUserManager.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/20.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM

class BTNUserManager: NSObject {
    
    
    static let shard = BTNUserManager()
    
    
    var client: AVIMClient!
    
    var currentUser: AVUser!
    
    var followeeUsers: [AVUser] {
            //查询联系人
        let query = AVUser.followeeQuery(AVUser.current()!.objectId!)
        query.includeKey("followee")
        return query.findObjects() as! [AVUser]
    }
    
    func initImService(completed: @escaping () -> Void) {
        currentUser = AVUser.current()
        client = AVIMClient(clientId: AVUser.current()!.username!)
        openIMClientService { completed() }
        
    }
    func openIMClientService(completed: @escaping () -> Void) {
        client.open { (success, error) in
            if error == nil {
                print("打开\(self.client.clientId)客户端的即时通讯服务成功")
                completed()
            } else {
                print("打开\(self.client.clientId)客户端的即时通讯服务失败\(error!.localizedDescription)")
            }
        }
    }
    
    func closeIMClientService(completed: @escaping () -> Void) {
        client.close { (success, error) in
            if error == nil {
                print("关闭\(self.client.clientId)客户端的即时通讯服务成功")
                completed()
            } else {
                print("关闭\(self.client.clientId)客户端的即时通讯服务失败\(error!.localizedDescription)")
            }
        }
    }
    
    func getRecentConversations(cachePolicy: AVIMCachePolicy, completed: @escaping (_ conversations: [AVIMConversation]?) -> Void) {
        
        let conversationQuery = self.client.conversationQuery()
        conversationQuery.cachePolicy = cachePolicy
        conversationQuery.findConversations(callback: { (objects, error) in
            if error == nil {
                let conversations = objects as! [AVIMConversation]
                completed(conversations)
                print("查询会话成功，当先用户最近有\(conversations.count)个会话")
            } else {
                completed(nil)
                print("查询当前用户最近的会话错误\(error!.localizedDescription)")
            }
        })

    }
    
    func getUnReadMessageFor(con: AVIMConversation,completed: @escaping (_ messages: [AVIMVideoMessage]?) -> Void) {
        if let unReadValue = con.object(forKey: "unReadMessDic") {
            let unReadMessagesMembers = unReadValue as! [String : [String]]

            if var unreadMessValue = unReadMessagesMembers[BTNUserManager.shard.currentUser.username!] {
                print("当前会话的用户在会话: \(con.name!)存在\(unreadMessValue.count)条未读消息")
                var getedMessages = [AVIMVideoMessage]()
                var getedMessagesID = [String]()
                func aaaa(lastQueryedMessage: AVIMVideoMessage?) {
                    
                    var lastQueryMessID: String? = nil
                    var lastTimestamp: Int64 = 0
                    if let lastMe = lastQueryedMessage {
                        lastQueryMessID = lastMe.messageId
                        lastTimestamp = lastMe.sendTimestamp
                    }
                    con.queryMediaMessagesFromServer(with: .video, limit: UInt(unreadMessValue.count), fromMessageId: lastQueryMessID, fromTimestamp: lastTimestamp) { (messages, error) in
                        
                        if error == nil {
                            //print("从云端查到消息数量：\(messages!.count)")
                            var lastMessage: AVIMVideoMessage!
                            for message in messages! {
                                let videoMessage = message as! AVIMVideoMessage
                                lastMessage = videoMessage
                                print(lastMessage.messageId!)
                                //print("clientID: \(videoMessage.clientId)")
                                if videoMessage.clientId! != BTNUserManager.shard.client.clientId {
                                    //print("查到一条消息")
                                    
                                    if unreadMessValue.contains(videoMessage.messageId!) {
                                        if !getedMessagesID.contains(videoMessage.messageId!) {
                                            getedMessages.append(videoMessage)
                                            getedMessagesID.append(videoMessage.messageId!)
                                       }
                                    } else {
                                        print("消息已读或不是要找的消息ID")
                                    }
                                }
                            }
                            if getedMessages.count >= unreadMessValue.count {
                                print("已拿到当前会话存在的\(getedMessages.count)条未读消息")
                                completed(getedMessages)
                                return
                            } else {
                                print("遍历一次云端数据共拿到了\(getedMessages.count)条未读消息")
                                print(lastMessage.messageId)
                                aaaa(lastQueryedMessage: lastMessage)
                            }
                        } else { print(error!.localizedDescription) }
                    }
                    
                }
                aaaa(lastQueryedMessage: nil)
                
            }
            
        }
    }
    
    func sendUnReadCountMarkForConversation(con: AVIMConversation, message: AVIMVideoMessage) {
    
        for memberID in con.members! {
            if memberID != BTNUserManager.shard.currentUser.username! {
                if let unReadMessagesValue = con.object(forKey: "unReadMessDic") {
                    var unReadMessagesMembers = unReadMessagesValue as! [String : [String]]
                    print(unReadMessagesMembers)
                    if var unreadMessValue = unReadMessagesMembers[memberID] {
                        unReadMessagesMembers[memberID]!.append(message.messageId!)
                        print("1unreadMessageID: \(message.messageId!)")
                        con.setObject(unReadMessagesMembers, forKey: "unReadMessDic")
                        print(unReadMessagesMembers)
                        con.update { (success, error) in
                            if error == nil {
                                print("为会话的成员\(memberID)更新未读消息ID：\(message.messageId)成功")
                            }else{ print(error!.localizedDescription) }
                        }
                    } else {
                        unReadMessagesMembers[memberID] = [String]()
                        unReadMessagesMembers[memberID]!.append(message.messageId!)
                        print("2unreadMessageID: \(message.messageId!)")
                        print(unReadMessagesMembers)
                        con.setObject(unReadMessagesMembers, forKey: "unReadMessDic")
                        con.update { (success, error) in
                            if error == nil {
                                print("为会话的成员\(memberID)更新未读消息ID：\(message.messageId)成功")
                            }else{ print(error!.localizedDescription) }
                        }

                    }
                    
                } else {
                    var unReadMessagesMembers = Dictionary<String , [String]>()
                    if var unreadMessValue = unReadMessagesMembers[memberID] {
                        unReadMessagesMembers[memberID]!.append(message.messageId!)
                        print("3unreadMessageID: \(message.messageId!)")
                        con.setObject(unReadMessagesMembers, forKey: "unReadMessDic")
                        con.update { (success, error) in
                            if error == nil {
                                print("为会话的成员\(memberID)更新未读消息ID：\(message.messageId)成功")
                            }else{ print(error!.localizedDescription) }
                        }
                    } else {
                        unReadMessagesMembers[memberID] = [String]()
                        unReadMessagesMembers[memberID]!.append(message.messageId!)
                        print("4unreadMessageID: \(message.messageId!)")
                        con.setObject(unReadMessagesMembers, forKey: "unReadMessDic")
                        con.update { (success, error) in
                            if error == nil {
                                print("为会话的成员\(memberID)更新未读消息ID：\(message.messageId)成功")
                            }else{ print(error!.localizedDescription) }
                        }
                        
                    }

                }
                
                
            }
        }
        

    
    }
    
    
    
    func addFriend(username: String, completed: @escaping (_ info: String) -> Void) {
        
        let userQuery = AVQuery(className: "_User")
        //todo: 查询手机号而不是username，查询username是为了调试
        userQuery.whereKey("username", equalTo: username)
        userQuery.findObjectsInBackground { (searchedUsers, error) in
            if error != nil {
                completed("findObjectFailed")
            } else {
                if searchedUsers!.count > 0 {
                    let user = searchedUsers!.first! as! AVUser
                    self.currentUser.follow(user.objectId!, andCallback: { (success, error) in
                        if success {
                            self.createConversation(withUser: user, completed: { (conversation) in
                                completed("follUserSuccess")
                            })
                        } else {
                            completed("follUserFailed")
                        }
                    })
                    
                } else {
                    completed("noUserFindInBackground")
                }
            }
        }

    }

    func createConversation(withUser: AVUser, completed: @escaping (_ conversation: AVIMConversation) -> Void) {
        
        let query = BTNUserManager.shard.client.conversationQuery()
        let currentUser =  BTNUserManager.shard.currentUser
        print(currentUser?.username!)
        // query.whereKey("m", containedIn: [currentUser!.username!, withUserName])
        query.whereKey("m", sizeEqualTo: 2)
        query.whereKey("m", containsAllObjectsIn: [currentUser!.username!, withUser.username!])
        print("开始query")
        query.findConversations(callback: { (objects, error) in
            if error == nil {
                print("find成功")
                if objects!.count == 0 {
                    print("不存在会话")
                    let conversationName = currentUser!.username! + "and" + withUser.username!
                    BTNUserManager.shard.client.createConversation(withName: conversationName, clientIds: [withUser.username!], callback: { (conversation, error) in
                        if error == nil {
                            print("创建会话成功\(conversation?.name!)")
                            completed(conversation!)
                        } else {
                            print("创建会话失败：\(error!.localizedDescription)")
                        }
                    })
                } else {
                    print("已存在会话")
                    print(objects!.count)
                    print(objects!)
                    completed(objects!.first!)
                }
            }
        })
        
        
    }

    
    
    func isInfoCompleted(completed: @escaping (_ isCompleted: Bool) -> Void) {
        let age = BTNUserManager.shard.currentUser.object(forKey: "age")
        let sex = BTNUserManager.shard.currentUser.object(forKey: "sex")
        let avatar = BTNUserManager.shard.currentUser.object(forKey: "avatar")
        let nickName = BTNUserManager.shard.currentUser.object(forKey: "nickName")
        
        if age != nil && sex != nil && avatar != nil && nickName != nil {
            completed(true)
        }else {
            completed(false)
        }
    }
    
}
