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

class ChatViewController: JSQMessagesViewController {
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    var chatRoomID: String!
    var membersID: [String]!
    var membersToPush: [String]!
    var titleName: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()?.firstname
        
        //custom send button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    //MARK: JSQMessages Delegate functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideoAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("Camera")
        }
        
        let sharePhotoAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
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
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?){
        
        var outgoingMessage: OutgoingMessages?
        let currentUser = FUser.currentUser()!
        
        //text
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderID:currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoomID, messageDictionary: outgoingMessage!.messageDictionary, membersID: membersID, membersToPush: membersToPush)
    }
    
    //MARK: IBActions
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
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
