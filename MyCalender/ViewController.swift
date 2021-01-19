//
//  ViewController.swift
//  MyCalender
//
//  Created by Myron on 2021/1/15.
//

import UIKit

class ViewController: UIViewController, MyCalenderViewDelegate {
    
    var calenderView: MyCalenderView?
    var label: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let calender = Calendar.current
        let day = calender.dateComponents([.year,.month,.day,.weekday], from: Date())
        
        calenderView = MyCalenderView.init(dateComponents: day)
        calenderView?.delegate = self
        
        let button = UIButton.init(frame: CGRect.init(x: 20, y: 100, width: 100, height: 45))
        button.setTitle("选择日历", for: .normal)
        button.backgroundColor = UIColor.cyan
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(chooseCalender(button:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        label = UILabel.init(frame: CGRect.init(x: 20, y: 150, width: 500, height: 45))
        label.textColor = UIColor.red
        self.view.addSubview(label)

    }
    
    @objc func chooseCalender(button: UIButton){
        calenderView?.showCalender()
    }
  

//    func didSelectDateComponents(loopScrollView: MyCalenderViewItem, dateComponents: DateComponents) {
//        print("didSelectDateComponents \(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)")
//    }
    
    func didSelectDayString(loopScrollView: MyCalenderViewItem, dateString: String) {
        print("didSelectDayString \(dateString)")
        label?.text = dateString
    }


}

