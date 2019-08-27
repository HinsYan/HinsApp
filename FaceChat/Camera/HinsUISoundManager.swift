//
//  HinsUISoundManager.swift
//  Hins
//
//  Created by yantommy on 2017/4/19.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit
import AVFoundation

enum HinsUISoundType: Int {

    case success = 0
    case failed
}

class HinsUISoundManager: NSObject {

    static var player: AVAudioPlayer!
    
    static func playUISound(type: HinsUISoundType) {
    
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: type == .success ? "slide-scissors" : "slide-network", ofType: "aif")!)
        
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            
            print("播放按钮音效")

        }catch{ print(error.localizedDescription) }
        
    }
    
    static func playTapticEngine() {
    
//        var soundID: SystemSoundID = 0
//        
//        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
//        AudioServicesPlayAlertSound(soundID)
        
    }
}
