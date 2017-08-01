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
        let translate = CGAffineTransform(translationX: 0, y: 600)
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

    override func viewDidAppear(_ animated: Bool) {
        
        
        // Spring animation
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_1.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_2.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_3.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_4.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.15, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_5.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.35, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_6.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_7.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.65, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.animation_8.transform = CGAffineTransform.identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.7, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.getStartedButton.transform = CGAffineTransform.identity
            }, completion: nil)
        
        UIView.animate(withDuration: 0.7, delay: 0.7, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.dontShowButton.transform = CGAffineTransform.identity
            }, completion: nil)
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStaretedTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func dontShowTapped(_ sender: AnyObject) {
        
        let defaluts = UserDefaults.standard
        let status = defaluts.bool(forKey: "ClosedWalkthrough")
        defaluts.set(!status, forKey: "ClosedWalkthrough")
        dismiss(animated: true, completion: nil)
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
