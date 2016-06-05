//
//  DatasetDetailViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/10.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    Control the dataset detail view.
 ********************************************************************************************/


import UIKit
import Alamofire
import SWXMLHash
import GoogleMaps

class DatasetDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapView: GMSMapView!
    
    var propertyList = [String: String]()
    var dataset:Dataset!
    var geom_name = "the_geom"
    
    var bounding = GMSPolygon()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getDatasetProperties()
        
        // Add a google map to the view
        self.mapView.myLocationEnabled = true;
        self.mapView.mapType = kGMSTypeNormal;
        self.mapView.settings.compassButton = false;
        self.mapView.settings.myLocationButton = false;
        self.mapView.settings.zoomGestures = true
        self.mapView.settings.tiltGestures = false
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.scrollGestures = true
        self.mapView.delegate = self;
        
        // Initialise the map view
        let lowerLAT = dataset.bbox.lowerLAT
        let lowerLON = dataset.bbox.lowerLON
        let upperLAT = dataset.bbox.upperLAT
        let upperLON = dataset.bbox.upperLON
        let centerLAT = dataset.center.latitude
        let centerLON = dataset.center.longitude
        let zoomLevel = dataset.zoom
        
        let camera = GMSCameraPosition.cameraWithLatitude(centerLAT, longitude: centerLON, zoom: zoomLevel)
        self.mapView.animateToCameraPosition(camera)
        
        // Draw bounding box on map
        let rect = GMSMutablePath()
        rect.addCoordinate(CLLocationCoordinate2D(latitude: lowerLAT, longitude: lowerLON))
        rect.addCoordinate(CLLocationCoordinate2D(latitude: upperLAT, longitude: lowerLON))
        rect.addCoordinate(CLLocationCoordinate2D(latitude: upperLAT, longitude: upperLON))
        rect.addCoordinate(CLLocationCoordinate2D(latitude: lowerLAT, longitude: upperLON))
        
        bounding = GMSPolygon(path: rect)
        bounding.strokeColor = UIColor.blackColor()
        bounding.strokeWidth = 0
        bounding.fillColor = UIColor(red: 28.0/255.0, green: 79.0/255.0, blue: 107.0/255.0, alpha: 0.15)
        //bbox.map = self.mapView
    
        
        // Table's appearance
        //tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.2)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = "Dataset Detail"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        
    }
    
    // Get the detail information of selected dataset from AURIN serer.
    private func getDatasetProperties() {
        Alamofire.request(.GET, "https://geoserver.aurin.org.au/wfs?request=DescribeFeatureType&service=WFS&version=1.1.0&TypeName=\(dataset.name)")
            .response { (request, response, data, error) in
                //print(data) // if you want to check XML data in debug window.
                let xml = SWXMLHash.parse(data!)
                for property in xml["xsd:schema"]["xsd:complexType"]["xsd:complexContent"]["xsd:extension"]["xsd:sequence"]["xsd:element"] {
                    let propertyName = (property.element?.attributes["name"])!
                    var propertyType = (property.element?.attributes["type"])!
                    propertyType.removeRange(propertyType.startIndex..<propertyType.startIndex.advancedBy(4))
                    //print("\(propertyName): \(propertyType)")
                    self.propertyList.updateValue(propertyType, forKey: propertyName)
                }
                self.tableView.reloadData()
            }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:
        NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DatasetDetailTableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.fieldImage.image = UIImage(named: "icon_dataset")
            cell.valueLabel.text = dataset.title
        case 1:
            cell.fieldImage.image = UIImage(named: "icon_org")
            cell.valueLabel.text = dataset.organisation
        case 2:
            cell.fieldImage.image = UIImage(named: "icon_website")
            cell.valueLabel.textColor = UIColor(red: 65.0/255.0, green: 151.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            cell.valueLabel.text = dataset.website
        case 3:
            cell.fieldImage.image = UIImage(named: "icon_type")
            
            // "wkb_geometry"
            for geom_title in ["the_geom", "geom", "wkb_geometry"] {
                if propertyList[geom_title] != nil {
                    cell.valueLabel.text = propertyList[geom_title]
                    self.geom_name = geom_title
                }
            }
            
        case 4:
            cell.fieldImage.image = UIImage(named: "icon_keywords")
            cell.valueLabel.text = dataset.showKeyword()
        case 5:
            cell.fieldImage.image = UIImage(named: "icon_bbox")
            cell.valueLabel.text = dataset.bbox.printBBOX()
        case 6:
            cell.fieldImage.image = UIImage(named: "icon_abstract")
            if dataset.abstract != "" {
                cell.valueLabel.text = dataset.abstract
            } else {
                cell.valueLabel.text = "This dataset doesn't have abstract."
            }
        default:
            cell.valueLabel.text = ""
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2 {
            let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                if let url = NSURL(string: self.dataset.website) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            let callAction = UIAlertAction(title: "Visit Website", style: .Default, handler: callActionHandler)
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(callAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        
        if indexPath.row == 5 {
            let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .ActionSheet)
            // Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let showBounding = UIAlertAction(title: "Show Bounding Box on Map", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                self.bounding.map = self.mapView
            })
            let dropBounding = UIAlertAction(title: "Don't Show Bounding Box", style: .Destructive, handler: { (action:UIAlertAction!) -> Void in
                self.bounding.map = nil
            })
            
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(showBounding)
            optionMenu.addAction(dropBounding)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMapSetting" {
            let destinationController = segue.destinationViewController as! MapSettingTableViewController
            destinationController.dataset = dataset
            destinationController.propertyList = propertyList
            destinationController.geom_name = geom_name
            // destinationController.hidesBottomBarWhenPushed = true
        }
        
        if segue.identifier == "showChartSetting" {
            let destinationController = segue.destinationViewController as! ChartSettingTableViewController
            destinationController.dataset = dataset
            destinationController.propertyList = propertyList
            destinationController.geom_name = geom_name
        }
    }

}
