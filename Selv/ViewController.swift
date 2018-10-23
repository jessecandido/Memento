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
    
    var context: NSManagedObjectContext!
    
    @IBAction func boldText(_ sender: Any) {
        
        
        let range = textView.selectedRange
        
        let string = NSMutableAttributedString(attributedString:
            textView.attributedText)
        let font = textView.font?.toggleBold()
        string.addAttributes([.font: font!], range: range)
        textView.attributedText = string
        textView.selectedRange = range
    }
    
    var currentDate = Date() {
        willSet {
            print("current date updates: + \(newValue)")
            
            var attrs = NSAttributedString()
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntry")
            request.predicate = NSPredicate(format: "timestamp = %@", newValue as CVarArg)
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    print("got data")
                    //print(data.value(forKey: "timestamp") as! String)
                    attrs = data.value(forKey: "attributes") as! NSAttributedString
                    note = Note(text: attrs.string, time: newValue)
                    textStorage.setAttributedString(attrs)
                }
                if result.count == 0 {
                    print ("nothing here")
                    note = Note(text: " ", time: newValue)
                    attrs = NSAttributedString(string: " ", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)])
                    textStorage.setAttributedString(attrs)
                }
            } catch {
                print("Failed")
            }
            
           // print(newValue)
            timeView = TimeIndicatorView(date: newValue)
            textView.addSubview(timeView)
            updateTimeIndicatorFrame()
            textView.setNeedsDisplay()
            
        }
    }
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    var textStorage: NSTextStorage!//SyntaxHighlightTextStorage!
    var timeView: TimeIndicatorView!
    
    
    var note: Note!
    
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
        textView.endEditing(true)
        textView.resignFirstResponder()
    }
    
    @objc func saveBeforeClosing(){
        textView.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveBeforeClosing), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveBeforeClosing), name: UIApplication.willResignActiveNotification, object: nil)
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
    
        
        createTextView()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        let today = Date()
        self.calendar.select(today)
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendar.scope = .week
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        toolbarView.sizeToFit()
        toolbarView.alpha = 0.9
        
        
        
        textView.isScrollEnabled = true
        navigationController?.navigationBar.barStyle = .black
        textView.adjustsFontForContentSizeCategory = true
        
        textView.tintColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        textView.inputAccessoryView = toolbarView

        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        currentDate = calendar.selectedDate!
        
    }
    
    override func viewDidLayoutSubviews() {
        updateTimeIndicatorFrame()
        //textStorage.update()
        print("updated sotrage")
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
        textView.endEditing(true)
        currentDate = date
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func toggleClicked(sender: AnyObject) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    func createTextView() {
        // 1
       // let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
       // let attrString = NSAttributedString(string: note.contents, attributes: attrs)
        textStorage = NSTextStorage() //SyntaxHighlightTextStorage()
      //  textStorage.append(attrString)
        
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
        textView.allowsEditingTextAttributes = true
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
        print("didendediting")
        let entity = NSEntityDescription.entity(forEntityName: "NoteEntry", in: context)
        let newNote = NSManagedObject(entity: entity!, insertInto: context)
        newNote.setValue(currentDate, forKey: "timestamp")
        newNote.setValue(textView.attributedText, forKey: "attributes")
        
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
    }
}


extension UIFont {
    
    func toggleBold () -> UIFont {
        return self.isBold ? removeBold() : setBold()
    }
    
    var isBold: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    func setBold() -> UIFont
    {
        if isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.insert([.traitBold])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
    }
    
    func removeBold()-> UIFont
    {
        if !isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.remove([.traitBold])
            let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: fontDescriptorVar!, size: 0)
        }
    }
    
}
