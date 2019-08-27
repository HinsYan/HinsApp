//
//  LoginOtherVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/30.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM

class LoginOtherVC: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func actionLogin(_ sender: Any) {
        if usernameTF.text?.count != 11 {
            self.showAlertWith(title: "输入错误", message: "请检查11位手机号输入是否正确") {
                return
            }
        }
        
        let newUser = AVUser()
        newUser.username = usernameTF.text
        newUser.password = passwordTF.text
        newUser.signUpInBackground { (success, error) in
            if success {
                self.showAlertWith(title: "注册成功", message: "立即登录", completed: {
                    AVUser.logInWithUsername(inBackground: newUser.username!, password: newUser.password!, block: { (user, error) in
                        if error == nil {
                            self.showAlertWith(title: "登录成功", message: "立即开始Chat吧！", completed: {
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
                            self.showAlertWith(title: "登录失败", message: error!.localizedDescription, completed: {
                            })
                        }
                    })
                })
            } else {
                self.showAlertWith(title: "注册失败", message: error!.localizedDescription, completed: {
                    if error!.localizedDescription.hasSuffix("Username has already been taken.") {
                        AVUser.logInWithUsername(inBackground: newUser.username!, password: newUser.password!, block: { (user, error) in
                            if error == nil {
                                self.showAlertWith(title: "登录成功", message: "立即开始Chat吧！", completed: {
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
                                self.showAlertWith(title: "登录失败", message: error!.localizedDescription, completed: {
                                })
                            }
                        })
                    }
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
