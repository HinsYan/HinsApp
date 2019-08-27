//
//  BTNSettingVC.swift
//  Chatter
//
//  Created by yantommy on 2017/1/1.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit
import AVOSCloudIM

public let kBTNSettingVC = "kBTNSettingVC"
class BTNSettingVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()

        initNavBar()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Navigation
extension BTNSettingVC {

    func initNavBar() {
        
        self.title = "设置"
        
        if let nav = self.navigationController {
            
            nav.navigationBar.barTintColor = UIColor.white
            nav.navigationBar.backgroundColor = UIColor.white
            nav.navigationBar.setBackgroundImage(UIImage() , for: .any, barMetrics: .default)
            nav.navigationBar.addShadowWith(color: UIColor.lightGray, opacity: nil, radius: 2, offset: CGSize.init(width: 0, height: 4))
            nav.navigationBar.tintColor = UIColor.black
            
            let btnClose = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(self.actionClose))
            self.navigationItem.setLeftBarButton(btnClose, animated: false)
        }
        
        
        
    }
    
    @objc func actionClose(){
        if let nav = self.navigationController {
            nav.dismiss(animated: true, completion: nil)
        }
    }
    

    
}

extension BTNSettingVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kBTNSettingTableCellIdentifier, for: indexPath) as! BTNSettingTableCell
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let sex = (BTNUserManager.shard.currentUser.object(forKey: "sex") as! Bool) ? "👧" : "👦"
                let nickName = BTNUserManager.shard.currentUser.object(forKey: "nickName") as! String
                cell.lbeTitle.text = "\(sex)修改个人信息"
                cell.lbeDetail.text = nickName
                let avatar = BTNUserManager.shard.currentUser.object(forKey: "avatar")
                cell.imgIcon.sd_setImage(with: URL(string: avatar as! String), completed: nil)
                cell.imgIcon.layer.cornerRadius = cell.imgIcon.bounds.height/2
                cell.imgIcon.layer.masksToBounds = true
            }
            if indexPath.row == 1 {
                cell.lbeTitle.text = "📱手机号码"
                cell.lbeDetail.text = BTNUserManager.shard.currentUser.username!
            }
        case 1:
            if indexPath.row == 0 {
                cell.lbeTitle.text = "🎉分享给微信好友"
                cell.lbeDetail.text = ""
            }
            if indexPath.row == 1 {
                cell.lbeTitle.text = "🎉分享给QQ好友"
                cell.lbeDetail.text = ""
            }
        default:
            if indexPath.row == 0 {
                cell.lbeTitle.text = "🔨版本号"
                cell.lbeDetail.text = "beta1.0"
            }
            if indexPath.row == 1 {
                cell.lbeTitle.text = "🤐用户协议"
                cell.lbeDetail.text = ""
            }
            if indexPath.row == 2 {
                cell.lbeTitle.text = "👉🏻退出登录"
                cell.lbeDetail.text = ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 74
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "基本"
        case 1:
            return "分享"
        default:
            return "其他"
        }

    }
}
extension BTNSettingVC: UITableViewDelegate {


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        if indexPath.section == 0 && indexPath.row == 0 {
            if let nav = self.navigationController {
                 let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "kBTNSettingUserInfoVC") as! BTNSettingUserInfoVC
                nav.pushViewController(destinVC, animated: true)
            }
        }
        
        
        if indexPath.section == 2 && indexPath.row == 2 {
            BTNUserManager.shard.closeIMClientService {
                AVUser.logOut()
                let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
                self.present(destinVC, animated: true, completion: nil)
            }
        }
        
        
        if indexPath.section == 2 && indexPath.row == 1 {
        
            let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "kPrivacyInfoVC")
            self.present(destinVC, animated: true, completion: nil)
        }
       
    }
    
}
