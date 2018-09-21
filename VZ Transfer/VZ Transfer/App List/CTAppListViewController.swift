//
//  AppListViewController.swift
//  test
//
//  Created by Sun, Xin on 4/4/17.
//  Copyright © 2017 Sun, Xin. All rights reserved.
//

import UIKit

@objc public protocol CTAppListDelegate {
    func CTAppListWillPopBack()
}
/**
 View controller for showing app list received from Android side. The raw list will be used to execute a search progress using iTunes search API to remove all the apps that don't belong to Apple Store.
 
 After list generated, allow user to use button to run Apple Store search.
 
 User allow to save the list, and continue saving it later.
 - note: This controller will filter the app by name only. Result will not be accurate, since same app from same company can use different app name for their product in Apple Store and Andorid Store.
 */
public class CTAppListViewController: CTViewController, UITableViewDelegate, UITableViewDataSource, AppListTableViewCellDelegate {
    
    // MARK: - Local Constants
    /** Constant struct for app list table view controller. This contains all the constants using in this controller.*/
    struct AppListConstants {
        /** Static varible for navigation title.*/
        static let navigationTitle  : String     = CTLocalizedString(CT_APP_LIST_VC_NAV_TITLE, comment: "")
        /** Static varible for no internet connection prompt context.*/
        static let noInternetContext: String     = CTLocalizedString(CT_NO_INTERNET_CONTEXT, comment: "")
        /** Static varible for no internet connection prompt go to setting button title.*/
        static let noInternetGotoSetting: String = CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, comment: "")
        /** Static varible for save list prompt context.*/
        static let saveListAlertContext : String = CTLocalizedString(CT_SAVE_LIST_ALERT_CONTEXT, comment: "")
        /** Static varible for table view cell identifier.*/
        static let cellIdentifier   : String     = "app_cell"
//        static let appStoreSearch   : String     = "itms-apps://itunes.apple.com/WebObjects/MZSearch.woa/wa/search?term=%@&country=us&entity=software"
        
