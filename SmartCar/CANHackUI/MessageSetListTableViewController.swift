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
    let decoder = PropertyListDecoder()

    
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
    
    @IBAction func newSet(_ sender: Any) {
        let set = MessageSet(from: UIPasteboard.general.string ?? "")
        
        performSegue(withIdentifier: "Show Message Set", sender: set)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageSet", for: indexPath)

        cell.textLabel?.text = messageSets[indexPath.row].lastPathComponent

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: Delete the row from the data source
            messageSets.remove(at: indexPath.row)
            
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
    
    
    // MARK: - Navigation

    private func loadMessageSet(for cell: UITableViewCell) -> MessageSet? {
        let url = messageSets[tableView.indexPath(for: cell)!.row]
        guard let data = fileManager.contents(atPath: url.absoluteString) else {
            Logger.error("Trying to prepare messageSetVC but unable to read message set")
            return nil
        }
        
        guard let set = try? decoder.decode(MessageSet.self, from: data) else {
            Logger.error("Trying to prepare messageSetVC but unable to decode messageset")
            return nil
        }
        
        return set
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if let messageSetViewController = segue.finalDestination as? MessageSetTableViewController {
            
            if let cell = sender as? UITableViewCell {
                messageSetViewController.messageSet = loadMessageSet(for: cell)
            } else if let set = sender as? MessageSet {
                messageSetViewController.messageSet = set
            } else {
                assertionFailure("Trying to prepare messageSetVC but sender gives no information")
                return
            }
            
        }
    }
    

}
