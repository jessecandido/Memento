//
//  ViewController.swift
//  Selv
//
//  Created by Jesse Candido on 3/21/18.
//  Copyright © 2018 Jesse Candido. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    
    //TODO: all deselected when first open the app
    
    //TODO: deselect save
    var activities: [NSManagedObject] = []
    
    var dictionary = [String: [String]]()

    var selectedDayString = String()
    
    var selectedDay = Date() {
        didSet {
            tableView.deselectAll()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let dateNew = dateFormatter.string(from: selectedDay)
            print("DATEEEE: \(dateNew)")
            selectedDayString = dateNew
            let actions = dictionary[dateNew]
            
            let totalSections = tableView.numberOfSections
            for section in 0 ..< totalSections {
                let indexPath = IndexPath(row: 0, section: section)
                let cell = tableView.cellForRow(at: indexPath)!
                let text = cell.textLabel?.text
                if(actions?.index(of: text!) != nil){
                    //print (text)
                    tableView(tableView, didSelectRowAt: indexPath)
                }
                    // call the delegate's willSelect, select the row, then call didSelect
            }
            
            print(dictionary)
            
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "New Activity",
                                      message: "Add a new activity",
                                      preferredStyle: .alert)
        let color = UIColor.random
        let FirstSubview = alert.view.subviews.first
        let AlertContentView = FirstSubview?.subviews.first
        for subview in (AlertContentView?.subviews)! {
            subview.backgroundColor = color
            subview.layer.cornerRadius = 10
            subview.alpha = 1
            subview.layer.borderWidth = 1
            subview.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        }
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        self.save(name: nameToSave, color: color)
                                        self.tableView.reloadData()
        }
        saveAction.setValue(UIColor.white, forKey: "titleTextColor")
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .destructive)

        let myString  = "New Activity"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String)
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
        alert.setValue(myMutableString, forKey: "attributedTitle")
        
        let message  = "Add a new activity"
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message as String)
        messageMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location:0,length:message.characters.count))
        alert.setValue(messageMutableString, forKey: "attributedMessage")
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    func save(name: String, color: UIColor) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Activity",
                                       in: managedContext)!
        let action = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        action.setValue(name, forKeyPath: "name")
        action.setValue(color, forKeyPath: "color")
        do {
            try managedContext.save()
            activities.append(action)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
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
        self.selectedDay = Date()
        self.calendar.select(Date())
        
        // TODO: get data for today here.
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext

        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Activity")
        do {
            activities = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.tableView.allowsMultipleSelection = true;
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
       // print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        selectedDay = date
        // TODO: get data for the new date
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = activities[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.layer.cornerRadius = 7
        cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.selectionStyle = .none
        cell.textLabel?.text = action.value(forKey: "name") as? String
        return cell
    }
    
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let action = activities[indexPath.section]
        cell.backgroundColor = action.value(forKey: "color") as? UIColor
        
        var act = [String]()
        if(dictionary[selectedDayString] != nil){
            act = dictionary[selectedDayString]!
        }
        if let text = cell.textLabel?.text{
            if(act.index(of: text) == nil){
                act.append(text)
            }
            dictionary[selectedDayString] = act
        }
        
       // mark activity as YES for this day
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
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


extension UITableView {
    func deselectAll(animated: Bool = false) {
        let totalSections = self.numberOfSections
        for section in 0 ..< totalSections {
            let totalRows = self.numberOfRows(inSection: section)
            for row in 0 ..< totalRows {
                let indexPath = IndexPath(row: row, section: section)
                // call the delegate's willSelect, select the row, then call didSelect
                self.deselectRow(at: indexPath, animated: animated)
                self.delegate?.tableView?(self, didDeselectRowAt: indexPath)
            }
        }
    }
}








extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}
