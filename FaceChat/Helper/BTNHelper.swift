//
//  BNTHelper.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/29.
//  Copyright © 2016年 yantommy. All rights reserved.
//

import UIKit
import Contacts

//
//// MARK: - View四边角
//public enum BNTViewCornerType: Int {
//    
//    case topLeft = 0
//    case topRight
//    case bottomLeft
//    case bottomRight
//}



public class BTNHelper: NSObject {
    
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    func updateTimeToCurrennTime(timeStamp: Double) -> String {
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        print(currentTime,   timeStamp, "sdsss")
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        //时间差
        let reduceTime : TimeInterval = currentTime - timeSta
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        //不满足上述条件---或者是未来日期-----直接返回日期
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
        return dfmatter.string(from: date as Date)
    }

    static let shard = BTNHelper()
    
    func checkContactStoreAuth(contactStore: CNContactStore, completed: @escaping ([CNContact]?) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            print("未授权")
            requestContactStoreAuthorization(contactStore) { (contacts) in
                completed(contacts)
            }
        case .authorized:
            print("已授权")
            readContactsFromContactStore(contactStore) { (contacts) in
                completed(contacts)
            }
        case .denied, .restricted:
            print("无权限")
        //可以选择弹窗到系统设置中去开启
        default: break
        }
    }
    
    func requestContactStoreAuthorization(_ contactStore:CNContactStore, completed: @escaping ([CNContact]?) -> Void) {
        contactStore.requestAccess(for: .contacts, completionHandler: {[weak self] (granted, error) in
            if granted {
                print("已授权")
                self?.readContactsFromContactStore(contactStore, completed: { (contacts) in
                    completed(contacts)
                })
            }else{
                completed(nil)
            }
        })
    }
    
    func readContactsFromContactStore(_ contactStore:CNContactStore, completed: @escaping ([CNContact]?) -> Void) {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            completed(nil)
            return
        }
        
        let keys = [CNContactFamilyNameKey,CNContactGivenNameKey,CNContactNicknameKey,CNContactOrganizationNameKey,CNContactJobTitleKey,CNContactDepartmentNameKey,CNContactNoteKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactInstantMessageAddressesKey]
        
        let fetch = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        var contactArray = [CNContact]()
        do {
            try contactStore.enumerateContacts(with: fetch, usingBlock: { (contact, stop) in
                
                contactArray.append(contact)
                //姓名
                let name = "\(contact.familyName)\(contact.givenName)"
                print(name)
                //电话
                for number in contact.phoneNumbers {
                    var label = "未知标签"
                    if number.label != nil {
                        label = CNLabeledValue<NSString>.localizedString(forLabel:
                            number.label!)
                    }
                    
                    let phoneNumber = (number.value as CNPhoneNumber).stringValue
                    print("\t\(label)：\(phoneNumber)")
                }
                
                //获取Email
                print("Email：")
                for email in contact.emailAddresses {
                    //获得标签名（转为能看得懂的本地标签名）
                    var label = "未知标签"
                    if email.label != nil {
                        label = CNLabeledValue<NSString>.localizedString(forLabel:
                            email.label!)
                    }
                    
                    //获取值
                    let value = email.value
                    print("\t\(label)：\(value)")
                }
                
                //获取地址
                print("地址：")
                for address in contact.postalAddresses {
                    //获得标签名（转为能看得懂的本地标签名）
                    var label = "未知标签"
                    if address.label != nil {
                        label = CNLabeledValue<NSString>.localizedString(forLabel:
                            address.label!)
                    }
                    
                    //获取值
                    let detail = address.value
                    let contry = detail.value(forKey: CNPostalAddressCountryKey) ?? ""
                    let state = detail.value(forKey: CNPostalAddressStateKey) ?? ""
                    let city = detail.value(forKey: CNPostalAddressCityKey) ?? ""
                    let street = detail.value(forKey: CNPostalAddressStreetKey) ?? ""
                    let code = detail.value(forKey: CNPostalAddressPostalCodeKey) ?? ""
                    let str = "国家:\(contry) 省:\(state) 城市:\(city) 街道:\(street)"
                        + " 邮编:\(code)"
                    print("\t\(label)：\(str)")
                }
                
                //获取纪念日
                print("纪念日：")
                for date in contact.dates {
                    //获得标签名（转为能看得懂的本地标签名）
                    var label = "未知标签"
                    if date.label != nil {
                        label = CNLabeledValue<NSString>.localizedString(forLabel:
                            date.label!)
                    }
                    
                    //获取值
                    let dateComponents = date.value as DateComponents
                    let value = NSCalendar.current.date(from: dateComponents)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                    print("\t\(label)：\(dateFormatter.string(from: value!))")
                }
                
                //获取即时通讯(IM)
                print("即时通讯(IM)：")
                for im in contact.instantMessageAddresses {
                    //获得标签名（转为能看得懂的本地标签名）
                    var label = "未知标签"
                    if im.label != nil {
                        label = CNLabeledValue<NSString>.localizedString(forLabel:
                            im.label!)
                    }
                    
                    //获取值
                    let detail = im.value
                    let username = detail.value(forKey: CNInstantMessageAddressUsernameKey)
                        ?? ""
                    let service = detail.value(forKey: CNInstantMessageAddressServiceKey)
                        ?? ""
                    print("\t\(label)：\(username) 服务:\(service)")
                }
                
                print("----------------")
                
                
                
            })
            
        } catch let error as NSError {
            print(error)
            completed(nil)
            return
        }
        
        completed(contactArray)
    }

    
}


