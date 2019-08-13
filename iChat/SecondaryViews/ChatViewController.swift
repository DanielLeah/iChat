//
//  ChatViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 24/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    //Custom Header
    let leftBarButtonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    
    let avatarButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        return title
    }()
    
    let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subtitleLabel.textAlignment = .left
        subtitleLabel.font = UIFont(name: subtitleLabel.font.fontName, size: 10)
        return subtitleLabel
    }()
    
    var chatRoomID: String!
    var membersID: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    var maxMessagesNo = 0
    var minMessagesNo = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    var initialLoadComplete = false
    
    var newChatListener: ListenerRegistration?
    var typingLister: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        setCustomTitle()
        
        loadMessages()
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()?.firstname
        
        //custom send button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    //MARK: JSQMessages DataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            cell.textView?.textColor = .white
        }else {
            cell.textView?.textColor = .black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId(){
            return outgoingBubble
        }else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objectMessages[indexPath.row]
        
        let status : NSAttributedString!
        
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
        default:
            status = NSAttributedString(string: "✓")
        }
        
        if indexPath.row == (messages.count - 1){
            return status
        }else {
            return NSAttributedString(string: "")
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    //MARK: JSQMessages Delegate functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideoAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("Camera")
        }
        
        let sharePhotoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
            print("Photo library")
        }
        
        let shareVideoAction = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("Video library")
        }
        
        let shareLocationAction = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("Share Location")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        takePhotoOrVideoAction.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhotoAction.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideoAction.setValue(UIImage(named: "video"), forKey: "image")
        shareLocationAction.setValue(UIImage(named: "location"), forKey: "image")
        
        optionsMenu.addAction(takePhotoOrVideoAction)
        optionsMenu.addAction(sharePhotoAction)
        optionsMenu.addAction(shareVideoAction)
        optionsMenu.addAction(shareLocationAction)
        optionsMenu.addAction(cancelAction)
        
        //Check if is ipad
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            if let currentPopoverPresentationController = optionsMenu.popoverPresentationController {
                currentPopoverPresentationController.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverPresentationController.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                currentPopoverPresentationController.permittedArrowDirections = .up
                self.present(optionsMenu, animated: true, completion: nil)
            }
        }else {
            self.present(optionsMenu, animated: true, completion: nil)
        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        }else{
            print("Microphone")
        
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        //load more messages
        self.loadMoreMessages(maxNumber: maxMessagesNo, minNumber: minMessagesNo)
        self.collectionView.reloadData()
    }
    
    //MARK: Send Messages
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?){
        
        var outgoingMessage: OutgoingMessages?
        let currentUser = FUser.currentUser()!
        
        //text
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderID:currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        if let pic = picture {
            uploadImage(image: pic, chatRoomId: chatRoomID, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    
                    let text = kPICTURE
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderID: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoomID, messageDictionary: outgoingMessage!.messageDictionary, membersID: self.membersID, membersToPush: self.membersToPush)
                }
            }
            
            return
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoomID, messageDictionary: outgoingMessage!.messageDictionary, membersID: membersID, membersToPush: membersToPush)
    }
    
    //MARK: Load Messages
    
    func loadMessages(){
        
        //get the last 11 messages
        reference(.Message).document(FUser.currentId()).collection(chatRoomID!).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents )) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            
            self.listenForNewChats()
            
            self.getOldMessagesInBackground()
        }
        
    }
    
    func listenForNewChats(){
        var lastMessageDate = "0"
        
        if loadedMessages.count > 0 {
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomID).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                for diff in snapshot.documentChanges {
                    if (diff.type == .added) {
                        let item = diff.document.data() as NSDictionary
                        
                        if let type = item[kTYPE] {
                            
                            if self.legitTypes.contains(type as! String) {
                                
                                if type as! String == kPICTURE {
                                    //add to pictures
                                }
                                
                                if self.insertInitialLoadedMessage(messageDict: item){
                                    
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    func getOldMessagesInBackground(){
        if loadedMessages.count > 10 {
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            
            reference(.Message).document(FUser.currentId()).collection(chatRoomID).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                
                //get the picture messages
                
                self.maxMessagesNo = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessagesNo = self.maxMessagesNo - kNUMBEROFMESSAGES
            }
        }
    }
    
    //MARK: Insert Messages
    
    func insertMessages(){
        
        maxMessagesNo = loadedMessages.count - loadedMessagesCount
        minMessagesNo = maxMessagesNo - kNUMBEROFMESSAGES
        
        if minMessagesNo < 0 {
            minMessagesNo = 0
        }
        
        for i in minMessagesNo ..< maxMessagesNo {
            let messageDict = loadedMessages[i]
            insertInitialLoadedMessage(messageDict: messageDict)
            loadedMessagesCount += 1
            
        }
        
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertInitialLoadedMessage(messageDict: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        if (messageDict[kSENDERID] as! String ) != FUser.currentId() {
            //update message status
        }
        
        let message = incomingMessage.createMessage(messageDict: messageDict, chatRoomId: chatRoomID)
        
        if message != nil {
            objectMessages.append(messageDict)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDict)
    }
    
    //MARK: Load more messages
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int ){
        if loadOld{
            maxMessagesNo = minNumber - 1
            minMessagesNo = maxMessagesNo - kNUMBEROFMESSAGES
        }
        
        if minMessagesNo < 0 {
            minMessagesNo = 0
        }
        
        for i in (minMessagesNo ... maxMessagesNo).reversed(){
            let messageDict = loadedMessages[i]
            insertNewMessage(messageDict: messageDict)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDict: NSDictionary){
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(messageDict: messageDict, chatRoomId: chatRoomID)
        
        objectMessages.insert(messageDict, at: 0)
        messages.insert(message!, at: 0)
        
        
    }
    
    //MARK: IBActions
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func infoButtonPressed(){
        print("show Img messages")
    }
    
    @objc func showGroup(){
        print("Show group")
    }
    
    @objc func showProfile(){
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = withUsers.first!
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    //MARK: CustomSendButton
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        }else {
            updateSendButton(isSend: false)
        }
    }
    
    func updateSendButton(isSend: Bool){
        
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        }else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    //MARK: Update UI
    func setCustomTitle(){
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subtitleLabel)
        
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonPressed))
        
        self.navigationItem.rightBarButtonItem = infoButton
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        }else{
            avatarButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: membersID) { (withUsers) in
            self.withUsers = withUsers
            //get avatars
            if !self.isGroup! {
                self.setUIForSingleChat()
            }
        }
    }
    
    func setUIForSingleChat(){
        let withUser = withUsers.first!
        
        imageFromData(pictureData: withUser.avatar) { (image) in
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        
        titleLabel.text = withUser.fullname
        
        if withUser.isOnline {
            subtitleLabel.text = "Online"
        }else{
            subtitleLabel.text = "Offline"
        }
        
        avatarButton.addTarget(self, action: #selector(self.showProfile), for: .touchUpInside)
    }
    
    //MARK: Uiimagepickercontroller delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Helper functions
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        for message in tempMessages{
            
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String){
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
                }
            }else{
                tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
            }
        }
        
        return tempMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        }else {
            return true
        }
    }
    
    func readTimeFrom(dateString: String) -> String{
        let date = dateFormatter().date(from: dateString)
        
        let currentDateFormat = dateFormatter()
        
        currentDateFormat.dateFormat = "HH:mm"
        
        return currentDateFormat.string(from: date!)
    }

}

extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else {return}
        if #available(iOS 11.0, *){
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}
