//
//  BTNSettingUserInfoVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/2/1.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM
import SDWebImage

class BTNSettingUserInfoVC: UIViewController {

    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var avatarDefault: String!
    var sexDefault: Bool!
    var nicknameDefault: String!
    var ageDefault: String!
    
    var sexData = ["👦","👧"]
    var ageData = ["12以下","12","13","14","15","16","17","18","19","20","21","22","23","24","25","25以上"]
    
    var photoPicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let avatar = BTNUserManager.shard.currentUser.object(forKey: "avatar") {
            let str = avatar as! String
            avatarDefault = str
            btnAvatar.sd_setImage(with: URL(string: avatar as! String), for: .normal, completed: nil)
            
        } else {
            avatarDefault = ""
        }
        if let sex = BTNUserManager.shard.currentUser.object(forKey: "sex") {
           
            let str = sex as! Bool
            sexDefault = str
            
        } else {
            sexDefault = false
        }
        if let age = BTNUserManager.shard.currentUser.object(forKey: "age") {
     
            let str = age as! String
            ageDefault = str
        } else {
            ageDefault = "未填写"
        }
        if let nickName = BTNUserManager.shard.currentUser.object(forKey: "nickName") {
            let str = nickName as! String
            nicknameDefault = str
        } else {
            nicknameDefault = "未知用户名"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        nickNameTF.placeholder = nicknameDefault
        
        initNavBar()
        
        btnAvatar.layer.cornerRadius = btnAvatar.bounds.height/2
        btnAvatar.layer.masksToBounds = true
        
        nickNameTF.delegate = self
        
        photoPicker =  UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        photoPicker.sourceType = .photoLibrary
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionAvatar(_ sender: Any) {

        let sexActionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        weak var weakSelf = self
        
        let sexNanAction = UIAlertAction(title: "从相册中选择", style: UIAlertAction.Style.default){ (action:UIAlertAction)in
            weakSelf?.initPhotoPicker()
            //填写需要的响应方法
        }
        
        let sexNvAction = UIAlertAction(title: "拍照", style: UIAlertAction.Style.default){ (action:UIAlertAction)in
            weakSelf?.initCameraPicker()
            //填写需要的响应方法
        }
        
        let sexSaceAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel){ (action:UIAlertAction)in
            //填写需要的响应方法
        }
        
        
        sexActionSheet.addAction(sexNanAction)
        sexActionSheet.addAction(sexNvAction)
        sexActionSheet.addAction(sexSaceAction)
        
        self.present(sexActionSheet, animated: true, completion: nil)
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

extension BTNSettingUserInfoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nicknameDefault = textField.text!
    }
}

extension BTNSettingUserInfoVC: UIImagePickerControllerDelegate {
    
    //从相册中选择
    func initPhotoPicker(){
        //在需要的地方present出来
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    //拍照
    func initCameraPicker(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let  cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            //在需要的地方present出来
            self.present(cameraPicker, animated: true, completion: nil)
        } else {
            print("不支持拍照")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //获得照片
        let image:UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        // 拍照
        if picker.sourceType == .camera {
            //保存相册
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        btnAvatar.setImage(image, for: .normal)
        self.dismiss(animated: true) {
            let imgData = self.btnAvatar.currentImage!.pngData()!
            let file = AVFile(data: imgData, name: BTNUserManager.shard.currentUser.username! + "avatar.png")
            file.upload { (success, error) in
                if error == nil {
                    self.showAlertWith(title: "上传头像成功", message: "", completed: {
                        BTNUserManager.shard.currentUser.setObject(file.url()!, forKey: "avatar")
                        BTNUserManager.shard.currentUser.saveInBackground({ (success, error) in
                            if error == nil {
                                self.avatarDefault = file.url()
                            }else{
                                self.showAlertWith(title: "保存图片出错", message: "请重试", completed: {
                                })
                            }
                        })
                    })
                } else {
                    self.showAlertWith(title: "出错了", message: "上传图片失败，请重试", completed: {
                    })
                }
            }
        }

    }
    
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        
        if error != nil {
            print("保存失败")
        } else {
            print("保存成功")
        }
    }
}

extension BTNSettingUserInfoVC: UINavigationControllerDelegate {
    // 这里可以什么都不写
}


// MARK: - Navigation
extension BTNSettingUserInfoVC {
    
    func initNavBar() {
        
        self.title = "个人信息"
        let btnSave = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(self.actionSave))
        self.navigationItem.setRightBarButton(btnSave, animated: false)
        
    }
    
    @objc func actionSave(){
        
        if nickNameTF.text == "" || nicknameDefault == "未知用户名" || ageDefault == "未填写" || avatarDefault == "" {
            self.showAlertWith(title: "稍等一下", message: "请先修改个人信息", completed: {
            })
            return
        }
        
        nicknameDefault = nickNameTF.text!
        BTNUserManager.shard.currentUser.setObject(ageDefault, forKey: "age")
        BTNUserManager.shard.currentUser.setObject(sexDefault, forKey: "sex")
        BTNUserManager.shard.currentUser.setObject(nicknameDefault, forKey: "nickName")
        BTNUserManager.shard.currentUser.saveInBackground { (success, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    self.showAlertWith(title: "保存出错", message: "请重试", completed: {
                    })
                } else {
                    if let nav = self.navigationController {
                        
                        if let firstVC = nav.viewControllers.first as? BTNSettingVC {
                            print("即将退回设置界面")
                            nav.popViewController(animated: true)
                        } else {
                            print("即将进入主界面")
                            let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                            self.present(destinVC, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

extension BTNSettingUserInfoVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BTNSettingTableCell
        if indexPath.row == 0 {
            cell.lbeTitle.text = "请选择您的年龄"
            cell.lbeDetail.text = ageDefault
        }
        if indexPath.row == 1 {
            cell.lbeTitle.text = "请选择您的性别"
            cell.lbeDetail.text = sexDefault ? "👧" : "👦"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 74
    }
    
}
extension BTNSettingUserInfoVC: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        nickNameTF.resignFirstResponder()
        
        if indexPath.row == 0 {
          
            let destin = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: kBTNSettingDataPickVC) as! BTNSettingDataPickVC
            destin.view.layoutIfNeeded()
            destin.dataSource = ageData
            destin.delegate = self
            destin.lbeInfo.text = "请选择您的年龄"
            if let nav = self.navigationController {
                nav.pushViewController(destin, animated: true)
            }
            
        }
        if indexPath.row == 1 {
            
            let destin = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: kBTNSettingDataPickVC) as! BTNSettingDataPickVC
            destin.view.layoutIfNeeded()
            destin.dataSource = sexData
            destin.delegate = self
            destin.lbeInfo.text = "请选择您的性别"
            if let nav = self.navigationController {
                nav.pushViewController(destin, animated: true)
            }

        }
    }
    
}
extension BTNSettingUserInfoVC: BTNSettingDataPickVCDelegate {
   
    func didEndPick(vc: BTNSettingDataPickVC) {
        if vc.lbeInfo.text == "请选择您的年龄" {
            ageDefault = ageData[vc.pickView.selectedRow(inComponent: 0)]
        }
        if vc.lbeInfo.text == "请选择您的性别" {
            sexDefault = (sexData[vc.pickView.selectedRow(inComponent: 0)] == "👧") ? true : false
        }
        tableView.reloadData()
    }
}

