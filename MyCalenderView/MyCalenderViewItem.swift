//
//  MyCalenderView.swift
//  MyCalender
//
//  Created by Myron on 2021/1/15.
//

import Foundation
import UIKit

protocol MyCalenderViewDelegate: NSObjectProtocol {
    //func didSelectDateComponents(loopScrollView:MyCalenderViewItem, dateComponents:DateComponents)
    func didSelectDayString(loopScrollView:MyCalenderViewItem, dateString:String)
}

class MyCalenderViewItem: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let cellID = "calenderCell"
    var calendar: Calendar =  Calendar.current
    lazy var formatter: DateFormatter = {
        var f = DateFormatter.init()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    var frontBlankCount: Int = 0
    var backBlankCount: Int = 0
    var todayMonthDateComponents: DateComponents {
        return calendar.dateComponents([.year,.month,.day,.weekday], from: Date())
    }
    var dateComponents: DateComponents?
    var modelArray: Array<CalenderModel> = []
    var collectionView: UICollectionView?
    // 是否是今月
    var isCurrentMonth: Bool = false
    weak var delegate:MyCalenderViewDelegate?
    var closure: ()->()?
    
    init(frame: CGRect, dateComponents: DateComponents, closure: @escaping ()->()) {
        self.dateComponents = dateComponents
        self.closure = closure
        super.init(frame: frame)
        if (dateComponents.year == todayMonthDateComponents.year) && (dateComponents.month == todayMonthDateComponents.month) {
            isCurrentMonth = true
        }else {
            isCurrentMonth = false
        }
        self.isUserInteractionEnabled = true
        setup()
        setupWithDateComponents(dateComponents: dateComponents)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        //上面一行周显示的高度
        let weekDayHeight: CGFloat = 40.0
        //一周一行排7个
        let itemWidth = self.bounds.size.width / 7
        let itemHeight = (self.bounds.size.height - weekDayHeight) / 6
        
        
        let weekView = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: self.bounds.size.width, height: weekDayHeight))
        weekView.backgroundColor = UIColor.init(red: 229 / 255, green: 159 / 255, blue: 73 / 255, alpha: 1)
        self.addSubview(weekView)
        var i = 0
        for _ in 0..<7 {
            let x = CGFloat(i) * itemWidth
            let weekLable = UILabel.init(frame: CGRect.init(x: x, y: 0, width: itemWidth, height: weekDayHeight))
            weekLable.font = UIFont.boldSystemFont(ofSize: 20)
            weekLable.textAlignment = .center
            weekLable.textColor = UIColor.white
            var weekStr = ""
            switch i {
            case 0:
                weekStr = "日"
            case 1:
                weekStr = "一"
            case 2:
                weekStr = "二"
            case 3:
                weekStr = "三"
            case 4:
                weekStr = "四"
            case 5:
                weekStr = "五"
            case 6:
                weekStr = "六"
            default:
                weekStr = ""
            }
            weekLable.text = weekStr
            weekView.addSubview(weekLable)
            i = i + 1
        }
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: itemWidth-1, height: itemHeight)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: weekDayHeight, width: self.bounds.size.width, height: self.bounds.size.height - weekDayHeight), collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.bounces = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(CalenderCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: cellID)
        collectionView?.delaysContentTouches = false
        self.addSubview(collectionView!)
       
    }
    
    func setupWithDateComponents(dateComponents: DateComponents) {
        var firstDayComponents = DateComponents.init()
        firstDayComponents.year = dateComponents.year
        firstDayComponents.month = dateComponents.month
        firstDayComponents.day = 1
        
        let firstDay = calendar.date(from: firstDayComponents)
        let timeZone = TimeZone.current
        let seconds = timeZone.secondsFromGMT(for: firstDay!)
        let day = firstDay!.addingTimeInterval(TimeInterval(seconds))
        
        // 当月有多少天
        let range = calendar.range(of: .day, in: .month, for: day)
        let components = calendar.dateComponents([.year,.month,.day,.weekday], from: day)
        // 当月1日前面有多少个空格
        frontBlankCount = components.weekday! - calendar.firstWeekday
        if (frontBlankCount < 0) {
            //默认firstWeekday为1是周日是，防止设置了firstWeekday为其它值判断下
            frontBlankCount += 7;
        }
        modelArray.removeAll()
        for _ in 0..<frontBlankCount {
            let model = CalenderModel.init(text: "")
            modelArray.append(model)
        }
        for i in range! {
            let model = CalenderModel.init(text: "\(i)")
            modelArray.append(model)
        }
        var weeks = 0
        let week1 = modelArray.count / 7
        let week2 = modelArray.count % 7
        if week2 == 0 {
            weeks = week1
        }else {
            weeks = week1 + 1
        }
        // 当月最后一天同一行后面有多少个空格
        backBlankCount = weeks * 7 - modelArray.count
        for _ in 0..<backBlankCount {
            let model = CalenderModel.init(text: "")
            modelArray.append(model)
        }
        
    }
    
    // MARK: - UICollectionViewDataSource代理
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CalenderCollectionViewCell
        let model = modelArray[indexPath.item]
        cell.setModel(model: model)
        if isCurrentMonth && (model.text == String(todayMonthDateComponents.day!)) {
            cell.showToday()
        }else {
            cell.showNormal()
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalenderCollectionViewCell
        let day = modelArray[indexPath.item].text
        if !day.isEmpty {
            cell.showSelect()
            var components = DateComponents.init()
            components.year = dateComponents?.year
            components.month = dateComponents?.month
            components.day = Int(day)
            //delegate?.didSelectDateComponents(loopScrollView: self, dateComponents: components)
            delegate?.didSelectDayString(loopScrollView: self, dateString: formatter.string(from: calendar.date(from: components)!))
            closure()

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem (at: indexPath) as! CalenderCollectionViewCell
        let day = modelArray[indexPath.item].text
        if !day.isEmpty {
            cell.showSelect()
        }

    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalenderCollectionViewCell
        cell.showNormal()
        if isCurrentMonth && (modelArray[indexPath.item].text == String(todayMonthDateComponents.day!)) {
            cell.showToday()
        }else {
            cell.showNormal()
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
