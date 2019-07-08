//
//  CollectionReferences.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 05/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String{
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}

func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
