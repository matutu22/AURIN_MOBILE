//
//  WalkthroughAnimationViewController.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/19.
//  Copyright © 2016年 University of Melbourne. All rights reserved.
//

import UIKit

class WalkthroughAnimationViewController: UIViewController {

    var index = 0
    @IBOutlet var animation_1: UIImageView!
    @IBOutlet var animation_2: UIImageView!
    @IBOutlet var animation_3: UIImageView!
    @IBOutlet var animation_4: UIImageView!
    @IBOutlet var animation_5: UIImageView!
    @IBOutlet var animation_6: UIImageView!
    @IBOutlet var animation_7: UIImageView!
    @IBOutlet var animation_8: UIImageView!
    
    @IBOutlet var getStartedButton: UIButton!
    @IBOutlet var dontShowButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        let translate = CGAffineTransformMakeTranslation(0, 600)
        animation_1.transform = translate
        animation_2.transform = translate
        animation_3.transform = translate
        animation_4.transform = translate
        animation_5.transform = translate
        animation_6.transform = translate
        animation_7.transform = translate
        animation_8.transform = translate
        getStartedButton.transform = translate
        dontShowButton.transform = translate
    }

    override func viewDidAppear(animated: Bool) {
        
        
        // Spring animation
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_1.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_2.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_3.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_4.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.15, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_5.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.35, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_6.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_7.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.65, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_8.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.getStartedButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.7, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.dontShowButton.transform = CGAffineTransformIdentity
            }, completion: nil)
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStaretedTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func dontShowTapped(sender: AnyObject) {
//        // 定义一个alertController，设定了title，message和style
//        let alertController = UIAlertController(title: "CLOSE INTRODUCTION", message: "This page will not appear next time. You can watch it in 'About' page.", preferredStyle: UIAlertControllerStyle.Alert)
//        // 向alertController添加了一个action，显示OK
//        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//        // 设置显示alertController
//        self.presentViewController(alertController, animated: true, completion: nil)
        
        let defaluts = NSUserDefaults.standardUserDefaults()
        let status = defaluts.boolForKey("ClosedWalkthrough")
        defaluts.setBool(!status, forKey: "ClosedWalkthrough")
        dismissViewControllerAnimated(true, completion: nil)
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
