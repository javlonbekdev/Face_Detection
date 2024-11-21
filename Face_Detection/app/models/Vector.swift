//
//  Vector.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 17/11/24.
//

import Foundation
import RealmSwift

struct Vector {
    var name: String
    var vector: [Float]
    var distance: Float
}

extension Vector {
    init(name: String, vector: [Float]) {
        self.init(name: name, vector: vector, distance: 0)
    }
}

class SavedVector: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var vector: String = ""
    @objc dynamic var distance: Float = 0
}
