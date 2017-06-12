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

class DeviceListViewController: UITableViewController, DeviceManagerDelegate {
    
    private var devices = [CarSmartsDevice]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DeviceManager.manager.delegate = self
    }
    
    var scanDisposable = DisposeBag()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DeviceManager.manager.attemptScan.observeOn(MainScheduler.instance)
        .flatMapLatest { state -> Observable<String> in
            switch state {
            case .poweredOn:
                return dots(initialString: "Scanning", range: 1...3, timeInterval: 1)
            case .poweredOff:
                return .just("Bluetooth Off")
            case .unauthorized:
                return .just("Authorize in settings")
            case .unknown, .resetting:
                return .just("Unknown")
            case .unsupported:
                return .just("Bluetooth Not supported")
            }
        }
        .subscribe(onNext: { self.title = $0 })
        .disposed(by: scanDisposable)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scanDisposable = DisposeBag() // cancel any scans
    }
    
    // MARK: - DeviceManagerDelegate
    
    func deviceManger(didDiscover device: CarSmartsDevice) {
        let newIndexPath = IndexPath(row: devices.count, section: 0)

        devices.append(device)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func deviceManager(didRestore knownDevices: [CarSmartsDevice]) {
        let newIndexPaths = (devices.count..<knownDevices.count).map { IndexPath(row: $0, section: 0) }
        
        devices += knownDevices
        tableView.insertRows(at: newIndexPaths, with: .automatic)
    }
    
    // MARK: - UITableViewDelegate?

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath)
    
        let device = devices[indexPath.row]
        
        cell.textLabel?.isEnabled = device.isConnected
        cell.textLabel?.text = device.name

        return cell
    }
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let selectedDevice: CarSmartsDevice? = decodeSegue(sender: sender, modelArray: devices)
        
        if let destination = segue.destination as? DeviceViewController {
            destination.device = selectedDevice
        }
    }
    

}
