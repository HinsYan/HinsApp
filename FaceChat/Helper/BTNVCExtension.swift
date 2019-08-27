//
//  BTNVCExtension.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/29.
//  Copyright © 2016年 yantommy. All rights reserved.
//


public extension UIViewController {
    
    @IBAction public func unwindtoVC(sender:UIStoryboardSegue) {}
    
    
    func showAlertWith(title: String!, message: String?, completed: @escaping () -> Void) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionDone = UIAlertAction(title: "Done", style: .default) { (action) in
            completed()
        }
        alertVC.addAction(actionDone)
        present(alertVC, animated: true, completion: nil)
    }
}


