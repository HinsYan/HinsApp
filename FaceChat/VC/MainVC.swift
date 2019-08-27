//
//  ViewController.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/29.
//  Copyright © 2016年 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM
import Contacts
import SDWebImage

enum BTNMinCameraViewPosition {
    case none
    case upLeft
    case upRight
    case bottomLeft
    case bottomRight
}

let collectionViewInitEdgeTop: CGFloat = 0.0

public var friendsDataSource = [AVUser]()

public let kNotifactionNameUpdateUnreadMessages = "kNotifactionNameUpdateUnreadMessages"

class MainVC: UIViewController {
    
    let colorsArray = ["EE5464", "DC4352", "FD6D50", "EA583F", "F6BC43", "8DC253", "4FC2E9", "3CAFDB", "5D9CEE", "4B89DD", "AD93EE", "977BDD", "EE87C0", "D971AE", "903FB1", "9D56B9", "227FBD", "2E97DE"]

    lazy var myContactStore: CNContactStore = {
        let cn:CNContactStore = CNContactStore()
        return cn
    }()
    
    var statusBarhHiddenBool = false
    var conversationDataSource = [AVIMConversation?]() {
        didSet {
            let numberOfFillColl = Int(ceil(collView.bounds.height/(collView.bounds.width/2))*2)
            let currentNumber = conversationDataSource.count
            if currentNumber < numberOfFillColl {
                for index in 0..<(numberOfFillColl-currentNumber) {
                    conversationDataSource.append(nil)
                }
            }
        }
    }
    
    @IBOutlet weak var collView: UICollectionView!
    
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lbeUserName: UILabel!
    @IBOutlet weak var btnInviteFriends: UIButton!
    
    var minCameraView: BTNCameraView!
    var minCameraInitPanPoint: CGPoint!
    var minCameraInitPointBeforePan: CGPoint!
    var minCameraViewPosition: BTNMinCameraViewPosition = .none {
        didSet{

            switch minCameraViewPosition {
            case .upLeft:
              
                minCameraView.center = CGPoint(x: minCameraView.bounds.width/2 + kBTNMinCameraViewPadding, y: minCameraView.bounds.height/2 + kBTNMinCameraViewPadding)
                print(minCameraView.center)
                
            case .upRight:
                
                minCameraView.center = CGPoint(x: (minCameraView.superview?.bounds.width)! - (minCameraView.bounds.width/2 + kBTNMinCameraViewPadding), y: minCameraView.bounds.height/2 + kBTNMinCameraViewPadding)
                print(minCameraView.center)
                
            case .bottomLeft:
                
                minCameraView.center = CGPoint(x: minCameraView.bounds.width/2 + kBTNMinCameraViewPadding, y: (minCameraView.superview?.bounds.height)! - (minCameraView.bounds.height/2 + kBTNMinCameraViewPadding))
                print(minCameraView.center)
            case .bottomRight:
                
               minCameraView.center = CGPoint(x: (minCameraView.superview?.bounds.width)! - (minCameraView.bounds.width/2 + kBTNMinCameraViewPadding), y: (minCameraView.superview?.bounds.height)! - (minCameraView.bounds.height/2 + kBTNMinCameraViewPadding))
                print(minCameraView.center)
                
            default:
                return
            }
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    override var prefersStatusBarHidden: Bool {
        return statusBarhHiddenBool
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initCollView()
        self.initMinCameraView()
        self.initTitleBarViews()
        
        self.conversationDataSource = []
        self.collView.delegate = self
        self.collView.dataSource = self

        
        BTNUserManager.shard.initImService {
            self.refreshConversationData(cachePolicy: .networkOnly)
        }
        
        if let avatar = BTNUserManager.shard.currentUser.object(forKey: "avatar") {
            btnAvatar.sd_setImage(with: URL(string: avatar as! String), for: .normal) { (image, error, type, url) in
                if error != nil {
                    print(error!.localizedDescription)
                }else{
                    print("加载头像成功")
                }
            }
        }
        if let nickName = BTNUserManager.shard.currentUser.object(forKey: "nickName") {
            lbeUserName.text = nickName as! String
        }
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        collView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            //获取最近的会话（注意这里是异步查询）
            BTNUserManager.shard.getRecentConversations(cachePolicy: .networkOnly) { (getedConversations) in
                if let _ = getedConversations {
                    self?.conversationDataSource = getedConversations!
                    self?.collView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                        self?.collView.dg_stopLoading()
                        
                    })

                }
            }
            
            
        }, loadingView: loadingView)
        
        collView.dg_setPullToRefreshFillColor(UIColor.white)
        collView.dg_setPullToRefreshBackgroundColor(UIColor.yellow)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUnreadMessages(noti:)), name: NSNotification.Name(rawValue: kNotifactionNameUpdateUnreadMessages), object: nil)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshConversationData(cachePolicy: .networkOnly)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BTNUserManager.shard.client.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotifactionNameUpdateUnreadMessages), object: nil)
    }
    
    @IBAction func actionShowSettingInfo(_ sender: Any) {
        let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "kBTNSettingVC")
        let nav =  UINavigationController(rootViewController: destinVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    func refreshConversationData(cachePolicy: AVIMCachePolicy) {
        //获取最近的会话（注意这里是异步查询）
        BTNUserManager.shard.getRecentConversations(cachePolicy: cachePolicy) { (getedConversations) in
            if let _ = getedConversations {
                self.conversationDataSource = getedConversations!
                self.collView.reloadData()
            }
        }
    }
    
    @objc func updateUnreadMessages(noti: Notification) {
        refreshConversationData(cachePolicy: .networkOnly)
    }

}


