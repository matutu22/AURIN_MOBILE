//
//  DatasetDetailViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/10.
//  Updated by Chenhan 
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
    var geom_name = "ogr_geometry"
    var chooseBBOX = BBOX(lowerLON: 144.88, lowerLAT: -37.84, upperLON: 145.05, upperLAT: -37.76)
    
    var bounding = GMSPolygon()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        print(dataset.name)
        self.getDatasetProperties()
        
        // Add a google map to the view
        self.mapView.isMyLocationEnabled = true;
        self.mapView.mapType = .normal;
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
        
        self.chooseBBOX = BBOX(lowerLON: lowerLON, lowerLAT: lowerLAT, upperLON: upperLON, upperLAT: upperLAT)
        
        let camera = GMSCameraPosition.camera(withLatitude: centerLAT, longitude: centerLON, zoom: zoomLevel)
        self.mapView.animate(to: camera)
        
        // Draw bounding box on map
        let rect = GMSMutablePath()
        rect.add(CLLocationCoordinate2D(latitude: lowerLAT, longitude: lowerLON))
        rect.add(CLLocationCoordinate2D(latitude: upperLAT, longitude: lowerLON))
        rect.add(CLLocationCoordinate2D(latitude: upperLAT, longitude: upperLON))
        rect.add(CLLocationCoordinate2D(latitude: lowerLAT, longitude: upperLON))
        
        bounding = GMSPolygon(path: rect)
        bounding.strokeColor = UIColor.black
        bounding.strokeWidth = 0
        bounding.fillColor = UIColor(red: 28.0/255.0, green: 79.0/255.0, blue: 107.0/255.0, alpha: 0.15)
        //bbox.map = self.mapView
    
        
        // Table's appearance
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = "Dataset Detail"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        
    }
    
    // Get the detail information of selected dataset from AURIN serer.
    func getDatasetProperties() {
        
        Alamofire.request("http://openapi.aurin.org.au/wfs?request=DescribeFeatureType&service=WFS&version=1.1.0&typeName=\(dataset.name)")
            .authenticate(user: "student", password: "dj78dfGF")
            .response { response in

                //print(response.data!) // if you want to check XML data in debug window.
                let xml = SWXMLHash.parse(response.data!)
                for property in xml["xsd:schema"]["xsd:complexType"]["xsd:complexContent"]["xsd:extension"]["xsd:sequence"]["xsd:element"].all {
                    let propertyName = (property.element?.attribute(by: "name")?.text)!
                    var propertyType = (property.element?.attribute(by: "type")?.text)!
                    propertyType = propertyType.components(separatedBy: ":")[1]
                    //print("\(propertyName): \(propertyType)")
                    self.propertyList.updateValue(propertyType, forKey: propertyName)                
                }
                self.tableView.reloadData()
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DatasetDetailTableViewCell
        
        cell.backgroundColor = UIColor.clear
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
            for geom_title in ["the_geom", "geom", "wkb_geometry", "ogr_geometry"] {
                if propertyList[geom_title] != nil {
                    cell.valueLabel.text = propertyList[geom_title]
                    self.geom_name = geom_title
                    break
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                if let url = URL(string: self.dataset.website) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let callAction = UIAlertAction(title: "Visit Website", style: .default, handler: callActionHandler)
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(callAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        if indexPath.row == 5 {
            let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
            // Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let showBounding = UIAlertAction(title: "Show Bounding Box on Map", style: .default, handler: { (action:UIAlertAction!) -> Void in
                self.bounding.map = self.mapView
            })
            let dropBounding = UIAlertAction(title: "Don't Show Bounding Box", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
                self.bounding.map = nil
            })
            
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(showBounding)
            optionMenu.addAction(dropBounding)
            self.present(optionMenu, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapSetting" {
            let destinationController = segue.destination as! MapSettingTableViewController
            destinationController.dataset = dataset
            destinationController.propertyList = propertyList
            destinationController.geom_name = geom_name
            destinationController.chooseBBOX = chooseBBOX
            // destinationController.hidesBottomBarWhenPushed = true
        }
        
        if segue.identifier == "showChartSetting" {
            let destinationController = segue.destination as! ChartSettingTableViewController
            destinationController.dataset = dataset
            destinationController.propertyList = propertyList
            destinationController.geom_name = geom_name
            destinationController.chooseBBOX = chooseBBOX

        }
    }

}