        /** Static varible for app store search link.*/
        static let appStoreSearch   : String     = "itms-apps://itunes.apple.com/WebObjects/MZSearch.woa/wa/search?lang=1&term=%@"
        /** Static varible for itunes search API link.*/
        static let itunsSearchAPI   : String     = "https://itunes.apple.com/search?term=%@&country=us&entity=software"
        /** Deprecated.*/
        static let maxAppsDispalyNum : Int     = 7
        /** Static varible for fixed app list cell height.*/
        static let fixedAppCellHeight: CGFloat = 60
        /** Static varible for fixed app list cell height for small screen.*/
        static let fixedAppCellSmallHeight: CGFloat = 128 // 96 for 4 cells, 128 for 3 cells
    }
    
    // MARK: - Prameters
    /** List of saved item, this item will be used in receiver side only.*/
    @objc public var savedItemsList: NSArray?
    /** Total Data Transferred.*/
    @objc public var totalDataTransferred: NSNumber?
    /** Acutal Data Transferred.*/
    @objc public var actualDataTransferred: NSNumber?
    /** Transfer speed.*/
    @objc public var transferSpeed: NSString?
    /** Transfer status: success/interrupted/connection_failed, etc. Using CTTransferStatus.*/
    @objc public var transferStatusAnalytics: CTTransferStatus = .success // default is success
    /** Transfer time.*/
    @objc public var transferTime: NSString?
    /** List of photo failed to store locally.*/
    @objc public var photoFailedList: NSArray?
    /** List of video failed to store locally.*/
    @objc public var videoFailedList: NSArray?
    /** Number of reminder transferred.*/
    @objc public var numberOfReminder = 0
    /** Number of reminder photos.*/
    @objc public var numberOfPhotos = 0;
    /** Number of reminder videos.*/
    @objc public var numberOfVideos = 0;
    /** Number of reminder contacts.*/
    @objc public var numberOfContacts = 0;
    /** Number of reminder calendars.*/
    @objc public var numberOfCalendar = 0;
    /** Number of reminder apps.*/
    @objc public var numberOfApps = 0;
    /** Bool value indicate this is normal transfer flow, if false means this view pop up from landing page as part of recover saving.*/
    @objc public var normalProcess: Bool = true
    /** CTAppListDelegate delegate protocal for app list call back.*/
    @objc public var delegate: CTAppListDelegate? = nil

    /** Number of apps inside the list without filter.*/
    private var appCount   : Int = 0
    /** Number of cell will be completely showed inside one screen without scroll.*/
    private var num        : Int = 0
    /** Data set for CTApp objects.*/
    private var dataset    : Array<CTApp> = []
    /** Bool value indicate this is the first time loading this page or not. Default value is **false**.*/
    private var firstLoad  : Bool = false
    /** Bool value indicate that current device has internet connection or not.*/
    private var hasInternet: Bool = false
    /** Bool value indicate that apps search is done or not.*/
    private var appsDone   : Bool = false
    /**
     Bool value indicate that internet error alert showed already or not.
     
     This property will make sure that internet error prompt will only be showed once per transfer.
     */
    private var alertShowed: Bool = false
    
    /** Operation queue using for fetch apps. This is lazy loading property, will automatically init when first called.*/
    private lazy var fetchQueue: OperationQueue = {
        let tempQueue = OperationQueue.init()
        return tempQueue
    }()
    /**
     Activity indicator using in app list controller. This is lazy loading property, will automatically init when first called.
     - SeeAlso: CTProgressHUD
     */
    private lazy var activityIndicator : CTProgressHUD = {
        let tempIndicator = CTProgressHUD.init(view: self.view)
        return tempIndicator!
    }()
    
    // MARK: - Outlets
    /** Table view using in app list controller. This is IBOutlet class.*/
    @IBOutlet weak var appListTableView: UITableView!
    /** Footer view for app list table view. This is IBOutlet class.*/
    @IBOutlet weak var scrollFooterView: UIView!
    /** Constaints of the height of footer. This is IBOutlet class.*/
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    /** Label for scrollable information. This is IBOutlet class.*/
    @IBOutlet weak var scrollLabel: CTRomanFontLabel!
    /** Label to show all kinds of error message in the middle of the screen. Either showing this label or table view. This is IBOutlet class.*/
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBottomMarginConstraint: NSLayoutConstraint!
    
    // MARK: - ViewController LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstLoad = true
        
#if STANDALONE
        self.setNavigationControllerMode(CTNavigationControllerMode.none)
#else
        self.setNavigationControllerMode(CTNavigationControllerMode.backAndHamburgar)
