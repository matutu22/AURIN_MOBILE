//
//  OnlineViewController.swift
//  AURIN Mobile
//
//  By Chenhan Ma
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

class OnlineViewController: UITableViewController, UITextFieldDelegate,
    NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    // 'datasets' list store the information of all datasets.
    var datasets = [Dataset]()
    
    // 'searchDatasets' list stores the information of datasets that match the query.
    var searchDatasets = [Dataset]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // The flag for walkthrough page displaying.
    var displayWalkthrough = true
    
    var sortOption : String = "default"
    var fetchResultController:NSFetchedResultsController<NSFetchRequestResult>!
    var localDatasets:[LocalDataset] = []
    var alldatasets = [Dataset]()
    
    override func viewWillAppear(_ animated: Bool) {
        // Add search bar to the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Org", "Keyword"]
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "sort"), for: .bookmark, state: .normal)

    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if self.sortOption == "default"          { self.sortOption = "descending"}
        else if self.sortOption == "descending"  { self.sortOption = "ascending" }
        else if self.sortOption == "ascending"   { self.sortOption = "descending"}
        tableView.reloadData()
        print("Sort button pressed")
    }
    
    
    // Fix the bug of searchController not display normally
    override func viewWillDisappear(_ animated: Bool) {
        searchController.isActive = false
    }
    
    // FUNCTION: invoke when the view first appears.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 72.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        // Get Data from GeoServer through WFS.
        self.getDatasets()
        getSavedDatasets()
        
        // Set the text of 'back' button in next view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Set refresh Control
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload datasets")
        refreshControl.addTarget(self, action: #selector(OnlineViewController.refreshDataset), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl

    } // viewDidLoad ends.
    
    // Refetch datasets from GeoServer.
    @objc func refreshDataset() {
        print("Refresh")
        datasets = alldatasets
        sleep(1)
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    

    
    // This function will display the walkthrough pages after the table view appears.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
        
        // Check user's setting, if the walkthrough is closed, then do noting and return.
        let defaluts = UserDefaults.standard
        if defaluts.bool(forKey: "ClosedWalkthrough") {
            return
        }
        
        // Check the flag, walktrough pages will only display once after the app launching.
        if displayWalkthrough {
            if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController {
                present(pageViewController, animated: true, completion: nil)
            }
            displayWalkthrough = false
        }
        
    }

    // This fucntion fetch dataset catalog from AURIN API: OpenApi
    fileprivate func getSavedDatasets() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalDataset")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let managedObjectContext = (UIApplication.shared.delegate as?
            AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(
                fetchRequest:fetchRequest,
                managedObjectContext: managedObjectContext,
                sectionNameKeyPath: nil, cacheName: nil)
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
    
    
    // This function will get datasets content fron Openapi, and generating a list of 'Dataset' type.
    fileprivate func getDatasets() {
        
        // Query the dataset list from GeoServer, using 'GetCapabilities' service.
        Alamofire.request("http://openapi.aurin.org.au/wfs?service=WFS&version=1.1.0&request=GetCapabilities")
            .authenticate(user: "student", password: "dj78dfGF")
            .response {  response in
                // It is the XML file that returnd by GeoServer.
                let xml = SWXMLHash.parse(response.data!)
                // Dealing each feature, and put them into a list.
                let featureTypeList = xml["wfs:WFS_Capabilities"]["FeatureTypeList"]["FeatureType"]
                for featureType in featureTypeList.all {
                    
                    // Create a dataset, read data from XML
                    let dataset = Dataset()
                    dataset.name = (featureType["Name"].element?.text)!
                    let title = (featureType["Title"].element?.text)!
                    dataset.title = title.components(separatedBy: "Data provider: ")[0]
                    let rawAbstract = (featureType["Abstract"].element?.text)!
                    dataset.abstract = rawAbstract.components(separatedBy: "Temporal extent start: ")[0]
                    
                    dataset.keywords = featureType["ows:Keywords"]["ows:Keyword"].all.map {
                        keyword in (keyword.element?.text)!
                    }
                    
                    //Retrieve Geo Data
                    for bbox in featureType["ows:WGS84BoundingBox"].all {
                        let lowerCorner = (bbox["ows:LowerCorner"].element?.text)!
                        let lowerLON = Double(lowerCorner.components(separatedBy: " ")[0])!
                        let lowerLAT = Double(lowerCorner.components(separatedBy: " ")[1])!
                        let upperCorner = (bbox["ows:UpperCorner"].element?.text)!
                        let upperLON = Double(upperCorner.components(separatedBy: " ")[0])!
                        let upperLAT = Double(upperCorner.components(separatedBy: " ")[1])!
                        dataset.bbox = BBOX(lowerLON: lowerLON, lowerLAT: lowerLAT, upperLON: upperLON, upperLAT: upperLAT)
                        // Calculating the center's coordinate of bounding box.
                        let centerLON = round((lowerLON + upperLON) / 2 * 1000000) / 1000000
                        let centerLAT = round((lowerLAT + upperLAT) / 2 * 1000000) / 1000000
                        dataset.center = (centerLON, centerLAT)
                        let zoom = Float(round((log2(210 / abs(upperLON - lowerLON)) + 1) * 100) / 100)
                        dataset.zoom = zoom
                    }
                    dataset.organisation = title.components(separatedBy: "Data provider: ")[1]
                    
                    //Find Dataset website in the abstract
                    if let start = dataset.abstract.range(of: "a href='"),
                        let end = dataset.abstract.range(of: "' target=", range: start.upperBound..<dataset.abstract.endIndex){
                        dataset.website = String(dataset.abstract[start.upperBound..<end.lowerBound])
                    }else{
                        dataset.website = "http://aurin.org.au"
                    }
                    
                    // Find dataset creation date
                    if let start = rawAbstract.range(of: "Temporal extent start: "),
                        let end = rawAbstract.range(of: "T00:00:00 Temporal", range: start.upperBound..<rawAbstract.endIndex){
                        dataset.date = Reuse.shared.dateConverter(dateString: String(rawAbstract[start.upperBound..<end.lowerBound]))
                    }

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
    
    
    
    // MARK: - EmptyDataset
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var str = "No data"
        if searchController.isActive && searchController.searchBar.text != ""{
            str = "No result"
        }
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        return NSAttributedString(string: str, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text = "Try refresh the table"
        if searchController.isActive && searchController.searchBar.text != ""{
            text = "No dataset matches your query, try another one."
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: CGFloat(14.0)),
                          NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.paragraphStyle: paragraph]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool{
        return true
    }


    // FUNCTION: Number of rows in table section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return searchDatasets.count
        } else {
            return datasets.count
        }
    }
    
    // FUNCTION: The content of row at 'indexPath'
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        getSavedDatasets()
        
        // Set Cell's identifier
        let cellIdentifier = "Cell"
        // Reuse cells for saving memory.
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DatasetTableViewCell
        let data:Dataset
        // If the search bar is active, display the filtered list.
        if searchController.isActive && searchController.searchBar.text != "" {
            data = searchDatasets[indexPath.row]
        } else {
            if self.sortOption == "descending" {
                datasets = datasets.sorted( by: {$0.date > $1.date})
                data = datasets[indexPath.row]
            }else if self.sortOption == "ascending"{
                datasets = datasets.sorted( by: {$0.date < $1.date})
                data = datasets[indexPath.row]
            }else{
                data = datasets[indexPath.row]
            }
        }
        
        if data.isSaved {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.datasetTitle.text = data.title
        cell.datasetOrg.text = data.organisation
        cell.datasetKeyword.text = "Keywords: " + data.showKeyword()
        let image = UIImage(named: data.organisation)

        cell.datasetImage.image = image
        cell.datasetImage.layer.cornerRadius = cell.datasetImage.frame.size.width/2
        cell.datasetImage.clipsToBounds = true
        cell.datasetImage.layer.masksToBounds = true
        cell.datasetImage.layer.borderWidth = 0.5
        cell.datasetImage.layer.borderColor = UIColor.lightGray.cgColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row after touching.
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt
        indexPath: IndexPath) -> [UITableViewRowAction]? {

        // Add a save option in the slide bar.
        let saveAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Save",handler:
            {   // This closure is a hundler which save dataset to CoreData
                (action, indexPath) -> Void in
                self.getSavedDatasets()
                if DataSet.savedDataset.contains(self.datasets[indexPath.row].title) {
                    tableView.isEditing = false
                    let alertMessage = UIAlertController(title: "NOTICE", message: "This dataset is already saved.", preferredStyle: .alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertMessage, animated: true, completion: nil)
                } else {
                    // The Dataset type will be changed into Localdataset type.
                    var localDataset:LocalDataset!
                    if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                        localDataset = NSEntityDescription.insertNewObject(forEntityName: "LocalDataset", into: managedObjectContext) as! LocalDataset
                        
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
                        let tabItem = tabArray?.object(at: 1) as! UITabBarItem
                        tabItem.badgeValue = "\(Numbers.newSavedItem)"
                        
                        do {
                            try managedObjectContext.save()
                        } catch {
                            print(error)
                        }
                        let cell = tableView.cellForRow(at: indexPath)
                        cell?.accessoryType = .checkmark
                    }
//                    self.datasets.remove(at: indexPath.row)
//                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }

        })
        saveAction.backgroundColor = UIColor(red: 036.0/255.0, green: 166.0/255.0, blue: 091.0/255.0, alpha: 1.0)
        
        return [saveAction]
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        searchDatasets = alldatasets.filter( { (dataset:Dataset) -> Bool in
            let titleMatch = dataset.title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let orgMatch = dataset.organisation.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let keywordMatch = dataset.showKeyword().range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
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
        
        tableView.reloadData()
    }
    
    
    // FUNCTION: Close the keyboard when touch other places.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchController.resignFirstResponder()
    }
    
    
    // Pass a Dataset object to next view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDatasetDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let datasetToPass: Dataset
                // If select a dataset from search view.
                if searchController.isActive && searchController.searchBar.text != "" {
                    datasetToPass = searchDatasets[indexPath.row]
                } else {
                    datasetToPass = datasets[indexPath.row]
                }
                let destinationController = segue.destination as! DatasetDetailViewController
                destinationController.dataset = datasetToPass
                // destinationController.hidesBottomBarWhenPushed = true
            }
        }
        if segue.identifier == "showPopover" {
            let vc = segue.destination as UIViewController
            let controller = vc.popoverPresentationController
            //controller!.backgroundColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.7)
            if controller != nil {
                controller?.delegate = self
            }
        }
        
    }

    @IBAction func popover(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showPopover", sender: self)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    // Go back to dataset list from geographical filter.
    @IBAction func close(_ segue:UIStoryboardSegue) {
        if let filterViewController = segue.source as? FilterViewController {
            let bbox = filterViewController.filterBBOX
            datasets = datasets.filter{$0.bbox.isIntersect(bbox)}
            tableView.reloadData()
            DataSet.filterBBOX = bbox
            
        }
    }
    
    // Reset Geo Filter
     @IBAction func reset(_ segue:UIStoryboardSegue) {
        datasets = alldatasets
        tableView.reloadData()
    }
    
}


extension OnlineViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            searchController.searchBar.showsBookmarkButton = false
        } else {
            searchController.searchBar.showsBookmarkButton = true
        }
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        //filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
}

extension OnlineViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        datasets = searchDatasets
        print("search button click")
        searchController.isActive = false
    }
}
