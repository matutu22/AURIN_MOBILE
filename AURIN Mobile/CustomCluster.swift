//
//  CustomCluster.swift
//  AURIN Mobile
//
//  Created by 马晨瀚 on 2017/10/2.
//  Copyright © 2017年 University of Melbourne. All rights reserved.
//

import Foundation


// Clustering markers customization

class CustomClusterItem: NSObject, GMUClusterItem {
    
    var position: CLLocationCoordinate2D
    var icon: UIImage

    init(position: CLLocationCoordinate2D,  icon: UIImage)
    {
        
        self.position = position
        self.icon = icon
        
    }
    
}

//MARK: - GMUClusterRendererDelegate

func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
    marker.icon = UIImage(named: "marker")

}
