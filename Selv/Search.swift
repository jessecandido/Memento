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
    
    lazy var dataArray = [(date: Date, text: String)]()
    
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
        cell.detailTextLabel?.text = note.text
        // Avoid loading image that we don't need anymore
        // Load the image and display another image during the loading
        return cell
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
                    dataArray.append((date as! Date, (text as! NSAttributedString).string))
                }
            }
        }
        catch {}
    }
}
