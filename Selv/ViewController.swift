//
//  ViewController.swift
//  Selv
//
//  Created by Jesse Candido on 3/21/18.
//  Copyright © 2018 Jesse Candido. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func sharePressed(_ sender: Any) {
        
        let textToShare = [ textView.attributedText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func goToToday(_ sender: Any) {
        calendar.scope = .month
        let date = Calendar.current.date(bySettingHour: 3, minute: 00, second: 0, of: calendar.today!)!
        calendar.select(date)
        currentDate = date
        textView.endEditing(true)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    let imagePicker = UIImagePickerController()

    @IBAction func addImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue" {
            textView.endEditing(true)
            let vc = segue.destination as! Search
            vc.context = context
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                let textAttachment = NSTextAttachment()
                let newImage = resizeImage(image: image, newWidth: textView.frame.width)
                
                textAttachment.image = newImage
               // var newString = NSMutableAttributedString(attachment: textAttachment)
                let newString = NSMutableAttributedString(attachment: textAttachment)
                let customFont = UIFont(name: "AvenirNext-Regular", size: 20)!
                newString.addAttribute(NSAttributedString.Key.font, value: UIFontMetrics.default.scaledFont(for: customFont), range: NSRange(location: 0, length: newString.length))

               // let attrs = NSMutableAttributedString(string: "", attributes: [NSMutableAttributedString.Key.font: UIFontMetrics.default.scaledFont(for: customFont!)])
               // let str = NSMutableAttributedString(attributedString: textView.attributedText)
//                str.append(newString)
//
//                str.addAttribute(NSAttributedString.Key.font, value: customFont, range: NSRange(location: 0, length: str.length))
//
//                textView.attributedText = str //+ attrs
//                textView.scrollRangeToVisible(NSRange(location: str.length, length: 0))
                
                textView.textStorage.insert(newString, at: textView.selectedRange.location)
                textView.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
                textView.selectedRange.location += 2
                
                let bottomRange = NSRange(location: textView.selectedRange.location + 2, length: 1)
                
                textView.scrollRangeToVisible(bottomRange)

                //textView.endEditing(true)
                
//                let temp = NSMutableAttributedString(attributedString: textView.attributedText)
//                temp.addAttribute(NSAttributedString.Key.font, value: customFont, range: NSRange(location: 0, length: temp.length))
//                textView.attributedText = temp
            }
            dismiss(animated:true, completion: {
                super.dismiss(animated: true, completion: nil)
                self.textView.becomeFirstResponder()
                //self.textView.scrollToBottom()
                //self.textView.simple_scrollToBottom()
            })
        }
    }
    
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet var toolbarView: UIView!
    @IBOutlet weak var magicView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func boldText(_ sender: Any) {
        
        
        let range = textView.selectedRange
        
        let string = NSMutableAttributedString(attributedString:
            textView.attributedText)
        let font = textView.font?.toggleBold()
        string.addAttributes([.font: font!], range: range)
        textView.attributedText = string
        textView.selectedRange = range
    }
    

    @IBAction func italicText(_ sender: Any) {
        let range = textView.selectedRange
        let string = NSMutableAttributedString(attributedString:
            textView.attributedText)
        let font = textView.font?.toggleItalic()
        string.addAttributes([.font: font!], range: range)
        textView.attributedText = string
        textView.selectedRange = range
    }
    
    @IBAction func underlineText(_ sender: Any) {
        
        let range = textView.selectedRange
        let string = NSMutableAttributedString(attributedString:
            textView.attributedText)
        
        
        string.enumerateAttribute(NSAttributedString.Key.underlineStyle, in: range, options: .longestEffectiveRangeNotRequired) { attribute, range, pointer in
            if attribute != nil {
                string.removeAttribute(NSAttributedString.Key.underlineStyle, range: range)
            } else {
                string.addAttributes([NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue], range: range)
            }
        }
        
        
        
        
        textView.attributedText = string
        textView.selectedRange = range
        
       
    }
    
    var currentDate = Date() {
        willSet {
            print("current date updates: + \(newValue)")
            
            var attrs = NSMutableAttributedString()
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntry")
            request.predicate = NSPredicate(format: "timestamp = %@", newValue as CVarArg)
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    print("got data")
                    //print(data.value(forKey: "timestamp") as! String)
                    attrs = data.value(forKey: "attributes") as! NSMutableAttributedString
                    
//                    let customFont = UIFont(name: "AvenirNext-Regular", size: UIFont.labelFontSize)
//

//                    var range = NSRange(location: 0, length: attrs.length)
//                    if let font = attrs.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: &range) as? UIFont {
//                        attrs.addAttribute(NSMutableAttributedString.Key.font, value: UIFontMetrics.default.scaledFont(for: font), range: NSRange(location:0,length:attrs.length))
//                    }
                    
                    
                    
                        
                    
                    
                    
                    
                    note = Note(text: attrs.string, time: newValue)
                    textView.textStorage.setAttributedString(attrs)
                    
                    let newPosition = textView.endOfDocument
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)

                }
                if result.count == 0 {
                    print ("nothing here")
                    note = Note(text: "", time: newValue)
                    //let attstr = NSAttributedString(string: newValue.getMonthName() + " " + newValue.getDay() + "", attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .largeTitle)])
                   
                   // let customFont = UIFont(name: "AvenirNext-Regular", size: UIFont.labelFontSize)
                
                    // attrs = NSMutableAttributedString(string: "", attributes: [NSMutableAttributedString.Key.font: UIFontMetrics.default.scaledFont(for: customFont!)])
                    textView.textStorage.setAttributedString(attrs)
                    
                }
            } catch {
                print("Failed")
            }
            self.title = calendar.currentPage.getMonthName() + " " + calendar.currentPage.getYear()
            dateLabel.text = newValue.getMonthName() + " " + newValue.getDay()
            dateLabel.setNeedsDisplay()
           // print(newValue)
           // timeView = TimeIndicatorView(date: newValue)
           // textView.addSubview(timeView)
          //  updateTimeIndicatorFrame()
            textView.setNeedsDisplay()
            
        }
    }
    
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
   // var textStorage: NSTextStorage!//SyntaxHighlightTextStorage!
    //var timeView: TimeIndicatorView!
    
    
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
    
    @objc func reload(_ notification: Notification) {
        if let target = notification.userInfo?["item"] as? (Date, NSAttributedString) {
            calendar.scope = .month
            currentDate = target.0
            calendar.select(target.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveBeforeClosing), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Notification.Name(rawValue: "reload"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.saveBeforeClosing), name: UIApplication.willResignActiveNotification, object: nil)
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        let today = Calendar.current.date(bySettingHour: 3, minute: 00, second: 0, of: calendar.today!)!
        //self.calendar.select(today)
        calendar.select(today)
        currentDate = today
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calendar.scope = .week
        calendar.allowsMultipleSelection = false
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        toolbarView.sizeToFit()
        toolbarView.alpha = 0.9
        
        textView.tintColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = .white
        textView.inputAccessoryView = toolbarView
        textView.becomeFirstResponder()
        
        
        //textView.font = UIFontMetrics.default.scaledFont(for: customFont!)
        textView.textColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        textView.adjustsFontForContentSizeCategory = true
        
      //  textView.layoutManager.allowsNonContiguousLayout = false
      //  textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        //currentDate = calendar.selectedDate!
        let dateLabelFont = UIFont(name: "AvenirNext-DemiBold", size: 26)
        dateLabel.font = UIFontMetrics.default.scaledFont(for: dateLabelFont!)
        dateLabel.adjustsFontForContentSizeCategory = true
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
    }
    
    override func viewDidLayoutSubviews() {
       // updateTimeIndicatorFrame()
        //textStorage.update()
        super.viewDidLayoutSubviews()
        print("updated sotrage")
    }
    
    
    
