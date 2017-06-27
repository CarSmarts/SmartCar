//
//  MessageSetListTableViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 6/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class MessageSetListTableViewController: UITableViewController {
    
    var messageSets = [URL]()
    let fileManager = FileManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // Load Messages
        do {
            let base = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            messageSets += ["Hi", "Hello"].map { URL(fileURLWithPath: $0, relativeTo: base) }
            
        } catch let error as NSError {
            // TODO: some error happened
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    enum MessageSection: Int {
        case new = 0
        case messageSet = 1
        
        init(_ section: Int) {
            guard let newSelf = MessageSection(rawValue: section) else { fatalError("Section \(section) is not valid")}
            self = newSelf
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MessageSection(section) {
        case .new:
            return 1
        case .messageSet:
            return messageSets.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageSet", for: indexPath)
        
        let text: String
        
        switch indexPath.messageSection {
        case .new: text = "Record New Set"
        case .messageSet: text = messageSets[indexPath.row].lastPathComponent
        }
        
        cell.textLabel?.text = text

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.messageSection == .messageSet
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: Delete the row from the data source
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension IndexPath {
    var messageSection: MessageSetListTableViewController.MessageSection {
        return MessageSetListTableViewController.MessageSection(section)
    }
}
