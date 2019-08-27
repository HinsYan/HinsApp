//
//  LoginVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/19.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM

class LoginVC: UIViewController {

    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var smsTF: UITextField!
    @IBOutlet weak var btnSure: HinsButtonBase!
    @IBOutlet weak var btnRequestSmsCode: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSure.layer.cornerRadius = 6.0
        btnSure.layer.masksToBounds = true
        
        btnRequestSmsCode.layer.cornerRadius = 3.0
        btnRequestSmsCode.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionSendSmsCode(_ sender: UIButton) {
        if numberTF.text?.count != 11 {
            self.showAlertWith(title: "输入错误", message: "请检查11位手机号输入是否正确") {
                return
            }
        }

        AVSMS.requestShortMessage(forPhoneNumber: numberTF.text!, options: nil) { (success, error) in
            if success {
                self.showAlertWith(title: "发送验证码成功", message: "请注意查收短信通知") {
                    return
                }
            } else {
                
                self.showAlertWith(title: "发送验证码失败", message: error?.localizedDescription) {
                    return
                }
            }
        }
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        if numberTF.text?.count != 11 {
            self.showAlertWith(title: "输入错误", message: "请检查11位手机号输入是否正确") {
                return
            }
        }

        AVUser.signUpOrLoginWithMobilePhoneNumber(inBackground: numberTF.text!, smsCode: smsTF.text!) { (user, error) in

            if error == nil {
                self.showAlertWith(title: "注册登录成功", message: "欢迎使用！", completed: {
                    BTNUserManager.shard.initImService {
                        let age = BTNUserManager.shard.currentUser.object(forKey: "age")
                        let sex = BTNUserManager.shard.currentUser.object(forKey: "sex")
                        let avatar = BTNUserManager.shard.currentUser.object(forKey: "avatar")
                        let nickName = BTNUserManager.shard.currentUser.object(forKey: "nickName")
                        if BTNUserManager.shard.currentUser.username! != "15026683676" {
                            BTNUserManager.shard.addFriend(username: "15026683676", completed: { (info) in
                                if age != nil && sex != nil && avatar != nil && nickName != nil {
                                    let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                                    self.present(destinVC, animated: true, completion: nil)
                                }else {
                                    let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "kBTNSettingUserInfoVC")
                                    let nav =  UINavigationController(rootViewController: destinVC)
                                    self.present(nav, animated: true, completion: nil)
                                }
                            })
                        } else {

                            if age != nil && sex != nil && avatar != nil && nickName != nil {
                                let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                                self.present(destinVC, animated: true, completion: nil)
                            }else {
                                let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "kBTNSettingUserInfoVC")
                                let nav =  UINavigationController(rootViewController: destinVC)
                                self.present(nav, animated: true, completion: nil)
                            }


                        }
                    }
                    
                })
            } else {
                self.showAlertWith(title: "注册登录失败", message: error!.localizedDescription, completed: {
                })
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

}
