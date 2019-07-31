//
//  IncomingMessages.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 26/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage{
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        self.collectionView = collectionView_
    }

    //MARK: Create message
    func createMessage(messageDict: NSDictionary, chatRoomId: String) -> JSQMessage?{
        
        var message: JSQMessage?
        
        let type = messageDict[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDict, chatRoomId: chatRoomId)
        case kPICTURE:
            print("create picture Msg")
        case kVIDEO:
                print("create video Msg")
        case kAUDIO:
                print("create audio Msg")
        case kLOCATION:
                print("create location Msg")
        default:
            print("Unknoun message type")
        }
        
        if message != nil {
            return message
        }
        
        return nil
    }
    
    //MARK: Create message types
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage{
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)
            }
        }else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
}
