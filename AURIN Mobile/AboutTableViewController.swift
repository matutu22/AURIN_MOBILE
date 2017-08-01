//
//  AboutTableViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/10.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
//import SafariServices

class AboutTableViewController: UITableViewController {

    var sectionTitles = ["Supervisors & Author", "Follow us", "More about AURIN"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else if section == 1 {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AboutTableViewCell

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 2:
                cell.aboutImageView.image = UIImage(named: "about-hayden")
                cell.aboutTextLabel.text = "Haidong Wang"
            case 0:
                cell.aboutImageView.image = UIImage(named: "about-richard")
                cell.aboutTextLabel.text = "Prof. Richard Sinnott"
            case 1:
                cell.aboutImageView.image = UIImage(named: "about-luca")
                cell.aboutTextLabel.text = "Mr. Luca Morandini"
            default:
                break
            }
            //cell.aboutTextLabel.text = sectionContent[indexPath.section][indexPath.row]
        case 1:
            switch indexPath.row {
            case 0:
                cell.aboutImageView.image = UIImage(named: "social-twitter")
                cell.aboutTextLabel.text = "Twitter"
            case 1:
                cell.aboutImageView.image = UIImage(named: "social-facebook")
                cell.aboutTextLabel.text = "Facebook"
            case 2:
                cell.aboutImageView.image = UIImage(named: "social-linkedin")
                cell.aboutTextLabel.text = "LinkedIn"
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.aboutImageView.image = UIImage(named: "about_intro")
                cell.aboutTextLabel.text = "Watch Introduction"
                
            case 1:
                cell.aboutImageView.image = UIImage(named: "about-website")
                cell.aboutTextLabel.textColor = UIColor(red: 65.0/255.0, green: 151.0/255.0, blue: 235.0/255.0, alpha: 1.0)
                cell.aboutTextLabel.text = "Visit Official Website"
            default:
                break
            }
            
            
        default:
            break
        }
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        // Leave us feedback section
        case 0:
            break
        case 1:
            if indexPath.row == 0 {
                if let url = URL(string: "https://twitter.com/aurin_org_au") {
                    UIApplication.shared.openURL(url)
                }
            } else if indexPath.row == 1 {
                if let url = URL(string: "https://www.facebook.com/Aurin-183080631739008/") {
                    UIApplication.shared.openURL(url)
                }
            } else {
                if let url = URL(string: "https://www.linkedin.com/groups/6622107/profile") {
                    UIApplication.shared.openURL(url)
                }
            }
        case 2:
            if indexPath.row == 0 {
                if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController {
                    present(pageViewController, animated: true, completion: nil)
                }
            } else {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
