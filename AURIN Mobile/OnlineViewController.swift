//
//  OnlineViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/9.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import CoreData

class OnlineViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {

    /*********************************** VARIABLES *********************************************/

    
    // 'datasets' list store the information of all datasets.
    var datasets = [Dataset]()
    
    // 'searchDatasets' list stores the information of datasets that match the query.
    var searchDatasets = [Dataset]()
    
    // Create a search controller.
    let searchController = UISearchController(searchResultsController: nil)
    
    // The flag for walkthrough page displaying.
    var displayWalkthrough = true
    
    
    var fetchResultController:NSFetchedResultsController!
    var localDatasets:[LocalDataset] = []
    
    var alldatasets = [Dataset]()
    

    
    //var refreshControl: UIRefreshControl!
    //let refreshControl: UIRefreshControl = UIRefreshControl()
    
    
    /*********************************** FUNCTIONS *********************************************/
    
    // FUNCTION: invoke when the view first appears.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the self sizing table cell. The default cell height is 72.0 point.
        tableView.estimatedRowHeight = 72.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Get Data from GeoServer through WFS.
        self.getDatasets()
        getSavedDatasets()

        // Add search bar to the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Org", "Keyword"]
        searchController.searchBar.delegate = self
        
        // Set the text of 'back' button in next view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        // Set refresh Control
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload datasets")
        refreshControl.addTarget(self, action: #selector(OnlineViewController.refreshDataset), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        
        
    } // viewDidLoad ends.
    
