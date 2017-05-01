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

class DeviceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let devices = DeviceManager.manager.knownDevices.asObservable()
        
        devices.bindTo(tableView.rx.items(cellIdentifier: "device")) { row, element, cell in
            cell.textLabel?.text = element.name
        }.disposed(by: rx_disposeBag)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
