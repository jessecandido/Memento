//
//  Search.swift
//  Selv
//
//  Created by Jesse Candido on 11/6/18.
//  Copyright © 2018 Jesse Candido. All rights reserved.
//

import Foundation
import CoreData

class Search : UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    lazy var dataArray = [(date: Date, text: NSAttributedString)]()
    
    lazy var dataArrayOriginal = [(date: Date, text: NSAttributedString)]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return dataArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseCell", for: indexPath)
        // Configure the cell...
        let note = dataArray[indexPath.row]
        
        let color = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        let initialtext = note.date.getMonthName() + " " + note.date.getDay() + ", " + note.date.getYear()
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: initialtext)
        let range: NSRange = (initialtext as NSString).range(of: searchBar.text!, options: .caseInsensitive)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        cell.textLabel?.attributedText = attrString
        
        
        let detailText = note.text.string.removingNewlines
        let detailString: NSMutableAttributedString = NSMutableAttributedString(string: detailText)
        let detailRange: NSRange = (detailText as NSString).range(of: searchBar.text!, options: .caseInsensitive)
        detailString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: detailRange)
        cell.detailTextLabel?.attributedText = detailString
        
        // Avoid loading image that we don't need anymore
        // Load the image and display another image during the loading
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = ["item": dataArray[indexPath.row]]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil, userInfo: userInfo)
        self.navigationController?.popViewController(animated: true)
    }
    
    

    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        searchBar.delegate = self
        searchBar.placeholder = "Search Notes"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = .white
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataArray.isEmpty ? "No results" : ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if(searchText == ""){
            dataArray = dataArrayOriginal
        } else {
            //dataArray = dataArrayOriginal.
            dataArray = dataArrayOriginal.filter {$0.text.string.lowercased().contains(searchText.lowercased()) || $0.date.getDay() == searchText || $0.date.getMonthName().contains(searchText) || $0.date.getYear() == searchText}
        }
        tableView.reloadData()
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func fetchData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntry")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print("got data")
                if let date = data.value(forKey: "timestamp"), let text = data.value(forKey: "attributes") {
                    if(!((text as? NSAttributedString)?.string.isEmpty)!){
                        dataArrayOriginal.append((date as! Date, text as! NSAttributedString))
                    }
                }
            }
            dataArrayOriginal.sort {$0.date < $1.date }
            dataArray = dataArrayOriginal
            
        }
        catch {}
    }
}



extension String {
    var removingNewlines: String {
        return components(separatedBy: .newlines).joined(separator: " ")
    }
}


import UIKit

struct AppFontName {
    static let regular = "AvenirNext-Regular"
    static let bold = "AvenirNext-Bold"
    static let italic = "AvenirNext-Italic"
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        var fontName = ""
        switch fontAttribute {
        case "CTFontRegularUsage":
            fontName = AppFontName.regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFontName.bold
        case "CTFontObliqueUsage":
            fontName = AppFontName.italic
        default:
            fontName = AppFontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
        
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}



