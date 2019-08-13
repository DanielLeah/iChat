//
//  OutgoingMessages.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 25/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import Foundation

class OutgoingMessages {
    let messageDictionary: NSMutableDictionary
    
    //MARK: Init
    
    //text
    init(message: String, senderID: String, senderName: String, date: Date, status: String, type: String){
        
        messageDictionary = NSMutableDictionary(objects: [message, senderID, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //picture
    
    init(message: String, pictureLink: String, senderID: String, senderName: String, date: Date, status: String, type: String){
        
        messageDictionary = NSMutableDictionary(objects: [message, pictureLink, senderID, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    //MARK: SendMessage
    func sendMessage(chatRoomID: String, messageDictionary: NSMutableDictionary, membersID: [String], membersToPush: [String]){
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in membersID{
            reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messageDictionary as! [String : Any])
        }
        
        //Update recent chat
        
        //send push notification
        
    }
    
}
