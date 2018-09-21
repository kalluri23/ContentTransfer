//
//  CTSTMOpionViewController.swift
//  contenttransfer
//
//  Created by Sun, Xin on 4/20/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/**
 This this the controller to let user choose either go next to one-to-many transfer or go back to one-to-one normal transfer.
 
 As per design, once choice is made in this controller, there wil be no back button until user restart the app completly.
 */
public class CTSTMOpionViewController: CTViewController, UITableViewDelegate, UITableViewDataSource {
    /** Static string value for navigation bar title.*/
    static let CTNavigationTitle                        = CTLocalizedString(CT_DEVICES_STORYBOARD_NAV_TITLE, comment: "")
    /** Static string value for option title.*/
    static let CTOneToManyiPhoneToiPhoneOptionTitle     = CTLocalizedString(CT_MULTIPLE_PHONE_OPTION, comment: "")
    /** Static string value for option subtitle.*/
    static let CTOneToManyiPhoneToiPhoneOptionSubtitle  = CTLocalizedString(CT_IOS_DEVICES_ONLY_OPTION, comment: "")
    /** Static string value for option title.*/
    static let CTOneToManyAndroidToiPhoneOptionTitle    = CTLocalizedString(CT_MULTIPLE_PHONE_OPTION, comment: "")
    /** Static string value for option subtitle.*/
    static let CTOneToManyAndroidToiPhoneOptionSubtitle  = CTLocalizedString(CT_COMBINATION_OPTION, comment: "")
    /** Static string value for table view cell ID.*/
    static let CTSTMOptionTableViewCellIdentifier       = "advanced_cell"
    
    /** TableView using in this controller. This is an IBOutlet object.*/
    @IBOutlet weak var optionTableView: UITableView!
    /** Next button using in this controller. This is an IBOutlet object.*/
    @IBOutlet weak var nextBtn: CTCommonBlackButton!
    /** Back button using in this controller. This is an IBOutlet object.*/
    @IBOutlet weak var backBtn: CTBlackBorderedButton!
    
    /** Array of possible options provided to user. This array is using for updating the table view. All the value in this array should be read from static string value.*/
    private let optionsArray: Array<String> = [CTOneToManyiPhoneToiPhoneOptionTitle, CTOneToManyAndroidToiPhoneOptionTitle]
    /** Array of possible options provided to user. This array is using for updating the table view. All the value in this array should be read from static string value.*/
    private let optionsSubTitleArray: Array<String> = [CTOneToManyiPhoneToiPhoneOptionSubtitle, CTOneToManyAndroidToiPhoneOptionSubtitle]
    
    /** Index of selected cell for table view.*/
    private var indexSelected: Int = 0;
    /** Enum value for index of the table view.*/
    private enum CTSTMOptionIndex:Int {
        /** iPhone to iPhone index.*/
        case iPhoneToiPhone
        /** Android to iPhone index. Temp value.*/
        case AndroidToiPhone
    }
    
    // MARK: - View controller lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = CTSTMOpionViewController.CTNavigationTitle;
        
        #if STANDALONE
            self.setNavigationControllerMode(.none)
        #else
            self.setNavigationControllerMode(.backAndHamburgar)
        #endif
        
        self.optionTableView.tableFooterView = UIView()
        
        self.backBtn.isEnabled = true
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView datasource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transferFlow == .sender ? 1 : 2
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CTSingleChoiceTableViewCell = tableView.dequeueReusableCell(withIdentifier: CTSTMOpionViewController.CTSTMOptionTableViewCellIdentifier, for: indexPath) as! CTSingleChoiceTableViewCell
        
        // Original text: "Multiple phone transfer"
        cell.cellLabel.text = self.optionsArray[indexPath.row]
        cell.cellSubLabel.text = self.optionsSubTitleArray[indexPath.row]
        
        return cell;
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 2;
    }
    
    // MARK: - TableView delegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: CTSingleChoiceTableViewCell = tableView.cellForRow(at: indexPath) as! CTSingleChoiceTableViewCell
        
        cell.highlightCell(true)
        
        self.indexSelected = indexPath.row // replace the last selected row;
        self.nextBtn.isEnabled = true;
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: CTSingleChoiceTableViewCell = tableView.cellForRow(at: indexPath) as! CTSingleChoiceTableViewCell
        cell.highlightCell(false)
    }
    
    // MARK: - User actions (IBActions)
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func next(_ sender: Any) {
        if (self.indexSelected == CTSTMOptionIndex.iPhoneToiPhone.rawValue) {
            CTUserDevice().isAndroidPlatform = "FALSE"
            CTUserDevice().phoneCombination  = IOS_IOS
            CTUserDevice().pairingType = kP2M // Indicate this is one-to-many
            
            if (self.transferFlow == .sender) {
                // start Sender Connection UI
                let targetViewController = CTSTMSenderViewController()
                self.navigationController?.pushViewController(targetViewController, animated: true)
            } else {
                // start Recv Connection UI
                let targetViewController = CTSTMRecvScannerViewController.init(nibName: "CTSTMRecvScannerViewController", bundle: CTBundle.resourceBundle())
                self.navigationController?.pushViewController(targetViewController, animated: true)
            }
        } else { // Android to iOS value for now
            CTUserDevice().isAndroidPlatform = "TRUE"
            CTUserDevice().phoneCombination  = IOS_Andriod
            CTUserDevice().pairingType = kP2P // Indicate this is one-to-many
            
            assert(self.transferFlow == .receiver) // Should never be sender side in this case
            
            let targetViewController: CTSenderScannerViewController = CTSenderScannerViewController.initialise(from: CTStoryboardHelper.qrCodeAndScannerStoryboard())
            targetViewController.transferFlow = .receiver
            targetViewController.isForSTM     = true
            UserDefaults.standard.set(targetViewController.isForSTM, forKey: "transferIsOneToMany")
            
            self.navigationController?.pushViewController(targetViewController, animated: true)
        }
    }
}
