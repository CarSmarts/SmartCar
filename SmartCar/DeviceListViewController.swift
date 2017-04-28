//
//  DeviceListViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DeviceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let devices = DeviceManager.manager.knownDevices.asDriver()
        
        devices.drive(tableView.rx.items(cellIdentifier: "device", cellType: UITableViewCell.self)) { ip, device, cell in
            cell.textLabel?.text = device.name
        }.disposed(by: rx_disposeBag)
    }
    
    var scanDisposable = DisposeBag()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DeviceManager.manager.scan.subscribe().disposed(by: scanDisposable)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scanDisposable = DisposeBag() // cancel any scans
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
