//
//  BTNSettingDataPickVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/2/3.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

public let kBTNSettingDataPickVC = "kBTNSettingDataPickVC"

protocol BTNSettingDataPickVCDelegate: class {
    func didEndPick(vc: BTNSettingDataPickVC)
}

extension BTNSettingDataPickVCDelegate {
    func didEndPick(vc: BTNSettingDataPickVC) {}
}

class BTNSettingDataPickVC: UIViewController {
    @IBOutlet weak var pickView: UIPickerView!
    @IBOutlet weak var lbeInfo: UILabel!
    
    var dataSource = [String]()
    weak var delegate: BTNSettingDataPickVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickView.delegate = self
        pickView.dataSource = self
        
        initNavBar()
        // Do any additional setup after loading the view.
    }
    
    func initNavBar() {
        
        self.title = "修改"
        let btnSave = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(self.actionSave))
        self.navigationItem.setRightBarButton(btnSave, animated: false)
        
    }
    
    @objc func actionSave(){
        if let dele = delegate {
            dele.didEndPick(vc: self)
        }
        
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
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

extension BTNSettingDataPickVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}