//    func updateTimeIndicatorFrame() {
//        timeView.updateSize()
//        timeView.frame = timeView.frame.offsetBy(dx: textView.frame.width - timeView.frame.width, dy: 0)
//
//    }
    
    
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
        //self.navigationController?.isNavigationBarHidden = true
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
        currentDate = Calendar.current.date(bySettingHour: 3, minute: 00, second: 0, of: date)!

    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.title = calendar.currentPage.getMonthName() + " " + calendar.currentPage.getYear()
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
    
    func getYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
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
        newNote.setValue(NSMutableAttributedString(attributedString: textView.attributedText), forKey: "attributes")
        
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
    }
}


extension UIFont{
    
    func toggleBold () -> UIFont {
        return self.isBold ? desetBold() : setBold()
    }
    
    func toggleItalic () -> UIFont {
        return self.isItalic ? desetItalic() : setItalic()
    }
    
    
    var isBold: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool
    {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    
    func setBold() -> UIFont
    {
        if(isBold)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.insert([.traitBold])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
    
    func setItalic()-> UIFont
    {
        if(isItalic)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.insert([.traitItalic])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
    func desetBold() -> UIFont
    {
        if(!isBold)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.remove([.traitBold])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
    
    func desetItalic()-> UIFont
    {
        if(!isItalic)
        {
            return self
        }
        else
        {
            var fontAtrAry = fontDescriptor.symbolicTraits
            fontAtrAry.remove([.traitItalic])
            let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry)
            return UIFont(descriptor: fontAtrDetails!, size: pointSize)
        }
    }
}






func + (left: NSMutableAttributedString, right: NSMutableAttributedString) -> NSMutableAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}



extension UITextView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
//
//    override func paste(_ sender: Any?) {
//        let textAttachment = NSTextAttachment()
//        if let image = UIPasteboard.general.image {
//            let newImage = resizeImage(image: image, newWidth: self.frame.width)
//            textAttachment.image = newImage
//            //textAttachment.setImageWidth(width: self.frame.width)
//            attributedText = NSAttributedString(attachment: textAttachment)
//        }
//    }
    
   
}

extension NSTextAttachment {
    func setImageWidth(width: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: width, height: width / ratio)
    }
}

class TextView: UITextView {
    
    enum VerticalAlignment: Int {
        case Top = 0, Middle, Bottom
    }
    
    var verticalAlignment: VerticalAlignment = .Middle
    
    //override contentSize property and observe using didSet
    override var contentSize: CGSize {
        didSet {
            let textView = self
            let height = textView.bounds.size.height
            let contentHeight:CGFloat = contentSize.height
            var topCorrect: CGFloat = 0.0
            switch(self.verticalAlignment){
            case .Top:
                textView.contentOffset = CGPoint.zero //set content offset to top
            case .Middle:
                topCorrect = (height - contentHeight * textView.zoomScale)/2.0
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
            case .Bottom:
                topCorrect = textView.bounds.size.height - contentHeight
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
            }
            if contentHeight >= height { //if the contentSize is greater than the height
                topCorrect = contentHeight - height //set the contentOffset to be the
                topCorrect = topCorrect < 0 ? 0 : topCorrect //contentHeight - height of textView
                textView.contentOffset = CGPoint(x: 0, y: topCorrect)
            }
        }
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.contentSize //forces didSet to be called
        self.contentSize = size
    }
}
