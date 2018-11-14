//
//  TodoItem.swift
//  GetDone
//
//  Created by Julian Mclain on 11/12/18.
//  Copyright © 2018 Julian Mclain. All rights reserved.
//

import Foundation

class TodoItem: Encodable, Decodable {
    var title : String = ""
    var done : Bool = false
}
