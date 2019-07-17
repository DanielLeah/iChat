//
//  UserTableViewCell.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 11/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func didTapAvatarImg(indexPath: IndexPath)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var indexPath : IndexPath!
    let tapGestureRecognizer = UITapGestureRecognizer()
    var delegate : UserTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImgView.isUserInteractionEnabled = true
        avatarImgView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func generateCellWith(fUser :FUser, indexPath: IndexPath){
        
        self.indexPath = indexPath
        
        self.fullNameLabel.text = fUser.fullname
        if fUser.avatar != "" {
            imageFromData(pictureData: fUser.avatar) { (avatar) in
                if avatar != nil {
                    self.avatarImgView.image = avatar!.circleMasked
                }
            }
        }
    }
    
    @objc func avatarTap(){
        delegate!.didTapAvatarImg(indexPath: indexPath)
    }
    
}
