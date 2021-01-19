//
//  MyLoopScrollView.swift
//  MyLoopScrollView-Swift
//
//  Created by Myron on 2021/1/10.
//

import Foundation
import UIKit


class MyCalenderView: UIView, UIScrollViewDelegate {
    var scrollView:UIScrollView!
    var array:Array<DateComponents> = []

    weak var delegate:MyCalenderViewDelegate?{
        didSet{
            reloadData()
        }
    }
    
    var currentDateComponents: DateComponents
    var firstDateComponents: DateComponents
    var yearMonthButton: UIButton!
    // 最外层view
    var view: UIView!
    
    init(dateComponents: DateComponents) {
        self.currentDateComponents = dateComponents
        self.firstDateComponents = dateComponents
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showCalender() {
        reloadData()
        let window = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
            .first?.windows.first
        window?.insertSubview(self, at:Int(INT8_MAX))
    }
    
    func dissmisCalender() {
        self.removeFromSuperview()
    }
    
    func setup() {
        view = UIView.init()
        view.isUserInteractionEnabled = true
        view.frame = CGRect.init(x: 20, y: 0, width: self.bounds.size.width - 40, height: 400)
        view.center = CGPoint.init(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        addSubview(view)
        // 头部高度
        let topHeight = 40.0
        let topView = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: Double(view.bounds.size.width), height: topHeight))
        topView.backgroundColor = UIColor.init(red: 229 / 255, green: 159 / 255, blue: 73 / 255, alpha: 1)
        view.addSubview(topView)
        let preButton = UIButton.init(frame: CGRect.init(x: 20, y: 0, width: 40, height: topHeight))
        preButton.setTitle("<", for: .normal)
        preButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        preButton.addTarget(self, action: #selector(leftMonth(button:)), for: .touchUpInside)
        topView.addSubview(preButton)
        
        yearMonthButton = UIButton.init(frame: CGRect.init(x: (Double(view.bounds.size.width) - 130) * 0.5, y: 0, width: 130, height: topHeight))
        yearMonthButton.setTitle("\(currentDateComponents.year!)年\(currentDateComponents.month!)月", for: .normal)
        yearMonthButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        yearMonthButton.addTarget(self, action: #selector(yearMonthChange(button:)), for: .touchUpInside)
        topView.addSubview(yearMonthButton)
        
        let nextButton = UIButton.init(frame: CGRect.init(x:Double(view.bounds.size.width) - 60, y: 0, width: 40, height: topHeight))
        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(rightMonth(button:)), for: .touchUpInside)
        topView.addSubview(nextButton)
        
        scrollView = UIScrollView.init(frame: CGRect.init(x: 0.0, y: topHeight, width: Double(view.bounds.size.width), height: Double(view.bounds.size.height) - topHeight))
        scrollView.delegate = self
        scrollView.contentSize = CGSize.init(width: view.bounds.size.width * 3, height: view.bounds.size.height - CGFloat(topHeight))
        scrollView.contentOffset = CGPoint.init(x: view.bounds.size.width, y: 0)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        
    }
    
    @objc func leftMonth(button: UIButton) {
        currentDateComponents = getPreviousPageWithCurrentPage(dateComponents: currentDateComponents)
        self.resetContentViews()

    }
    
    @objc func rightMonth(button: UIButton) {
        currentDateComponents = getNextPageWithCurrentPage(dateComponents: currentDateComponents)
        self.resetContentViews()
    }
    
    @objc func yearMonthChange(button: UIButton) {
        
    }


    
    func reloadData() {
        //重置为第一次传进来的时间
        currentDateComponents = firstDateComponents
        resetContentViews();
    }
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (array.count < 1) {
            return;
        }
        let contentOffsetX = scrollView.contentOffset.x;
        if(contentOffsetX >= (2 * scrollView.bounds.size.width)) {
            currentDateComponents = getNextPageWithCurrentPage(dateComponents: currentDateComponents)
            self.resetContentViews()
        }
        
        if(contentOffsetX <= 0) {
            currentDateComponents = getPreviousPageWithCurrentPage(dateComponents: currentDateComponents)
            self.resetContentViews()
        }
    }
    
    func resetContentViews() {
        //重置时间
        var year = currentDateComponents.year
        var month = currentDateComponents.month! - 1
        if (month == 0) {
            month = 12;
            year = year! - 1
        }
        var previousDayComponents = DateComponents.init()
        previousDayComponents.year = year
        previousDayComponents.month = month
        previousDayComponents.day = 1
        // 前一月
        array.append(previousDayComponents)
        // 当月
        array.append(currentDateComponents)
        var nextYear = currentDateComponents.year
        var nextMonth = currentDateComponents.month! + 1
        if (nextMonth == 13) {
            nextMonth = 1;
            nextYear = nextYear! + 1
        }
        var nextDayComponents = DateComponents.init()
        nextDayComponents.year = nextYear
        nextDayComponents.month = nextMonth
        nextDayComponents.day = 1
        // 后一月
        array.append(nextDayComponents)
        
        scrollView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        let previousPageIndex = getPreviousPageWithCurrentPage(dateComponents: currentDateComponents)
        let nextPageIndex = getNextPageWithCurrentPage(dateComponents: currentDateComponents)

        let previousContentView = MyCalenderViewItem.init(frame: scrollView.bounds,dateComponents: previousPageIndex) { [weak self] in
            self?.dissmisCalender()
        }
        previousContentView.delegate = delegate
        let currentContentView = MyCalenderViewItem.init(frame: scrollView.bounds, dateComponents: currentDateComponents) { [weak self] in
            self?.dissmisCalender()
        }
        currentContentView.delegate = delegate
        let nextContentView = MyCalenderViewItem.init(frame: scrollView.bounds, dateComponents: nextPageIndex) { [weak self] in
            self?.dissmisCalender()
        }
        nextContentView.delegate = delegate
        let viewsArr = [previousContentView,currentContentView,nextContentView];
        var i: CGFloat = 0.0
        for contentView in viewsArr {
            contentView.frame = CGRect.init(x: scrollView.bounds.size.width * i, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
            scrollView.addSubview(contentView)
            i = i + 1
        }
        scrollView.setContentOffset(CGPoint.init(x: scrollView.bounds.size.width, y: 0), animated: false)
        yearMonthButton.setTitle("\(currentDateComponents.year!)年\(currentDateComponents.month!)月", for: .normal)
    }
        
    // 获取当前页上一页
    func getPreviousPageWithCurrentPage(dateComponents: DateComponents) -> DateComponents {
        var year = dateComponents.year
        var month = dateComponents.month! - 1
        if (month == 0) {
            month = 12;
            year = year! - 1
        }
        var previousDayComponents = DateComponents.init()
        previousDayComponents.year = year
        previousDayComponents.month = month
        previousDayComponents.day = 1
        return previousDayComponents
    }
    
    // 获取当前页下一页
    func getNextPageWithCurrentPage(dateComponents: DateComponents) -> DateComponents {
        var nextYear = dateComponents.year
        var nextMonth = dateComponents.month! + 1
        if (nextMonth == 13) {
            nextMonth = 1;
            nextYear = nextYear! + 1
        }
        var nextDayComponents = DateComponents.init()
        nextDayComponents.year = nextYear
        nextDayComponents.month = nextMonth
        nextDayComponents.day = 1
        return nextDayComponents
    }
   
    
}
