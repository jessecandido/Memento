//
//  ViewController.swift
//  Selv
//
//  Created by Jesse Candido on 3/21/18.
//  Copyright © 2018 Jesse Candido. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
    
        
        let today = Date()
        self.calendar.select(today)
        dateField.text = today.getMonthName() + " " + today.getDay()
        // TODO: get data for today here.
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendar.scope = .week
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        toolbarView.sizeToFit()
        toolbarView.alpha = 0.9
        textView.inputAccessoryView = toolbarView
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        // TODO: get data for the new date
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    
    // MARK:- Target actions
    
    @IBAction func toggleClicked(sender: AnyObject) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
}



extension Date {
    
    func getMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
    func getDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let strDay = dateFormatter.string(from: self)
        return strDay
    }
    
    
}
