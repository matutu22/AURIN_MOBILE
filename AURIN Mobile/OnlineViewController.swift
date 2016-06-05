//
//  OnlineViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/9.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    This file control the online dataset view, fetching datasat catalog from AUIRN, and display
 them in a table view. There are also a geographical filer and search bar in this view.
 
 ********************************************************************************************/


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
        
    }

    // This fucntion fetch dataset catalog from AURIN API: GeoServer
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
                    // Create a dataset, read data from XML
                    let dataset = Dataset()
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
                    
                    // Add dataset object to list
                    if DataSet.invalidData[dataset.title] != nil {
                        // Do nothing
                    } else {
                        self.datasets.append(dataset)
                    }
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
        
        // Set Cell's identifier
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

        // Add a save option in the slide bar.
        let saveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Save",handler:
            {   // This closure is a hundler which save dataset to CoreData
                (action, indexPath) -> Void in
                self.getSavedDatasets()
                if DataSet.savedDataset.contains(self.datasets[indexPath.row].title) {
                    tableView.editing = false
                    let alertMessage = UIAlertController(title: "NOTICE", message: "This dataset is already saved.", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
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
                // If select a dataset from search view.
                if searchController.active && searchController.searchBar.text != "" {
                    datasetToPass = searchDatasets[indexPath.row]
                } else {
                    datasetToPass = datasets[indexPath.row]
                }
                let destinationController = segue.destinationViewController as! DatasetDetailViewController
                destinationController.dataset = datasetToPass
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
    
    
    // Go back to dataset list from geographical filter.
    @IBAction func close(segue:UIStoryboardSegue) {
        if let filterViewController = segue.sourceViewController as? FilterViewController {
            let bbox = filterViewController.filertBBOX
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

