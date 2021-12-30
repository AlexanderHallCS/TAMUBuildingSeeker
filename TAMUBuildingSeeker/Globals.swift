//
//  Globals.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 12/29/21.
//

import Foundation
import FirebaseFirestore

struct UserData {
    static var group = ""
    static var groupCode = ""
    static var totalTimeElapsed = 0.0
    static var positions: [GeoPoint] = [] // coordinates of the user during study
}
