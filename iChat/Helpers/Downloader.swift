//
//  Downloader.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 13/08/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD

let storage = Storage.storage()

//image
func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping (_ imageLink: String? ) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    progressHUD.mode = .determinateHorizontalBar
    
    let dateStr = dateFormatter().string(from: Date())
    
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateStr + ".jpg"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    
    let imageData = image.jpegData(compressionQuality: 0.7)
    
    var task : StorageUploadTask!
    
    task = storage.reference().putData(imageData!, metadata: nil
        , completion: { (metadata, error) in
            
            task.removeAllObservers()
            progressHUD.hide(animated: true)
            if error != nil {
                print("Error uploading image\(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                guard let downloadUrl = url else {
                    completion (nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
}
