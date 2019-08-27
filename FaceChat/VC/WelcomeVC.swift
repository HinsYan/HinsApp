//
//  WelcomeVC.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/29.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var backView: HinsVideoMessagePreView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "video2", ofType: "mov")!)
        let video = HinsAssetVideo(cacheURL: url)
        backView.progressLine.isHidden = true
        backView.assetVideo = video
        backView.startPlayVideo()
        
        // Do any additional setup after loading the view.
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
