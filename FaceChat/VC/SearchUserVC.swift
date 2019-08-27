//
//  SearchUserVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/20.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM
import Contacts
import MessageUI

class SearchUserVC: UIViewController {

  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    
    var searchedUser = [AVUser?]()
    var contactSource = [CNContact]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        
        let contactStore = CNContactStore()
        BTNHelper.shard.checkContactStoreAuth(contactStore: contactStore) { (contacts) in
            if contacts != nil {
                self.contactSource = contacts!
            }
        }
    
        self.numberTF.keyboardType = .numberPad
        self.numberTF.addTarget(self, action: #selector(self.textFiledEditDidChanged(_:)), for: .editingChanged)
        self.numberTF.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self

        
        

        
        // Do any additional setup after loading the view.
    }
    
    
    func initNavBar() {
        
        self.title = "添加好友"
        
        if let nav = self.navigationController {
            
            nav.navigationBar.barTintColor = UIColor.white
            nav.navigationBar.backgroundColor = UIColor.white
            nav.navigationBar.setBackgroundImage(UIImage() , for: .any, barMetrics: .default)
            nav.navigationBar.addShadowWith(color: UIColor.lightGray, opacity: nil, radius: 2, offset: CGSize.init(width: 0, height: 4))
            nav.navigationBar.tintColor = UIColor.black
            //nav.navigationBar.hideBottomHairline()
            
            let btnClose = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(self.actionClose))
            self.navigationItem.setLeftBarButton(btnClose, animated: false)
        }
        
    }
    
    @objc func actionClose(){
        if let nav = self.navigationController {
            nav.dismiss(animated: true, completion: nil)
        }
    }

    
    @IBAction func actionSearch(_ sender: Any) {
        if numberTF.text?.count != 11 {
            self.searchedUser = []
            self.tableView.reloadData()
            self.showAlertWith(title: "输入错误", message: "请检查11位手机号输入是否正确") {
            }
            return
        }
        
        let userQuery = AVQuery(className: "_User")
        //todo: 查询手机号而不是username，查询username是为了调试
        userQuery.whereKey("username", equalTo: numberTF.text!)
        userQuery.findObjectsInBackground { (searchedUsers, error) in
            if error != nil {
                self.showAlertWith(title: "添加好友查询手机号失败", message: error!.localizedDescription, completed: {
                })
            } else {
                if searchedUsers!.count > 0 {
                    let user = searchedUsers!.first! as! AVUser
                    print(user.username!)
                    self.searchedUser.append(user)
                    
                } else {
                    self.searchedUser.append(nil)
                    
                }
                let indexSet = IndexSet(arrayLiteral: 0)
                self.tableView.reloadSections(indexSet, with: .automatic)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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


}


extension SearchUserVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let firstUser = searchedUser.first {
                return 1
            }else{
                return 0
            }
        case 1:
            return 2
        default:
            return contactSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: kBTNSearchInfoTableCellIdentifier, for: indexPath) as! BTNSearchInfoTableCell
            if let firstUser = searchedUser.first {
                if let user = firstUser {
                    cell.nameLbe.text = user.username!
                    cell.avatarView.sd_setImage(with: URL(string: user.object(forKey: "avatar") as! String), completed: nil)
                    cell.lbeNameIcon.text = ""
                    cell.infoLbe.text = "来自数据库搜索"
                    cell.lbeAdd.text = "添加"
                } else {
                    cell.nameLbe.text = numberTF.text!
                    cell.lbeNameIcon.text = ""
                    cell.infoLbe.text = "好友未加入，您可以邀请他"
                    cell.lbeAdd.text = "👉🏻邀请"
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: kBTNInviteTableCellIdentifier, for: indexPath) as! BTNInviteTableCell
            if indexPath.row == 0 {
                cell.infoLbe.text = "邀请微信好友"
                cell.icon.image = UIImage(named: "iconWechat")
            }
            if indexPath.row == 1 {
                cell.infoLbe.text = "邀请QQ好友"
                cell.icon.image = UIImage(named: "iconQQ")
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: kBTNSearchInfoTableCellIdentifier, for: indexPath) as! BTNSearchInfoTableCell
            cell.nameLbe.text = contactSource[indexPath.row].familyName + contactSource[indexPath.row].givenName
            if cell.nameLbe.text != "" {
                let str = String((cell.nameLbe.text?.prefix(1))!)
                cell.lbeNameIcon.text = str
            }
            cell.infoLbe.text = "来自手机通讯录"
            cell.lbeAdd.text = "👉🏻邀请"
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let hearder = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
//        let lbe = UILabel(frame: CGRect(x: 16, y: 0, width: hearder.bounds.width - 32, height: 30))
//        lbe.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
//        hearder.addSubview(lbe)
//        hearder.backgroundColor = UIColor.red
//
//
//        return hearder
//
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if let firstUser = searchedUser.first {
                if let user = firstUser {
                    return "已找到好友🎉"
                } else{
                    return "未找到好友🌚"
                }
            }else{
                return "搜索结果将会出现在这里😁"
            }
        case 1:
            return "邀请好友"
        default:
            return "邀请手机通讯录好友"
        }
    }
}

extension SearchUserVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 68
        case 1:
            return 68
        default:
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if let firstUser = searchedUser.first {
                if let user = firstUser {
                    BTNUserManager.shard.currentUser.follow(user.objectId!, andCallback: { (success, error) in
                        if success {
                            self.createConversation(withUser: user, completed: { (conversation) in
                                print(conversation.name!)
                                self.showAlertWith(title: "成功添加好友", message: "快去和朋友视频交流吧！", completed: {
                                    
                                    self.dismiss(animated: true, completion: nil)
                                })
                            })
                        } else {
                            self.showAlertWith(title: "添加好友失败", message: error!.localizedDescription, completed: {
                            })
                        }
                    })

                } else{
                    print("fasongxiaoxi")
                    let number = numberTF.text!
                    sendMessageFor(number: number)
                }
            }
        case 1:
            if indexPath.row == 0 {
                print("邀请微信好友")
            }
            if indexPath.row == 1 {
                print("邀请QQ好友")
            }
        default:
            print("fasongxiaoxi")
            if let phoneNumber = contactSource[indexPath.row].phoneNumbers.first {
                let number = (phoneNumber.value as CNPhoneNumber).stringValue
                sendMessageFor(number: number)
            } else {
                self.showAlertWith(title: "出错啦！", message: "该联系号码不存在!", completed: {
                })
            }
            
        }
        
    }
}

extension SearchUserVC: UITextFieldDelegate {
    
    @objc func textFiledEditDidChanged(_ textField: UITextField) {
        print("changed")
        if (textField.text?.count)! > 11 {
            textField.text = String(textField.text!.prefix(11))
        } else {
            searchedUser = []
            tableView.reloadData()
        }
    }
    
}

extension SearchUserVC: MFMessageComposeViewControllerDelegate {
    
    func sendMessageFor(number: String!) {
        //判断设备是否能发短信(真机还是模拟器)
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            //短信的内容,可以不设置
            controller.body = "发短信"
            //联系人列表
            controller.recipients = [number]
            //设置代理
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        } else {
            print("本设备不能发短信")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        //判断短信的状态
        switch result{
        case .sent:
            print("短信已发送")
        case .cancelled:
            print("短信取消发送")
        case .failed:
            print("短信发送失败")
        default:
            print("短信已发送")
            break
        }
    }
}
