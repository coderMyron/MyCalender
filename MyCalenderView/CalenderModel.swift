//
//  CalenderModel.swift
//  MyCalender
//
//  Created by Myron on 2021/1/15.
//

import Foundation

class CalenderModel {
    var text: String
    var today: Bool?
    
    init(text: String, today: Bool = false) {
        self.text = text
        self.today = today
    }
}
