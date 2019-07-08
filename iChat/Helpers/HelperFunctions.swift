//
//  HelperFunctions.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 05/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}
