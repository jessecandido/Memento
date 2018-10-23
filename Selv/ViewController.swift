//
//  ViewController.swift
//  Selv
//
//  Created by Jesse Candido on 3/21/18.
//  Copyright © 2018 Jesse Candido. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    var textView: UITextView!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet weak var magicView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    var textStorage: SyntaxHighlightTextStorage!
    var timeView: TimeIndicatorView!
    
    
    var note = Note(text: "Shopping List\r\r1. Cheese\r2. Biscuits\r3. Sausages\r4. IMPORTANT Cash for going out!\r5. -potatoes-\r6. A copy of iOS8 by Tutorials\r7. A new iPhone\r8. A present for mum")
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func doneButton(_ sender: Any) {
        textView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
    
        
        let today = Date()
        self.calendar.select(today)
        updateDate(today)
        
        // TODO: get data for today here.
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendar.scope = .week
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        toolbarView.sizeToFit()
        toolbarView.alpha = 0.9
        
        createTextView()
        
        textView.isScrollEnabled = true
        navigationController?.navigationBar.barStyle = .black
        textView.adjustsFontForContentSizeCategory = true
        timeView = TimeIndicatorView(date: note.timestamp)
        textView.tintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        textView.addSubview(timeView)
        
        //    NotificationCenter.default.addObserver(self,
        //                                           selector: #selector(keyboardDidShow),
        //                                           name: UIResponder.keyboardDidShowNotification,
        //                                           object: nil)
        //    NotificationCenter.default.addObserver(self,
        //                                           selector: #selector(keyboardDidHide),
        //                                           name: UIResponder.keyboardDidHideNotification,
        //                                           object: nil)
        textView.inputAccessoryView = toolbarView
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        updateTimeIndicatorFrame()
        textStorage.update()
        
    }
    
    func updateTimeIndicatorFrame() {
        timeView.updateSize()
        timeView.frame = timeView.frame.offsetBy(dx: textView.frame.width - timeView.frame.width, dy: 0)
        let exclusionPath = timeView.curvePathWithOrigin(timeView.center)
        textView.textContainer.exclusionPaths = [exclusionPath]
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {
        textView.frame = CGRect(x: 0, y: 0, width: magicView.frame.width, height: magicView.frame.height - keyboardHeight - toolbarView.frame.height)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        if let rectValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = rectValue.cgRectValue.size
            updateTextViewSizeForKeyboardHeight(keyboardHeight: keyboardSize.height)
        }
        
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        updateTextViewSizeForKeyboardHeight(keyboardHeight: 0)
    }
    
    
    
    func updateDate(_ date: Date){
       // dateField.text = date.getMonthName() + " " + date.getDay()
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
    
    func createTextView() {
        // 1
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        let attrString = NSAttributedString(string: note.contents, attributes: attrs)
        textStorage = SyntaxHighlightTextStorage()
        textStorage.append(attrString)
        
        let newTextViewRect = magicView.bounds
        
        // 2
        let layoutManager = NSLayoutManager()
        
        // 3
        let containerSize = CGSize(width: newTextViewRect.width, height: .greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        // 4
        textView = UITextView(frame: newTextViewRect, textContainer: container)
        textView.delegate = self
        magicView.addSubview(textView)
        
        // 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: magicView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: magicView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: magicView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: magicView.bottomAnchor)
            ])
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

// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.contents = textView.text
    }
}
