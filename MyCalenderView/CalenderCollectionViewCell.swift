//
//  CalenderCollectionViewCell.swift
//  MyCalender
//
//  Created by Myron on 2021/1/18.
//

import Foundation
import UIKit

class CalenderCollectionViewCell: UICollectionViewCell {
    
    var itemLabel: UILabel?
//    let model: CalenderModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        itemLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        itemLabel?.textColor = UIColor.black
        itemLabel?.font = UIFont.systemFont(ofSize: 17)
        itemLabel?.textAlignment = .center
//        itemLabel?.text = model?.text
        self.addSubview(itemLabel!)
    }
    
    func setModel(model: CalenderModel) {
        itemLabel?.text = model.text
    }
    
    func showToday() {
        backgroundColor =  UIColor.init(red: 229 / 255, green: 159 / 255, blue: 73 / 255, alpha: 1)
        itemLabel?.textColor = UIColor.white
    }
    
    func showNormal() {
        backgroundColor = UIColor.lightGray
        itemLabel?.textColor = UIColor.black
    }
    
    func showSelect() {
        backgroundColor = UIColor.red
        itemLabel?.textColor = UIColor.white
    }
}
