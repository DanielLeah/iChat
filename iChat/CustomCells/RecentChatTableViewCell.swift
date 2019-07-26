//
//  RecentChatTableViewCell.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 22/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImg(indexPath: IndexPath)
}

class RecentChatTableViewCell: UITableViewCell {


    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counterBackgrounView: UIView!
    
    let tapGesture = UITapGestureRecognizer()
    
    var indexPath : IndexPath!
    
    var delegate: RecentChatTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        counterBackgrounView.layer.cornerRadius = counterBackgrounView.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(self.avatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //Functions
    @objc func avatarTapped(){
        delegate?.didTapAvatarImg(indexPath: indexPath)
    }
    
    //MARK: Generate cell
    
    func generateCell(recentChat: NSDictionary, indexPath : IndexPath){
        self.indexPath = indexPath
        
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.counterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.counterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.counterBackgrounView.isHidden = false
            self.counterLabel.isHidden = false
        }else {
            self.counterBackgrounView.isHidden = true
            self.counterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else {
                date = dateFormatter().date(from: created as! String)!
            }
        }else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
    }

}