#endif
        self.title = AppListConstants.navigationTitle
        
        // Register the tableview cell
        self.appListTableView.register(UINib.init(nibName: "CTAppListTableViewCell", bundle: Bundle.init(for: CTAppListTableViewCell.self)), forCellReuseIdentifier: AppListConstants.cellIdentifier)
        self.appListTableView.delegate   = self
        self.appListTableView.dataSource = self
        self.appListTableView.tableFooterView = UIView()
        if (CTDeviceMarco.isiPhone4AndBelow()) { // if it's iPhone 4 screen size
            self.num = Int(self.appListTableView.frame.size.height / AppListConstants.fixedAppCellSmallHeight) // downgrade
        } else {
            self.num = Int(self.appListTableView.frame.size.height / AppListConstants.fixedAppCellHeight) // downgrade
        }
        
        if (CTDeviceMarco.isiPhoneX()) {
            // New title position for new height of navigation bar
            self.titleTopMarginConstraint.constant += 24;
            // Button add extra pixel for new screen layout
            self.btnBottomMarginConstraint.constant *= 2;
        }
        
        // Add observer for wifi change
        NotificationCenter.default.addObserver(self, selector: #selector(checkWifiConnectionAgain), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        self.errorLabel.text = AppListConstants.noInternetContext.replacingOccurrences(of: ". ", with: ".\n\n")
        self.errorLabel.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        
        self.checkInternetConnection { (hasNetwork) in
            if (hasNetwork) { // has network
                DispatchQueue.main.async {
                    self.appListTableView.isHidden = false
                    self.errorLabel.isHidden = true
                }
                self.hasInternet = true
                self.fetchQueue.addOperation {
                    self._prepareData()
                }
            } else {
                DispatchQueue.main.async {
                    self.appListTableView.isHidden = true
                    self.errorLabel.isHidden = false
                }
                self.hasInternet = false
                print("No Internet connection, pop up the alert")
                self.enableUserInteractionWithDelay(delay: 0)
                
                self.alertShowed = true

                if (CTContentTransferSetting.userCustomVerizonAlert()) {
                    CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: AppListConstants.noInternetContext, cancelBtnText: AppListConstants.noInternetGotoSetting, confirmBtnText: CTLocalizedString(CTAlertGeneralIgnoreTitle, comment: ""), confirmHandler: nil, cancelHandler: { (alertVC: CTVerizonAlertViewController) in
                        CTSettingsUtility.openWifiSettings()
                    }, isGreedy: false, from: self)
                } else {
                    CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: AppListConstants.noInternetContext, cancelBtnText: AppListConstants.noInternetGotoSetting, confirmBtnText: CTLocalizedString(CTAlertGeneralIgnoreTitle, comment: ""), confirmHandler: nil, cancelHandler: { (action) in
                        CTSettingsUtility.openWifiSettings()
                    }, isGreedy: false)
                }
            }
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil) // try remove the observer added in viewDidLoad
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (self.firstLoad) {
            self.firstLoad = false
            self.disableUserInteraction()
        }
    }
    
    // MARK: - App fetch and search logic
    /**
     Prepare the data to show in controller. This method will try to go through the app list received from Android and create app object for each of them and run the search logic for them.
     
     This is a private method.
     - SeeAlso:CTApp
     */
    private func _prepareData() {
        print("This is background thread? \(Thread.isMainThread)")
        self.dataset = [] // reset the array
        
        let userDefaultObj = UserDefaults.standard.value(forKey: "appsFileList")
        
        var appList: NSArray?
        if (userDefaultObj != nil) {
            appList = UserDefaults.standard.value(forKey: "appsFileList") as? NSArray
        } else {
            appList = NSArray()
        }
        print("appList:\(String(describing: appList))");
        
        self.appCount = (appList?.count)!
        
        if (appList?.count == 0) {
            self.enableUserInteractionWithDelay(delay: 0)
        } else {
            for appInfo in appList! { // Go through all the apps.
                self._createApp(appInfo as! NSDictionary)
            }
        }
    }
    /**
     Creat CTApp object for each of the app read from file list.
     
     This is private method.
     - parameters:
        - appInfo: NSDictionary contains all the information for an app from Android.
     - SeeAlso:CTApp
     */
    private func _createApp(_ appInfo: NSDictionary) {
        let app: CTApp = CTApp.init(appInfo)
        self._filterDataSet(app)
    }
    /**
     Try to run seaching program for each of the app and remove which returns 0 item from the list.
     
     This is private method.
     - parameters:
        - app: CTApp object represents the app needs to be searched.
     */
    private func _filterDataSet(_ app: CTApp) {
        let url = URL(string: String.init(format: AppListConstants.itunsSearchAPI, (app.name?.encodeForURLComponents())!))
        print("target URL:\(String(describing: url))")
        
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil) { // Error happened during app search
                print("error found:\(String(describing: error))")
                CTSTMContents.synchronized(lock: self, block: {
                    self.appCount -= 1 // reduce app count.
                    
                    if (self.appCount == 0) { // if all apps finished
                        print("======================")
                        print("final data set:\n\(self.dataset)\nfinal count:\(self.dataset.count)")
                        print("======================")
                        
                        self.appsDone = true
                        self.enableUserInteractionWithDelay(delay: 0)
                    }
                
                })
            } else { // No error
                do { // Try catch exception for parsing.
                    let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let count = (jsonDictionary["resultCount"] as! NSNumber).intValue // Get result count from Apple Json value.
                    print("=====\ntargetUrl:\(String(describing: url))\n")
                    print("->non-zero found: \(count)")
                    
                    CTSTMContents.synchronized(lock: self.dataset) {
                        self.appCount -= 1
                        
                        if (count > 0) { // Some app found in Apple server
                            if (count == 1) { // Only one app match
                                app.trackURL = ((jsonDictionary["results"] as? NSArray)?.object(at: 0) as! NSDictionary).object(forKey: "trackViewUrl") as! String? // store track URL
                                app.trackURL = app.trackURL?.replacingOccurrences(of: "https://", with: "itms-apps://")
                            }
                            app.searchResSetCount = count
                            self.dataset.append(app)
                            
                            // Sort dataset using app name, word ascending order
                            self.dataset = self.dataset.sorted(by: { (a, b) -> Bool in
                                let nameA = a.name!
                                let nameB = b.name!
                                
                                return nameA.compare(nameB) == .orderedAscending
                            })
                            
                            // Refresh UI
                            self.performSelector(onMainThread: #selector(self.reloadTable), with: nil, waitUntilDone: false)
                        }
                        
                        if (self.appCount == 0) {
                            print("======================")
                            print("final data set:\n\(self.dataset)\nfinal count:\(self.dataset.count)")
                            print("======================")
                            
                            self.appsDone = true
                            self.enableUserInteractionWithDelay(delay: 0)
                        }
                    }
                    
                } catch { // exception happened
                    print("json error:\(error)")
                    self.appCount -= 1
                    
                    if (self.appCount == 0) {
                        print("======================")
                        print("final data set:\n\(self.dataset)\nfinal count:\(self.dataset.count)")
                        print("======================")
                        
                        self.appsDone = true
                        self.enableUserInteractionWithDelay(delay: 0)
                    }
                }
            }
            
            print("count:\(self.appCount)")
        }).resume() // start search
    }
    /**
     Try to reload the table view using filtered app data.
     */
    @objc private func reloadTable() {
        if (self.scrollFooterView.isHidden && self.dataset.count > self.num) {
            self.scrollFooterView.isHidden = false
            
            self.view.layoutIfNeeded()
            self.footerHeight.constant = 30.0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (result) in
                self.scrollLabel.alpha = 1;
            })
            self.appListTableView.isScrollEnabled = true
        }
        self.appListTableView.reloadData()
    }

    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataset.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CTAppListTableViewCell = tableView.dequeueReusableCell(withIdentifier: AppListConstants.cellIdentifier, for: indexPath) as! CTAppListTableViewCell
        let app: CTApp = dataset[indexPath.row]
        
        if (!app.isClicked) {
            cell.getAppButton.setTitleColor(cell.blueButtonColor, for: .normal)
        } else {
            cell.getAppButton.setTitleColor(cell.blueButtonColor.mixLighter(0.6), for: .normal)
        }
        
        cell.appIcon.image = self.getAppIconFor(app) // Need a default image
        cell.appNameLabel.text = app.name!
        cell.getAppButton.tag = indexPath.row
        
        cell.delegate = self

        return cell
    }
    
    private func getAppIconFor(_ app: CTApp) -> UIImage? {
//        print("app: \(app.name)")
        
        let rootURL = URL.init(string: NSString.appRootDocumentDirectory())
        let folderPath = rootURL?.appendingPathComponent("ReceivedAppIcons")
        
        var filePath = folderPath?.appendingPathComponent(app.name!)
        filePath = filePath?.appendingPathExtension("png")
        
//        print("->Path:\(filePath)")
        
        var myImages: UIImage?
        if (filePath != nil) {
            myImages = UIImage.init(contentsOfFile: (filePath?.path)!)
        }
        
        return myImages
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.appListTableView.frame.size.height / CGFloat(num)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.dataset.count - 1) {
            // last cell will show
            self.view.layoutIfNeeded()
            self.footerHeight.constant = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollLabel.alpha = 0;
                self.view.layoutIfNeeded()
            }, completion: { (result) in
                self.scrollLabel.alpha = 0;
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.dataset.count - 1) {
            // last cell will gone
            self.view.layoutIfNeeded()
            self.footerHeight.constant = 30.0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (result) in
                self.scrollLabel.alpha = 1;
            })
        }
    }
    
    //MARK: - AppListTableViewCell Delegate
    func getAppButtonDidClicked(appID: Int) {
        self.dataset[appID].didChecked()
        self.doSearch(appID)
    }
    /**
     Open the app store searching page to let user download the app.
     */
    func doSearch(_ appID: Int) {
        let app = self.dataset[appID]
        
        let searchURLString:String = String.init(format: AppListConstants.appStoreSearch, app.name!.replacingOccurrences(of: " +", with: " plus").replacingOccurrences(of: "+", with: " plus").encodeForURLComponents())
        print("Complete search URL:\(searchURLString)")
        
        UIApplication.shared.openURL(URL.init(string: searchURLString)!) // jump to application
    }
    
    // MARK: - Methods
    /**
     Disable the user interaction for app list controller.
     */
    private func disableUserInteraction() {
        if(!self.view.subviews.contains(self.activityIndicator)) {
            self.view.addSubview(self.activityIndicator)
            self.view.bringSubview(toFront: self.activityIndicator)
        }
        self.activityIndicator.show(animated: true)
    }
    /**
     Enable the user interaction for app list controller. Delay time can be specified.
     - parameters:
        - delay: Double value represents how many seconds wait before hid the spinner.
     */
    private func enableUserInteractionWithDelay(delay: Double) {
        self.activityIndicator.hide(animated: true, afterDelay: delay)
    }
    /**
     Check internet connection with completion block. Basically, this method will try to pin Google.com in short period of time(10s).
     
     Because session task is async task, no garantee of order, so result will be returned using block.
     - parameters:
        - completionHandler: Result block for internet check containing the result using Bool value.
        - hasNetwork: Bool value indicate current device is conecting to Internet or not.
     */
    private func checkInternetConnection(completionHandler: @escaping (_ hasNetwork: Bool) -> Void) {
        let request = NSMutableURLRequest(url: URL.init(string: "https://www.google.com")!)
        
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 10 // Set timeout for network check
        urlconfig.timeoutIntervalForResource = 10
        let session = URLSession.init(configuration: urlconfig)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error -> Void in
            if (error != nil) { // No internet connection error happened.
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
        task.resume()
    }
    /**
     Recheck Wi-Fi networking after app comes back from background mode and update necessary information.
     */
    @objc private func checkWifiConnectionAgain() {
        if (!self.hasInternet && !self.appsDone) { // if there is no internet connection and app searching haven't finished, recheck internet again; Otherwise no need to check internet anymore.
            self.disableUserInteraction()
            
            self.checkInternetConnection { (hasNetwork) in
                if (hasNetwork) { // has network
                    DispatchQueue.main.async {
                        self.appListTableView.isHidden = false
                        self.errorLabel.isHidden = true
                    }
                    self.hasInternet = true
                    self.fetchQueue.addOperation { // Run app search logic in another queue.
                        self._prepareData()
                    }
                } else { // no internet connection
                    DispatchQueue.main.async {
                        self.appListTableView.isHidden = true
                        self.errorLabel.isHidden = false
                    }
                    self.hasInternet = false
                    self.enableUserInteractionWithDelay(delay: 0)
                    
                    if (!self.alertShowed) {
                        self.alertShowed = true

                        if (CTContentTransferSetting.userCustomVerizonAlert()) {
                            CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: AppListConstants.noInternetContext, cancelBtnText: AppListConstants.noInternetGotoSetting, confirmBtnText: CTLocalizedString(CTAlertGeneralIgnoreTitle, comment: ""), confirmHandler: nil, cancelHandler: { (alertVC: CTVerizonAlertViewController) in
                                CTSettingsUtility.openWifiSettings()
                            }, isGreedy: false, from: self)
                        }else {
                            CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: AppListConstants.noInternetContext, cancelBtnText: AppListConstants.noInternetGotoSetting, confirmBtnText: CTLocalizedString(CTAlertGeneralIgnoreTitle, comment: ""), confirmHandler: nil, cancelHandler: { (action) in
                                CTSettingsUtility.openWifiSettings()
                            }, isGreedy: false)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func doneButtonClicked(_ sender: Any) {
        if (CTContentTransferSetting.userCustomVerizonAlert()) {
            CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: AppListConstants.saveListAlertContext, cancelBtnText: CTLocalizedString(CT_APP_REVIEW_ALERT_NO_THANKS, comment: ""), confirmBtnText: CTLocalizedString(CT_YES_ALERT_BUTTON_TITLE, comment: ""), confirmHandler: { (alertVC: CTVerizonAlertViewController) in
                self._dismissViewController()
            }, cancelHandler: { (cancelAction) in
                self._clearAppData()
            }, isGreedy: false, from: self)
        }else {
            CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: AppListConstants.saveListAlertContext, cancelBtnText: CTLocalizedString(CT_APP_REVIEW_ALERT_NO_THANKS, comment: ""), confirmBtnText: CTLocalizedString(CT_YES_ALERT_BUTTON_TITLE, comment: ""), confirmHandler: { (confirmAction) in
                self._dismissViewController()
            }, cancelHandler: { (cancelAction) in
                self._clearAppData()
            }, isGreedy: false)
        }
    }
    
    private func _clearAppData() { // Remove all the icons saved in the folder
        self.disableUserInteraction()
        
        let rootURL = URL.init(string: NSString.appRootDocumentDirectory())
        let folderPath = rootURL?.appendingPathComponent("ReceivedAppIcons")
       
        do {
            let fileManager = FileManager.default
            let icons:[String] = try fileManager.contentsOfDirectory(atPath: (folderPath?.path)!)
            for path in icons {
                let fullPath = folderPath?.appendingPathComponent(path)
                if (fileManager.fileExists(atPath: (fullPath?.path)!)) { // Exist, then remove
                    try fileManager.removeItem(atPath: (fullPath?.path)!)
                }
            }
        } catch {
            print("Error:\(error)")
        }
        
        self.enableUserInteractionWithDelay(delay: 0)
        
        self._dismissViewController()
    }
    
    private func _dismissViewController() {
        if (self.normalProcess) {
            // in normal process, push to next
            self.pushToNext()
        } else {
            // first page, pop back
            self.delegate?.CTAppListWillPopBack()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func pushToNext() {
        if (CTUserDefaults.sharedInstance().isCancel) { // If it's cancel, go to interrupted page with necessary information
            let errorViewController = CTErrorViewController.initialise(from: CTStoryboardHelper.commonStoryboard())
            errorViewController?.dataInterruptedItemsList = self.savedItemsList as! [Any]!;
            errorViewController?.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, comment: "");
            errorViewController?.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, comment: "");
            errorViewController?.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, comment: "");
            errorViewController?.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, comment: "");
            errorViewController?.totalDataAmount = self.totalDataTransferred;
            errorViewController?.totalDataSentUntillInterrupted = self.actualDataTransferred;
            errorViewController?.transferSpeed = self.transferSpeed as String!;
            errorViewController?.transferTime = self.transferTime as String!;
            errorViewController?.transferStatusAnalytics = self.transferStatusAnalytics;
            errorViewController?.photoFailedList = self.photoFailedList as! [Any]!;
            errorViewController?.videoFailedList = self.videoFailedList as! [Any]!;
            
            errorViewController?.numberOfPhotos = self.numberOfPhotos;
            errorViewController?.numberOfVideos = self.numberOfVideos;
            errorViewController?.numberOfCalendar = self.numberOfCalendar;
            errorViewController?.numberOfContacts = self.numberOfContacts;
            errorViewController?.numberOfReminder = self.numberOfReminder;
            errorViewController?.numberOfApps = self.numberOfApps;
            
            self.navigationController?.pushViewController(errorViewController!, animated: true)
        } else { // If it finished, go to finish view controller
            let transferFinishViewController = CTTransferFinishViewController.initialise(from: CTStoryboardHelper.transferStoryboard())
            transferFinishViewController?.savedItemsList = self.savedItemsList as! [Any]!;
            transferFinishViewController?.transferFlow = CTTransferFlow.receiver;
            transferFinishViewController?.totalDataTransferred = self.totalDataTransferred;
            transferFinishViewController?.dataTransferred = self.actualDataTransferred;
            transferFinishViewController?.transferSpeed = self.transferSpeed as String!;
            transferFinishViewController?.transferStatusAnalytics = self.transferStatusAnalytics;
            transferFinishViewController?.transferTime = self.transferTime as String!;
            transferFinishViewController?.photoFailedList = self.photoFailedList as! [Any]!;
            transferFinishViewController?.videoFailedList = self.videoFailedList as! [Any]!;
            
            //Analytics data
            transferFinishViewController?.numberOfReminder = self.numberOfReminder;
            transferFinishViewController?.numberOfPhotos = self.numberOfPhotos;
            transferFinishViewController?.numberOfVideos = self.numberOfVideos;
            transferFinishViewController?.numberOfContacts = self.numberOfContacts;
            transferFinishViewController?.numberOfCalendar = self.numberOfCalendar;
            transferFinishViewController?.numberOfApps = self.numberOfApps;
            
            self.navigationController?.pushViewController(transferFinishViewController!, animated: true)
        }
    }
}

