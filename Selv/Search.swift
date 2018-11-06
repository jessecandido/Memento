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
        
        //cell.detailTextLabel?.text = note.text
        cell.textLabel?.text = note.date.getMonthName() + " " + note.date.getDay() + ", " + note.date.getYear()
        cell.detailTextLabel?.text = note.text.string
        // Avoid loading image that we don't need anymore
        // Load the image and display another image during the loading
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = ["item": dataArray[indexPath.row]]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil, userInfo: userInfo)
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = .white
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func fetchData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntry")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print("got data")
                if let date = data.value(forKey: "timestamp"), let text = data.value(forKey: "attributes") {
                    dataArray.append((date as! Date, text as! NSAttributedString))
                }
            }
        }
        catch {}
    }
}