public class AnimationViewBackgroundColor: NSObject {
    
    var currentIndex: Int = 0
    var colors = [UIColor]()
    var view: UIView!
    var displayLink: CADisplayLink!
    var originColor: UIColor!
    
    func showColorChangeAnimation(view: UIView!, colors: [UIColor]!) {
        self.colors = colors
        self.view = view
        self.currentIndex = 0
        originColor = view.backgroundColor
        displayLink = CADisplayLink(target: self, selector: #selector(self.colorChange(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.preferredFramesPerSecond = 5
        displayLink.isPaused = false
    }
    
    @objc func colorChange(_ sender: CADisplayLink!) {
        view.backgroundColor = colors[currentIndex%colors.count]
        currentIndex += 1
    }
    
    func endColorChangeAnimation() {
        displayLink.isPaused = true
        displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.invalidate()
        displayLink = nil

        view.backgroundColor = originColor
    }

}

public extension UIView {

    func addShadowsForLayer(color: UIColor){
        
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 5)
        
    }
}

public extension UIPanGestureRecognizer {
    
    func getPanGestureDirection() -> HinsViewSwipeDirection {
        
        var direction: HinsViewSwipeDirection = .none
        
        guard let _ = self.view else { return direction }
        
        if abs(self.velocity(in: self.view!).x) > abs(self.velocity(in: self.view!).y) {
            
            if self.velocity(in: self.view!).x > 0 {
                print("向右\(self.velocity(in: self.view!).x)")
                direction = .swipeRight
            }
            
            if self.velocity(in: self.view!).x < 0 {
                
                print("向左\(self.velocity(in: self.view!).x)")
                direction = .swipeLeft
            }
            if self.velocity(in: self.view!).x == 0 {
                direction = .none
            }
        }
        
        if abs(self.velocity(in: self.view!).x) < abs(self.velocity(in: self.view!).y) {
            
            if self.velocity(in: self.view!).y > 0 {
                
                print("向下\(self.velocity(in: self.view!).y)")
                direction = .swipeDown
            }
            
            if self.velocity(in: self.view!).y < 0 {
                
                print("向上\(self.velocity(in: self.view!).y)")
                direction = .swipeUp
            }
            
            if self.velocity(in: self.view!).y == 0 {
                direction = .none
            }
            
            
        }
        
        if abs(self.velocity(in: self.view!).x) == abs(self.velocity(in: self.view!).y) {
            
            direction = .none
        }
        
        return direction
    }
}

public extension UIColor {
    public class func colorFromHexString(_ hexString: String) -> UIColor {
        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased() as NSString
        let alpha, red, blue, green: Float
        alpha = 1.0
        red = self.colorComponentsFrom(colorString, start: 0, length: 2)
        green = self.colorComponentsFrom(colorString, start: 2, length: 2)
        blue = self.colorComponentsFrom(colorString, start: 4, length: 2)
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    
    fileprivate class func colorComponentsFrom(_ string: NSString, start: Int, length: Int) -> Float {
        NSMakeRange(start, length)
        let subString = string.substring(with: NSMakeRange(start, length))
        var hexValue: UInt32 = 0
        Scanner(string: subString).scanHexInt32(&hexValue)
        return Float(hexValue) / 255.0
    }
}
