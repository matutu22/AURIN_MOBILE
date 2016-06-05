//
//  WalkthroughContentViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/19.
//  Copyright © 2016年 University of Melbourne. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var forwardButton:UIButton!
    @IBOutlet var skipButton: UIButton!
    
    var index = 0
    var imageFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        
        switch index {
        case 0...5: forwardButton.setTitle("NEXT", forState: UIControlState.Normal)
        case 6: forwardButton.setTitle("DONE", forState: UIControlState.Normal)
        default: break
        }
        
    }
    
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        switch index {
        case 0...6:
            let pageViewController = parentViewController as!
            WalkthroughPageViewController
            pageViewController.forward(index)
        case 7:
            break
            //dismissViewControllerAnimated(true, completion: nil)
        default: break
        }
    }
    
    @IBAction func skipButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
