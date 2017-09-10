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
    var fetchResultController:NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the self sizing table cell. The default cell height is 72.0 point.
        tableView.estimatedRowHeight = 72.0
        tableView.rowHeight = UITableViewAutomaticDimension
        // Get Data from openapi through WFS.
        self.getDatasets()
        // Add search bar to the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Title", "Org", "Keyword"]
        searchController.searchBar.delegate = self
        // Set the text of 'back' button in next view.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: CGRect.zero)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray?.object(at: 1) as! UITabBarItem
        tabItem.badgeValue = nil
        Numbers.newSavedItem = 0
    }
    

    fileprivate func getDatasets() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalDataset")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let managedObjectContext = (UIApplication.shared.delegate as?
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return searchDatasets.count
        } else {
            return localDatasets.count
        }
    }
    
    // FUNCTION: The content of row at 'indexPath'
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Set Cell's identifier
        let cellIdentifier = "Cell"
        // Reuse table cells to save memory
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DatasetTableViewCell
        let data:LocalDataset
        if searchController.isActive && searchController.searchBar.text != "" {
            data = searchDatasets[indexPath.row]
        } else {
            data = localDatasets[indexPath.row]
        }
        cell.datasetTitle.text = data.title
        cell.datasetOrg.text = data.organisation
        cell.datasetKeyword.text = "Keywords: " + data.keywords
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
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt
        indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Delete option
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete",handler:
            {
                (action, indexPath) -> Void in
                // Delete the row from the database
                if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                    
                    let datasetToDelete = self.fetchResultController.object(at: indexPath) as! LocalDataset
                    managedObjectContext.delete(datasetToDelete)
                    
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
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let datasetToMove = localDatasets[fromIndexPath.row]
        localDatasets.remove(at: fromIndexPath.row)
        localDatasets.insert(datasetToMove, at: toIndexPath.row)
        
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    @IBAction func editing(_ sender: AnyObject) {
        
        self.isEditing = !self.isEditing
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        searchDatasets = localDatasets.filter( { (localDatasets:LocalDataset) -> Bool in
            let titleMatch = localDatasets.title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let orgMatch = localDatasets.organisation.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            let keywordMatch = localDatasets.keywords.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchController.resignFirstResponder()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange
        anObject: Any, at indexPath: IndexPath?, for type:
        NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRows(at: [_newIndexPath], with: .fade)
            }
        case .delete:
            if let _indexPath = indexPath {
                tableView.deleteRows(at: [_indexPath], with: .fade)
            }
        case .update:
            if let _indexPath = indexPath {
                tableView.reloadRows(at: [_indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        localDatasets = controller.fetchedObjects as! [LocalDataset]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayDatasetDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let datasetToPass = Dataset()
                let localDataset: LocalDataset!
                if searchController.isActive && searchController.searchBar.text != "" {
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
                let destinationController = segue.destination as! DatasetDetailViewController
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
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
        //filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
}

extension LocalViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
