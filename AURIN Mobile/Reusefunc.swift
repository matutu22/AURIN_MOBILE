//
//  Reusefunc.swift
//  AURIN Mobile
//
//  Created by 马晨瀚 on 2017/9/25.
//  Copyright © 2017年 University of Melbourne. All rights reserved.
//

import Foundation

class Reuse{
    static let shared = Reuse()

    func showAlert(view: UIViewController , title : String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async(execute: {
            view.present(alert, animated: true, completion: nil)
        })
    }
    
    
    func showAlertWithSettings(view:UIViewController, title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
        alertController.addAction(okAction)
        
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
//            guard let url = NSURL(string: UIApplicationOpenSettingsURLString) else { return }
//            UIApplication.shared.openURL(url as URL)
//        }
//        alertController.addAction(settingsAction)
        
        view.present(alertController, animated: true, completion: nil)
    }
    
    func dateConverter(dateString : String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        
        return date!
    }

}