// MARK: - Local extensions
extension String {
    /** Error for parsing json string.*/
    enum JsonStringParserError: Error {
        /** String is empty.*/
        case emptyString
        /** Failed when parsing json, error will be assigned as detail.*/
        case jsonParseFailed(detail: Error)
    }
    /**
     Parse json string to object, if something wrong happened during json parse, exception will be thrown.
     - returns: Object that contains in json string.
     - seeAlso: JsonStringParserError
     */
    func parseJsonStringToObject() throws -> Any! {
        if (self.count == 0) {
            throw JsonStringParserError.emptyString
        }
        
        let jsonData = self.data(using: .utf8) // Get data from Json string
        do {
            return try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
        } catch {
            print("error:\(error)")
            throw JsonStringParserError.jsonParseFailed(detail: error)
        }
    }
}

extension NSArray {
    /**
     Decode the app name from array using Base64. This method will replace the object inside array in place by changing it to mutable copy.
     */
    func decodedEncryptArray() {
        for index in 0...self.count-1 {
            let appInfo = self[index] as! NSDictionary
            
            for keyObject in appInfo.allKeys {
                if ((keyObject as! String).lowercased() == "size") {
                    continue
                }
                let value = appInfo[keyObject] as! String
                let decodedvalue = self._decodeStringTo64(value)
                appInfo.setValue(decodedvalue, forKey: keyObject as! String)
            }
            
            (self.mutableCopy() as! NSMutableArray).replaceObject(at: index, with: appInfo)
        }
    }
    
    private func _decodeStringTo64(_ string: String) -> String {
        if (string.count > 0) {
            let decodedData = Data.init(base64Encoded: string, options: .init(rawValue: 0))
            return String.init(data: decodedData!, encoding: .utf8)!
        }
        
        return ""
    }
}