// MARK: - initViews
extension MainVC {

    func initCollView() {
        
        collView.register(UINib(nibName: "BTNContactCollCell", bundle: Bundle.main), forCellWithReuseIdentifier: kBTNContactCollCellIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collView.bounds.width/2, height: collView.bounds.width/2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: collectionViewInitEdgeTop, left: 0, bottom: 0, right: 0)
        collView.collectionViewLayout = layout
        collView.backgroundColor = UIColor.clear
        collView.layer.cornerRadius = kBTNWindowCornerRadii
        collView.layer.masksToBounds = true
        //collView.addCornerMask(rectCorners: .topLeft, cornerRadii: kBTNWindowCornerRadii)
        //collView.addCornerMask(rectCorners: .topRight, cornerRadii: kBTNWindowCornerRadii)
        
    }

    func initTitleBarViews(){
        
        btnAvatar.layer.cornerRadius = btnAvatar.bounds.height/2
        btnAvatar.layer.masksToBounds = true
    
        btnInviteFriends.layer.cornerRadius = btnInviteFriends.bounds.height/2
        btnInviteFriends.addShadowWith(color: UIColor.lightGray, opacity: nil, radius: nil, offset: CGSize.zero)
    
    }
    
}

// MARK: - IBAction
extension MainVC {
    
    func actionInviteFriends(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "Invite", message: "Invite yous firends on Chatter", preferredStyle: .actionSheet)
        actionSheet.view.tintColor = UIColor.black
        let actionQQ = UIAlertAction(title: "QQ", style: .default) { (action) in
            
        }
        
        let actionWechat = UIAlertAction(title: "Wechat", style: .default) { (action) in
            
        }
        
        let actionNumber = UIAlertAction(title: "PhoneNumber", style: .default) { (action) in
            let destinVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchUserVC")
            self.present(destinVC, animated: true, completion: nil)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }

        actionSheet.addAction(actionQQ)
        actionSheet.addAction(actionWechat)
        actionSheet.addAction(actionNumber)
        actionSheet.addAction(actionCancel)
        present(actionSheet, animated: true, completion: nil)
        
        
    }

}


// MARK: - collectionView相关数据动作代理
extension MainVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kBTNContactCollCellIdentifier, for: indexPath) as! BTNContactCollCell
        let hexString = colorsArray[indexPath.row % colorsArray.count]
        let color = UIColor.colorFromHexString(hexString)
        cell.bgColor = color
        
        let conversation = conversationDataSource[indexPath.row]
        cell.conversation = conversation
        //cell.messagesDataSource = messagesDataSource[conversation.conversationId!]!
        // MARK: - Todo: Data
        cell.controller = self
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        let scrollContOffY = scrollView.contentOffset.y
        if scrollContOffY > 0 && statusBarhHiddenBool == false {
            UIView.animate(withDuration: 0.3) {
                self.statusBarhHiddenBool = true
                self.collView.frame = self.view.bounds
                self.setNeedsStatusBarAppearanceUpdate()
            }
        } else if scrollView.contentOffset.y < 0 && statusBarhHiddenBool == true {
            UIView.animate(withDuration: 0.3) {
                self.statusBarhHiddenBool = false
                self.collView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height)
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
        
    }
}

extension MainVC: AVIMClientDelegate {
    func imClientPaused(_ imClient: AVIMClient) {
        
    }
    
    func imClientResuming(_ imClient: AVIMClient) {
        
    }
    
    func imClientResumed(_ imClient: AVIMClient) {
        
    }
    
