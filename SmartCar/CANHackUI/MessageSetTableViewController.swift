//
//  MessageSetTableViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 11/4/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class MessageSetTableViewController: UITableViewController {

    var messageSet: SignalSet<Message>! {
        didSet {
            if let messageSet = messageSet {
                groupedMessages = GroupedSignalSet(grouping: messageSet, by: { (stat) -> MessageID in
                    stat.signal.id
                })
            }
        }
    }
    
    private var groupedMessages: GroupedSignalSet<Message, MessageID>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedMessages.groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MessageIDStatTableViewCell
        let group = groupedMessages.groups[indexPath.row]

        // TODO: Switch to do something different when there are more than 10 values
        cell.groupStats = groupedMessages[group]
        cell.scale = messageSet.scale

        return cell
    }


    @IBAction func testAdd(_ sender: Any) {
        let testData = UIPasteboard.general.string ?? "4157,0xAF81111,true,Rx,1,2,00,00"
        
        if let testMessage = GVRetParser().parse(line: testData) {
            messageSet.add(testMessage)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let messageStatViewController = segue.finalDestination as? MessageStatViewController,
           let cell = sender as? MessageIDStatTableViewCell {
            
                messageStatViewController.groupStats = cell.groupStats
        }
    }
}
