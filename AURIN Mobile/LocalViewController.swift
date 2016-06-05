//
//  LocalViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/16.
//  Copyright © 2016年 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    This file control the offline dataset view, the structure is similar with OnlineViewController.
 It fetches dataset from local database and display in a table view.
 ********************************************************************************************/


import UIKit
import CoreData

class LocalViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    
    var localDatasets:[LocalDataset] = []
    // 'searchDatasets' list stores the information of datasets that match the query.
    var searchDatasets:[LocalDataset] = []
    // Create a search controller.
    let searchController = UISearchController(searchResultsController: nil)
    var fetchResultController:NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the self sizing table cell. The default cell height is 72.0 point.
        tableView.estimatedRowHeight = 72.0
        tableView.rowHeight = UITableViewAutomaticDimension
        // Get Data from GeoServer through WFS.
        self.getDatasets()
        // Add search bar to the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Org", "Keyword"]
        searchController.searchBar.delegate = self
        // Set the text of 'back' button in next view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRectZero)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(1) as! UITabBarItem
        tabItem.badgeValue = nil
        Numbers.newSavedItem = 0
    }
    

    private func getDatasets() {
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
    }
    
    
    // MARK: - DataSource
    
    // FUNCTION: Number of rows in table section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return searchDatasets.count
        } else {
            return localDatasets.count
        }
    }
    
    // FUNCTION: The content of row at 'indexPath'
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Set Cell's identifier
        let cellIdentifier = "Cell"
        // Reuse table cells to save memory
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DatasetTableViewCell
        let data:LocalDataset
        if searchController.active && searchController.searchBar.text != "" {
            data = searchDatasets[indexPath.row]
        } else {
            data = localDatasets[indexPath.row]
        }
        cell.datasetTitle.text = data.title
        cell.datasetOrg.text = data.organisation
        cell.datasetKeyword.text = "Keywords: " + data.keywords
        cell.datasetImage.image = UIImage(named: data.organisation)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath
        indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Delete option
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete",handler:
            {
                (action, indexPath) -> Void in
                // Delete the row from the database
                if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                    
                    let datasetToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! LocalDataset
                    managedObjectContext.deleteObject(datasetToDelete)
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                }
                DataSet.savedDataset.removeAll()
                
        })
        deleteAction.backgroundColor = UIColor(red: 210.0/255.0, green: 77.0/255.0, blue: 87.0/255.0, alpha: 1.0)
        return [deleteAction]
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let datasetToMove = localDatasets[fromIndexPath.row]
        localDatasets.removeAtIndex(fromIndexPath.row)
        localDatasets.insert(datasetToMove, atIndex: toIndexPath.row)
        
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    @IBAction func editing(sender: AnyObject) {
        
        self.editing = !self.editing
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        searchDatasets = localDatasets.filter( { (localDatasets:LocalDataset) -> Bool in
            let titleMatch = localDatasets.title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let orgMatch = localDatasets.organisation.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let keywordMatch = localDatasets.keywords.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject
        anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type:
        NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let _indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let _indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
            }
        default:
            tableView.reloadData()
        }
        localDatasets = controller.fetchedObjects as! [LocalDataset]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "displayDatasetDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let datasetToPass = Dataset()
                let localDataset: LocalDataset!
                if searchController.active && searchController.searchBar.text != "" {
                    localDataset = searchDatasets[indexPath.row]
                } else {
                    localDataset = localDatasets[indexPath.row]
                }
                datasetToPass.name = localDataset.name
                datasetToPass.title = localDataset.title
                datasetToPass.abstract = localDataset.abstract
                datasetToPass.organisation = localDataset.organisation
                datasetToPass.website = localDataset.website
                datasetToPass.keywords = [localDataset.keywords]
                datasetToPass.bbox = BBOX(lowerLON: localDataset.lowerLON, lowerLAT: localDataset.lowerLAT, upperLON: localDataset.upperLON, upperLAT: localDataset.upperLAT)
                datasetToPass.zoom = localDataset.zoom
                datasetToPass.center = (longitude: localDataset.centerLON, latitude: localDataset.centerLAT)
                let destinationController = segue.destinationViewController as! DatasetDetailViewController
                destinationController.dataset = datasetToPass
                // destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocalViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
        //filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
}

extension LocalViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