    func imClientClosed(_ imClient: AVIMClient, error: Error?) {
        
    }
    
    
    func conversation(_ conversation: AVIMConversation, didReceive message: AVIMTypedMessage) {
        //let videoMessage = message as! AVIMVideoMessage
        print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
//        for index in 0..<conversationDataSource.count {
//            if videoMessage.conversationId == conversationDataSource[index]!.conversationId {
//                //messagesDataSource[con.conversationId!]!.append(videoMessage)
//                print("成功为\(conversationDataSource[index]!.conversationId)会话接收到一条视频消息")
//                print("在这里更新本地消息")
//                let indexPath = IndexPath(item: index, section: 0)
//                collView.reloadItems(at: [indexPath])
//            }
//        }
        
    }
    
    func conversation(_ conversation: AVIMConversation, didUpdateForKey key: String) {
        if key == "unreadMessagesCount" {
            print("更新消息:\(conversation.conversationId)")
            for con in conversationDataSource {
                if con == conversation {
                    conversationDataSource.remove(at: conversationDataSource.firstIndex(of: con)!)
                    conversationDataSource.insert(conversation, at: 0)
                    collView.reloadData()
                }
            }
        }
    }
}



// MARK: - Camera浮窗
extension MainVC {

    func initMinCameraView(){
    
        minCameraView = Bundle.main.loadNibNamed("BTNCameraView", owner: self, options: nil)?.first as! BTNCameraView
        //注意这里是先先确定大小 再确定父视图 最后算位置
        minCameraView.frame = CGRect(x: 0, y: 0, width: kBTNScreenWidth/3, height: kBTNScreenWidth/3/kBTNScreenRatio)
        self.view.addSubview(minCameraView)
        minCameraViewPosition = .bottomRight
        minCameraView.layoutIfNeeded()
        minCameraView.filterView.layer.cornerRadius = kBTNWindowCornerRadii/3
        minCameraView.filterView.clipsToBounds = true
        minCameraView.backgroundColor = UIColor.clear
        minCameraView.addShadowWith(color: UIColor.black, opacity: nil, radius: nil, offset: CGSize.zero)
      
        self.addPanGesture(view: minCameraView)
    
    }
    
    func addPanGesture(view: BTNCameraView) {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panFroMinCameraView(_:)))
        minCameraView.addGestureRecognizer(panGesture)
    }
    
    @objc func panFroMinCameraView(_ sender: UIPanGestureRecognizer) {
  
        switch sender.state {
        case .began:
        
            //记录初始点
            self.minCameraInitPanPoint = sender.location(in: self.view)
            self.minCameraInitPointBeforePan = minCameraView.center
            
        case .changed:

            let touchPoint = sender.location(in: self.view)
            let translateX = touchPoint.x - self.minCameraInitPanPoint.x
            let translateY = touchPoint.y - self.minCameraInitPanPoint.y
            
            minCameraView.center = CGPoint(x: minCameraInitPointBeforePan.x + translateX , y: minCameraInitPointBeforePan.y + translateY)

        case .ended:
            
            
            let centerPoint = minCameraView.center
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
                
                if centerPoint.x > (self.minCameraView.superview?.bounds.width)!/2 {
    
                    //右下角
                    if centerPoint.y > (self.minCameraView.superview?.bounds.height)!/2 {
                        self.minCameraViewPosition = .bottomRight
                        //右上角
                    }else{
                        self.minCameraViewPosition = .upRight
                    }
                    
                }else{
                    
                    //左下角
                    if centerPoint.y > (self.minCameraView.superview?.bounds.height)!/2 {
                        self.minCameraViewPosition = .bottomLeft
                        //左上角
                    }else{
                        self.minCameraViewPosition = .upLeft
                    }
                }
                
            }, completion: { (success) in
                
                print("相机窗口移动后的位置\(self.minCameraView.center)")
            })
            
            
        default:
            print("")
        }
    }

}

extension MainVC {

    func checkContactStoreAuth(){
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            print("未授权")
            requestContactStoreAuthorization(myContactStore)
        case .authorized:
            print("已授权")
            readContactsFromContactStore(myContactStore)
        case .denied, .restricted:
            print("无权限")
        //可以选择弹窗到系统设置中去开启
        default: break
        }
    }

    func requestContactStoreAuthorization(_ contactStore:CNContactStore) {
        contactStore.requestAccess(for: .contacts, completionHandler: {[weak self] (granted, error) in
            if granted {
                print("已授权")
                self?.readContactsFromContactStore(contactStore)
            }
        })
    }

    func readContactsFromContactStore(_ contactStore:CNContactStore) {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return
        }
        
        let keys = [CNContactFamilyNameKey,CNContactGivenNameKey,CNContactNicknameKey,CNContactOrganizationNameKey,CNContactJobTitleKey,CNContactDepartmentNameKey,CNContactNoteKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactInstantMessageAddressesKey]
        
        let fetch = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: fetch, usingBlock: { (contact, stop) in
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
        }
    }

}