    // Refetch datasets from GeoServer.
    func refreshDataset() {
        datasets = alldatasets
        sleep(1)
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    
    // This function will display the walkthrough pages after the table view appears.
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
        
        // Check user's setting, if the walkthrough is closed, then do noting and return.
        let defaluts = NSUserDefaults.standardUserDefaults()
        if defaluts.boolForKey("ClosedWalkthrough") {
            return
        }
        
        // Check the flag, walktrough pages will only display once after the app launching.
        if displayWalkthrough {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughController") as? WalkthroughPageViewController {
                presentViewController(pageViewController, animated: true, completion: nil)
            }
            // Set the display flag to false.
            displayWalkthrough = false
        }
        
        
        // --------- 抓取CoreData里的信息
        //getSavedDatasets()
    }

    
    private func getSavedDatasets() {
        let fetchRequest = NSFetchRequest(entityName: "LocalDataset")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as?
            AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest:
                fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath:
                nil, cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                localDatasets = fetchResultController.fetchedObjects as! [LocalDataset]
            } catch {
                print(error)
            }
        }
        for localDataset in localDatasets {
            DataSet.savedDataset.insert(localDataset.title)
        }
        
        for dataset in datasets {
            if DataSet.savedDataset.contains(dataset.title) {
                dataset.isSaved = true
            } else {
                dataset.isSaved = false
            }
        }
        
    }
    
    
    // This function will get datasets content fron GeoServer, and generating a list of 'Dataset' type.
    private func getDatasets() {
        
        // Query the dataset list from GeoServer, using 'GetCapabilities' service.
        Alamofire.request(.GET, "https://geoserver.aurin.org.au/wfs?service=WFS&version=1.1.0&request=GetCapabilities")
            .authenticate(user: "student", password: "dj78dfGF")
            .response { (request, response, data, error) in
                
                // It is the XML file that returnd by GeoServer.
                let xml = SWXMLHash.parse(data!)
                // Dealing each feature, and put them into a list.
                let featureTypeList = xml["wfs:WFS_Capabilities"]["FeatureTypeList"]["FeatureType"]
                for featureType in featureTypeList {
                    // 建立一个数据集，从XML中读取信息
                    let dataset = Dataset()
                    // 从XML中读取信息，并初始化dataset的成员变量
                    dataset.name = (featureType["Name"].element?.text)!
                    dataset.title = (featureType["Title"].element?.text)!
                    dataset.abstract = (featureType["Abstract"].element?.text)!
                    dataset.keywords = featureType["ows:Keywords"]["ows:Keyword"].all.map {
                        keyword in (keyword.element?.text)!
                    }
                    for bbox in featureType["ows:WGS84BoundingBox"] {
                        let lowerCorner = (bbox["ows:LowerCorner"].element?.text)!
                        let lowerLON = Double(lowerCorner.componentsSeparatedByString(" ")[0])!
                        let lowerLAT = Double(lowerCorner.componentsSeparatedByString(" ")[1])!
                        let upperCorner = (bbox["ows:UpperCorner"].element?.text)!
                        let upperLON = Double(upperCorner.componentsSeparatedByString(" ")[0])!
                        let upperLAT = Double(upperCorner.componentsSeparatedByString(" ")[1])!
                        dataset.bbox = BBOX(lowerLON: lowerLON, lowerLAT: lowerLAT, upperLON: upperLON, upperLAT: upperLAT)
                        // Calculating the center's coordinate of bounding box.
                        let centerLON = round((lowerLON + upperLON) / 2 * 1000000) / 1000000
                        let centerLAT = round((lowerLAT + upperLAT) / 2 * 1000000) / 1000000
                        dataset.center = (centerLON, centerLAT)
                        let zoom = Float(round((log2(210 / abs(upperLON - lowerLON)) + 1) * 100) / 100)
                        dataset.zoom = zoom
                    }
                    dataset.organisation = dataset.name.componentsSeparatedByString(":")[0]
                    dataset.website = (featureType.element?.attributes["xmlns:\(dataset.organisation)"])!
                    
                    // 将Dataset对象存入Dataset数组
                    
                    if DataSet.invalidData[dataset.title] != nil {
                        // Do nothing
                    } else {
                        self.datasets.append(dataset)
                    }
                    
                    //self.datasets.append(dataset)
                    
                    //print(dataset.bbox)
                    //print("Center: \(dataset.center),  Zoom: \(dataset.zoom)\n")
                }
                self.tableView.reloadData()
                self.alldatasets = self.datasets
            }
    }
    
    
    
    // MARK: - DataSource
    
    // FUNCTION: Number of rows in table section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return searchDatasets.count
        } else {
            return datasets.count
        }
    }
    
    // FUNCTION: The content of row at 'indexPath'
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        getSavedDatasets()
        
        // 设置Cell的identifier
        let cellIdentifier = "Cell"
        // Reuse cells for saving memory.
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DatasetTableViewCell
        let data:Dataset
        // If the search bar is active, display the filtered list.
        if searchController.active && searchController.searchBar.text != "" {
            data = searchDatasets[indexPath.row]
        } else {
            data = datasets[indexPath.row]
        }
        
        if data.isSaved {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        cell.datasetTitle.text = data.title
        cell.datasetOrg.text = data.organisation
        cell.datasetKeyword.text = "Keywords: " + data.showKeyword()
        cell.datasetImage.image = UIImage(named: data.organisation)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active {
            return false
        } else {
            return true }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect the row after touching.
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath
        indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        // 定制存储按钮，将dataset转换之后，存在CoreData里面
        let saveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Save",handler:
            {   // This closure is a hundler which save dataset to CoreData
                (action, indexPath) -> Void in
                self.getSavedDatasets()
                
                if DataSet.savedDataset.contains(self.datasets[indexPath.row].title) {
                    tableView.editing = false
                    
                    let alertMessage = UIAlertController(title: "NOTICE", message: "This dataset is already saved.", preferredStyle: .Alert)
                    
                    // 向Alert弹框里面增加一个选项
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                    
                    
                    
                    //print("hello world")
                } else {
                    // The Dataset type will be changed into Localdataset type.
                    var localDataset:LocalDataset!
                    
                    if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                        localDataset = NSEntityDescription.insertNewObjectForEntityForName("LocalDataset", inManagedObjectContext: managedObjectContext) as! LocalDataset
                        
                        localDataset.name = self.datasets[indexPath.row].name
                        localDataset.title = self.datasets[indexPath.row].title
                        localDataset.abstract = self.datasets[indexPath.row].abstract
                        localDataset.organisation = self.datasets[indexPath.row].organisation
                        localDataset.website = self.datasets[indexPath.row].website
                        localDataset.keywords = self.datasets[indexPath.row].showKeyword()
                        localDataset.lowerLON = self.datasets[indexPath.row].bbox.lowerLON
                        localDataset.lowerLAT = self.datasets[indexPath.row].bbox.lowerLAT
                        localDataset.upperLON = self.datasets[indexPath.row].bbox.upperLON
                        localDataset.upperLAT = self.datasets[indexPath.row].bbox.upperLAT
                        localDataset.zoom = self.datasets[indexPath.row].zoom
                        localDataset.centerLON = self.datasets[indexPath.row].center.longitude
                        localDataset.centerLAT = self.datasets[indexPath.row].center.latitude
                        
                        Numbers.newSavedItem += 1
                        let tabArray = self.tabBarController?.tabBar.items as NSArray!
                        let tabItem = tabArray.objectAtIndex(1) as! UITabBarItem
                        tabItem.badgeValue = "\(Numbers.newSavedItem)"
                        
                        do {
                            try managedObjectContext.save()
                        } catch {
                            print(error)
                        }
                        let cell = tableView.cellForRowAtIndexPath(indexPath)
                        cell?.accessoryType = .Checkmark
                    }
                    //tableView.editing = false
                    self.datasets.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                }

        })
        saveAction.backgroundColor = UIColor(red: 036.0/255.0, green: 166.0/255.0, blue: 091.0/255.0, alpha: 1.0)
        
        return [saveAction]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        searchDatasets = datasets.filter( { (dataset:Dataset) -> Bool in
            let titleMatch = dataset.title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let orgMatch = dataset.organisation.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let keywordMatch = dataset.showKeyword().rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let titleMatchFlag = titleMatch != nil
            let orgMatchFlag = orgMatch != nil
            let keywordMatchFlag = keywordMatch != nil
            if scope == "Title" {
                return titleMatchFlag
            } else if scope == "Org" {
                return orgMatchFlag
            } else if scope == "Keyword" {
                return keywordMatchFlag
            } else {
                return (titleMatchFlag || orgMatchFlag || keywordMatchFlag)
            }
        })
        
        //tableView.reloadData()
    }
    
    
    // FUNCTION: Close the keyboard when touch other places.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchController.resignFirstResponder()
    }
    
    
    // Pass a Dataset object to next view.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDatasetDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let datasetToPass: Dataset
                // 如果从搜索框进入Detail的话，下表要从过滤后的新列表中取
                if searchController.active && searchController.searchBar.text != "" {
                    datasetToPass = searchDatasets[indexPath.row]
                } else {
                    datasetToPass = datasets[indexPath.row]
                }
                let destinationController = segue.destinationViewController as! DatasetDetailViewController
                destinationController.dataset = datasetToPass
                // 在下页隐藏Tab Bar
                // destinationController.hidesBottomBarWhenPushed = true
                
            }
        }
        if segue.identifier == "showPopover" {
            let vc = segue.destinationViewController as UIViewController
            let controller = vc.popoverPresentationController
            //controller!.backgroundColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.7)

            if controller != nil {
                controller?.delegate = self
            }
        }
        
    }

    @IBAction func popover(sender: AnyObject) {
        self.performSegueWithIdentifier("showPopover", sender: self)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    // 从Filter视图中返回
    @IBAction func close(segue:UIStoryboardSegue) {
        if let filterViewController = segue.sourceViewController as? FilterViewController {
            let bbox = filterViewController.filertBBOX
            //print(bbox.printBBOX())
            // 在这里过滤datasets，然后刷新tableView
            datasets = datasets.filter{$0.bbox.isIntersect(bbox)}
            tableView.reloadData()
            DataSet.filterBBOX = bbox
            
        }
    }
    
}


extension OnlineViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
        //filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
}

extension OnlineViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

