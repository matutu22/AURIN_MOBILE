//
//  DataStorage.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/15.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

/********************************************************************************************
 Description：
    This file is to store some data used in the project, such as bounding box of each suburbs.

 ********************************************************************************************/


import Foundation
import UIKit

// Color palettes.
class ColorSet {
    
    static let theme = [
        "AURIN-Ming": UIColor(red: 28.0/255.0, green: 79.0/255.0, blue: 107.0/255.0, alpha: 1.0)
    ]
    
    
    static let colorDictionary = [
        "Red":    UIColor(red:242/255, green:038/255, blue:019/255, alpha:1.0),
        "Orange": UIColor(red:248/255, green:148/255, blue:006/255, alpha:1.0),
        "Green":  UIColor(red:038/255, green:166/255, blue:091/255, alpha:1.0),
        "Blue":   UIColor(red:065/255, green:131/255, blue:215/255, alpha:1.0),
        "Purple": UIColor(red:142/255, green:068/255, blue:173/255, alpha:1.0),
        "Gray":   UIColor(red:000/255, green:000/255, blue:000/255, alpha:1.0)]
    
    
    
    static let redSet = [
        UIColor(red:049/255, green:053/255, blue:148/255, alpha:1.0),
        UIColor(red:066/255, green:117/255, blue:181/255, alpha:1.0),
        UIColor(red:115/255, green:173/255, blue:208/255, alpha:1.0),
        UIColor(red:170/255, green:218/255, blue:233/255, alpha:1.0),
        UIColor(red:225/255, green:243/255, blue:247/255, alpha:1.0),
        UIColor(red:255/255, green:224/255, blue:145/255, alpha:1.0),
        UIColor(red:252/255, green:174/255, blue:096/255, alpha:1.0),
        UIColor(red:244/255, green:109/255, blue:066/255, alpha:1.0),
        UIColor(red:214/255, green:048/255, blue:048/255, alpha:1.0),
        UIColor(red:165/255, green:000/255, blue:041/255, alpha:1.0)]
    
    static let OrangeSet = [
        UIColor(red:255/255, green:255/255, blue:255/255, alpha:1.0),
        UIColor(red:255/255, green:255/255, blue:204/255, alpha:1.0),
        UIColor(red:255/255, green:237/255, blue:160/255, alpha:1.0),
        UIColor(red:254/255, green:217/255, blue:118/255, alpha:1.0),
        UIColor(red:254/255, green:178/255, blue:076/255, alpha:1.0),
        UIColor(red:253/255, green:114/255, blue:060/255, alpha:1.0),
        UIColor(red:252/255, green:078/255, blue:042/255, alpha:1.0),
        UIColor(red:227/255, green:026/255, blue:028/255, alpha:1.0),
        UIColor(red:189/255, green:000/255, blue:038/255, alpha:1.0),
        UIColor(red:103/255, green:000/255, blue:013/255, alpha:1.0)]
    
    static let GreenSet = [
        UIColor(red:247/255, green:252/255, blue:245/255, alpha:1.0),
        UIColor(red:229/255, green:245/255, blue:224/255, alpha:1.0),
        UIColor(red:199/255, green:233/255, blue:192/255, alpha:1.0),
        UIColor(red:116/255, green:217/255, blue:155/255, alpha:1.0),
        UIColor(red:116/255, green:198/255, blue:118/255, alpha:1.0),
        UIColor(red:065/255, green:171/255, blue:093/255, alpha:1.0),
        UIColor(red:035/255, green:139/255, blue:069/255, alpha:1.0),
        UIColor(red:000/255, green:109/255, blue:044/255, alpha:1.0),
        UIColor(red:000/255, green:087/255, blue:035/255, alpha:1.0),
        UIColor(red:000/255, green:050/255, blue:020/255, alpha:1.0)]
    
    static let BlueSet = [
        UIColor(red:247/255, green:251/255, blue:255/255, alpha:1.0),
        UIColor(red:222/255, green:235/255, blue:247/255, alpha:1.0),
        UIColor(red:198/255, green:219/255, blue:239/255, alpha:1.0),
        UIColor(red:158/255, green:202/255, blue:225/255, alpha:1.0),
        UIColor(red:107/255, green:174/255, blue:214/255, alpha:1.0),
        UIColor(red:066/255, green:146/255, blue:198/255, alpha:1.0),
        UIColor(red:033/255, green:113/255, blue:181/255, alpha:1.0),
        UIColor(red:008/255, green:081/255, blue:156/255, alpha:1.0),
        UIColor(red:008/255, green:048/255, blue:107/255, alpha:1.0),
        UIColor(red:005/255, green:039/255, blue:089/255, alpha:1.0)]
    
    static let PurpleSet = [
        UIColor(red:252/255, green:251/255, blue:253/255, alpha:1.0),
        UIColor(red:239/255, green:237/255, blue:245/255, alpha:1.0),
        UIColor(red:218/255, green:218/255, blue:235/255, alpha:1.0),
        UIColor(red:188/255, green:189/255, blue:220/255, alpha:1.0),
        UIColor(red:158/255, green:154/255, blue:200/255, alpha:1.0),
        UIColor(red:128/255, green:125/255, blue:186/255, alpha:1.0),
        UIColor(red:106/255, green:081/255, blue:163/255, alpha:1.0),
        UIColor(red:084/255, green:039/255, blue:143/255, alpha:1.0),
        UIColor(red:063/255, green:000/255, blue:125/255, alpha:1.0),
        UIColor(red:046/255, green:000/255, blue:092/255, alpha:1.0)]
    
    static let GraySet = [
        UIColor(red:230/255, green:230/255, blue:230/255, alpha:1.0),
        UIColor(red:215/255, green:215/255, blue:215/255, alpha:1.0),
        UIColor(red:200/255, green:200/255, blue:200/255, alpha:1.0),
        UIColor(red:175/255, green:175/255, blue:175/255, alpha:1.0),
        UIColor(red:150/255, green:150/255, blue:150/255, alpha:1.0),
        UIColor(red:125/255, green:125/255, blue:125/255, alpha:1.0),
        UIColor(red:100/255, green:100/255, blue:100/255, alpha:1.0),
        UIColor(red:075/255, green:075/255, blue:075/255, alpha:1.0),
        UIColor(red:050/255, green:050/255, blue:050/255, alpha:1.0),
        UIColor(red:025/255, green:025/255, blue:025/255, alpha:1.0)]
    
    static let barChartRed = [
        UIColor(red:1.00, green:0.54, blue:0.50, alpha:1.0),
        UIColor(red:1.00, green:0.32, blue:0.32, alpha:1.0),
        UIColor(red:1.00, green:0.09, blue:0.27, alpha:1.0),
        UIColor(red:0.84, green:0.00, blue:0.00, alpha:1.0)
    ]
    
    static let barChartOrange = [
        UIColor(red:1.00, green:0.82, blue:0.50, alpha:1.0),
        UIColor(red:1.00, green:0.67, blue:0.25, alpha:1.0),
        UIColor(red:1.00, green:0.57, blue:0.00, alpha:1.0),
        UIColor(red:1.00, green:0.43, blue:0.00, alpha:1.0)
    ]
    
    static let barChartGreen = [
        UIColor(red:0.65, green:0.84, blue:0.65, alpha:1.0),
        UIColor(red:0.40, green:0.73, blue:0.42, alpha:1.0),
        UIColor(red:0.26, green:0.63, blue:0.28, alpha:1.0),
        UIColor(red:0.18, green:0.49, blue:0.20, alpha:1.0)
    ]
    
    static let barChartBlue = [
        UIColor(red:0.39, green:0.71, blue:0.96, alpha:1.0),
        UIColor(red:0.13, green:0.59, blue:0.95, alpha:1.0),
        UIColor(red:0.10, green:0.46, blue:0.82, alpha:1.0),
        UIColor(red:0.05, green:0.28, blue:0.63, alpha:1.0)
    ]
    
    static let barChartPurple = [
        UIColor(red:0.70, green:0.62, blue:0.86, alpha:1.0),
        UIColor(red:0.49, green:0.34, blue:0.76, alpha:1.0),
        UIColor(red:0.37, green:0.21, blue:0.69, alpha:1.0),
        UIColor(red:0.27, green:0.15, blue:0.63, alpha:1.0)
    ]
    
    static let barChartGray = [
        UIColor(red:0.74, green:0.74, blue:0.74, alpha:1.0),
        UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0),
        UIColor(red:0.46, green:0.46, blue:0.46, alpha:1.0),
        UIColor(red:0.38, green:0.38, blue:0.38, alpha:1.0)
    ]
    
}

class bboxSet {
    
    static let States: [String: (lowerLAT:Double, lowerLON:Double, upperLAT:Double, upperLON:Double)] =
                        ["Capital Territory": (-35.9208,148.7627,-35.1245,149.3993),
                         "New South Wales": (-37.5051,140.9993,-22.1570,159.1092),
                         "Victoria": (-39.1592,140.9617,-33.9806,149.9767),
                         "Tasmania": (-43.7405,143.8189,-39.2037,148.4987),
                         "Queensland": (-29.1779,137.9960,-9.1422,153.5522),
                         "South Australia": (-38.0626,129.0013,-25.9961,141.0030),
                         "Northern Territory": (-37.5051,140.9993,-22.1570,159.1092),
                         "Western Australia": (-35.1348,112.9211,-13.6895,129.0019)]
    
    static let BBoxes: [String: BBOX] =
        ["VIC-All":BBOX(lowerLON: 140.9617, lowerLAT: -39.1592, upperLON: 149.9767, upperLAT: -33.9806),
         "Ballarat": BBOX(lowerLON: 143.0630, lowerLAT: -37.9885, upperLON: 144.4906, upperLAT: -36.6988),
         "Bendigo": BBOX(lowerLON: 143.3152, lowerLAT: -37.4589, upperLON: 144.8536, upperLAT: -35.9059),
         "Geelong": BBOX(lowerLON: 143.6221, lowerLAT: -38.5794, upperLON: 144.7202, upperLAT: -37.7812),
         "Hume": BBOX(lowerLON: 144.5304, lowerLAT: -37.8280, upperLON: 148.2207, upperLAT: -35.9285),
         "Latrobe - Gippsland": BBOX(lowerLON: 145.1094, lowerLAT: -39.1592, upperLON: 149.9767, upperLAT: -36.6124),
         "Melbourne - Inner": BBOX(lowerLON: 144.8889, lowerLAT: -37.8917, upperLON: 145.0453, upperLAT: -37.7325),
         "Melbourne - Inner East": BBOX(lowerLON: 144.9993, lowerLAT: -37.8759, upperLON: 145.1841, upperLAT: -37.7339),
         "Melbourne - Inner South": BBOX(lowerLON: 144.9834, lowerLAT: -38.0850, upperLON: 145.1563, upperLAT: -37.8374),
         "Melbourne - North East": BBOX(lowerLON: 144.9907, lowerLAT: -37.7851, upperLON: 145.5800, upperLAT: -37.2629),
         "Melbourne - North West": BBOX(lowerLON: 144.4577, lowerLAT: -37.7761, upperLON: 144.9853, upperLAT: -37.1751),
         "Melbourne - Outer East": BBOX(lowerLON: 145.1569, lowerLAT: -37.9750, upperLON: 145.8784, upperLAT: -37.5260),
         "Melbourne - South East": BBOX(lowerLON: 145.0795, lowerLAT: -38.3325, upperLON: 145.7651, upperLAT: -37.8533),
         "Melbourne - West": BBOX(lowerLON: 144.3336, lowerLAT: -38.0046, upperLON: 144.9165, upperLAT: -37.5464),
         "Mornington Peninsula": BBOX(lowerLON: 144.6514, lowerLAT: -38.5030, upperLON: 145.2617, upperLAT: -38.0674),
         "North West": BBOX(lowerLON: 140.9617, lowerLAT: -37.8366, upperLON: 144.4182, upperLAT: -33.9804),
         "Shepparton": BBOX(lowerLON: 144.2593, lowerLAT: -36.7626, upperLON: 146.2465, upperLAT: -35.8020),
         "Warrnambool and South West": BBOX(lowerLON: 140.9657, lowerLAT: -38.8577, upperLON: 143.9461, upperLAT: -37.0870),
         
         
         
         "ACT-All": BBOX(lowerLON: 148.7627, lowerLAT: -35.9208, upperLON: 149.3993, upperLAT: -35.1245),
         "Canberra": BBOX(lowerLON: 148.7627,lowerLAT: -35.9208,upperLON: 149.3993,upperLAT: -35.1245),
         
         
         
         "NSW-All": BBOX(lowerLON: 140.9993, lowerLAT: -37.5051, upperLON: 159.1092, upperLAT: -22.1570),
         "Capital Region": BBOX(lowerLON: 147.7108,lowerLAT: -37.5051,upperLON: 150.3791,upperLAT: -33.8878),
         "Central Coast": BBOX(lowerLON: 150.9841,lowerLAT: -33.5706,upperLON: 151.6305,upperLAT: -33.0436),
         "Central West": BBOX(lowerLON: 146.0540,lowerLAT: -34.3172,upperLON: 150.6198,upperLAT: -31.7787),
         "Coffs Harbour": BBOX(lowerLON: 152.1683,lowerLAT: -30.5671,upperLON: 153.3948,upperLAT: -28.9700),
         "Far West and Orana": BBOX(lowerLON: 140.9995,lowerLAT: -33.3667,upperLON: 150.1106,upperLAT: -28.9978),
         "Hunter Valley exc Newcastle": BBOX(lowerLON: 149.7916,lowerLAT: -33.1390,upperLON: 152.3369,upperLAT: -31.5537),
         "Illawarra": BBOX(lowerLON: 150.5275,lowerLAT: -34.7922,upperLON: 151.0662,upperLAT: -34.0934),
         "Mid North Coast": BBOX(lowerLON: 151.4028,lowerLAT: -32.6158,upperLON: 159.1092,upperLAT: -30.5006),
         "Murray": BBOX(lowerLON: 141.0017,lowerLAT: -36.1299,upperLON: 147.8192,upperLAT: -32.7485),
         "Newcastle and Lake Macquarie": BBOX(lowerLON: 151.3315,lowerLAT: -33.2028,upperLON: 151.8788,upperLAT: -32.7798),
         "New England and North West": BBOX(lowerLON: 148.6762,lowerLAT: -31.8582,upperLON: 152.6314,upperLAT: -28.2492),
         "Riverina": BBOX(lowerLON: 144.8511,lowerLAT: -36.8061,upperLON: 148.8088,upperLAT: -32.6713),
         "Southern Highlands and Shoalhaven": BBOX(lowerLON: 149.9761,lowerLAT: -35.5684,upperLON: 150.8498,upperLAT: -34.2125),
         "Sydney - Baulkham Hills and Hawkesbury": BBOX(lowerLON: 150.3567,lowerLAT: -33.7730,upperLON: 151.1556,upperLAT: -32.9961),
         "Sydney - Blacktown": BBOX(lowerLON: 150.7596,lowerLAT: -33.8340,upperLON: 150.9669,upperLAT: -33.6429),
         "Sydney - City and Inner South": BBOX(lowerLON: 151.1366,lowerLAT: -33.9848,upperLON: 151.2367,upperLAT: -33.8509),
         "Sydney - Eastern Suburbs": BBOX(lowerLON: 151.2112,lowerLAT: -34.0018,upperLON: 151.2878,upperLAT: -33.8325),
         "Sydney - Inner South West": BBOX(lowerLON: 150.9660,lowerLAT: -34.0060,upperLON: 151.1680,upperLAT: -33.8820),
         "Sydney - Inner West": BBOX(lowerLON: 151.0567,lowerLAT: -33.9163,upperLON: 151.1966,upperLAT: -33.8228),
         "Sydney - Northern Beaches": BBOX(lowerLON: 151.1608,lowerLAT: -33.8239,upperLON: 151.3430,upperLAT: -33.5719),
         "Sydney - North Sydney and Hornsby": BBOX(lowerLON: 151.0579,lowerLAT: -33.8536,upperLON: 151.2689,upperLAT: -33.5073),
         "Sydney - Outer South West": BBOX(lowerLON: 150.4183,lowerLAT: -34.3312,upperLON: 150.9967,upperLAT: -33.9408),
         "Sydney - Outer West and Blue Mountains": BBOX(lowerLON: 149.9719,lowerLAT: -34.3083,upperLON: 150.8412,upperLAT: -33.4857),
         "Sydney - Parramatta": BBOX(lowerLON: 150.9124,lowerLAT: -33.8990,upperLON: 151.0841,upperLAT: -33.7571),
         "Sydney - Ryde": BBOX(lowerLON: 151.0375,lowerLAT: -33.8449,upperLON: 151.1803,upperLAT: -33.7192),
         "Sydney - South West": BBOX(lowerLON: 150.6179,lowerLAT: -34.0510,upperLON: 150.9981,upperLAT: -33.8207),
         "Sydney - Sutherland": BBOX(lowerLON: 150.9366,lowerLAT: -34.1723,upperLON: 151.2319,upperLAT: -33.9772),

         
         
         "TAS-All": BBOX(lowerLON: 143.8189, lowerLAT: -43.7405, upperLON: 148.4987,upperLAT: -39.2037),
         "Hobart": BBOX(lowerLON: 147.0267,lowerLAT: -43.1213,upperLON: 147.9369,upperLAT: -42.6554),
         "Launceston and North East": BBOX(lowerLON: 145.9513,lowerLAT: -42.2813,upperLON: 148.4987,upperLAT: -39.2037),
         "South East": BBOX(lowerLON: 145.8325,lowerLAT: -43.7405,upperLON: 148.3593,upperLAT: -41.7003),
         "West and North West": BBOX(lowerLON: 143.8189,lowerLAT: -43.3226,upperLON: 146.7621,upperLAT: -39.5793),
         
         
         
         "QLD-All": BBOX(lowerLON: 137.9960, lowerLAT: -29.1779, upperLON: 153.5522, upperLAT: -9.1422),
         "Brisbane - East": BBOX(lowerLON: 153.0879,lowerLAT: -27.7408,upperLON: 153.5467,upperLAT: -27.0220),
         "Brisbane Inner City": BBOX(lowerLON: 152.9583,lowerLAT: -27.4938,upperLON: 153.0896,upperLAT: -27.4040),
         "Brisbane - North": BBOX(lowerLON: 152.9752,lowerLAT: -27.4457,upperLON: 153.1605,upperLAT: -27.2787),
         "Brisbane - South": BBOX(lowerLON: 152.9693,lowerLAT: -27.6604,upperLON: 153.1918,upperLAT: -27.4576),
         "Brisbane - West": BBOX(lowerLON: 152.7986,lowerLAT: -27.6021,upperLON: 153.0206,upperLAT: -27.3933),
         "Cairns": BBOX(lowerLON: 144.7408,lowerLAT: -18.5783,upperLON: 146.3587,upperLAT: -15.9028),
         "Darling Downs - Maranoa": BBOX(lowerLON: 146.8631,lowerLAT: -29.1779,upperLON: 152.4926,upperLAT: -24.8789),
         "Fitzroy": BBOX(lowerLON: 146.5725,lowerLAT: -25.9661,upperLON: 152.7184,upperLAT: -21.9152),
         "Gold Coast": BBOX(lowerLON: 153.0079,lowerLAT: -28.3579,upperLON: 153.5522,upperLAT: -27.6918),
         "Ipswich": BBOX(lowerLON: 152.1340,lowerLAT: -28.3390,upperLON: 152.9984,upperLAT: -26.9902),
         "Logan - Beaudesert": BBOX(lowerLON: 152.6478,lowerLAT: -28.3640,upperLON: 153.2905,upperLAT: -27.5873),
         "Mackay": BBOX(lowerLON: 146.0315,lowerLAT: -23.5560,upperLON: 150.4420,upperLAT: -19.7055),
         "Moreton Bay - North": BBOX(lowerLON: 152.0734,lowerLAT: -27.2635,upperLON: 153.2076,upperLAT: -26.4519),
         "Moreton Bay - South": BBOX(lowerLON: 152.6810,lowerLAT: -27.4224,upperLON: 153.0779,upperLAT: -27.0862),
         "Queensland - Outback": BBOX(lowerLON: 137.9960,lowerLAT: -28.9991,upperLON: 147.9553,upperLAT: -9.1422),
         "Sunshine Coast": BBOX(lowerLON: 152.5509,lowerLAT: -26.9848,upperLON: 153.1514,upperLAT: -26.1371),
         "Toowoomba": BBOX(lowerLON: 151.7665,lowerLAT: -27.9697,upperLON: 152.3823,upperLAT: -27.3493),
         "Townsville": BBOX(lowerLON: 144.2852,lowerLAT: -22.1048,upperLON: 147.6633,upperLAT: -18.3137),
         "Wide Bay": BBOX(lowerLON: 150.3696,lowerLAT: -26.9479,upperLON: 153.3604,upperLAT: -24.3921),

         
         
         "SA-All": BBOX(lowerLON: 129.0013, lowerLAT: -38.0626, upperLON: 141.0030, upperLAT: -25.9961),
         "Adelaide - Central and Hills": BBOX(lowerLON: 138.5719,lowerLAT: -35.2433,upperLON: 139.0440,upperLAT: -34.6805),
         "Adelaide - North": BBOX(lowerLON: 138.4362,lowerLAT: -34.8883,upperLON: 138.8480,upperLAT: -34.5002),
         "Adelaide - South": BBOX(lowerLON: 138.4421,lowerLAT: -35.3503,upperLON: 138.7134,upperLAT: -34.9585),
         "Adelaide - West": BBOX(lowerLON: 138.4757,lowerLAT: -34.9759,upperLON: 138.5879,upperLAT: -34.7552),
         "Barossa - Yorke - Mid North": BBOX(lowerLON: 136.4414,lowerLAT: -35.3782,upperLON: 139.3580,upperLAT: -32.1203),
         "South Australia - Outback": BBOX(lowerLON: 129.0013,lowerLAT: -35.3404,upperLON: 141.0030,upperLAT: -25.9961),
         "South Australia - South East": BBOX(lowerLON: 136.5329,lowerLAT: -38.0626,upperLON: 140.9739,upperLAT: -33.8008),
         
         
         "NT-All": BBOX(lowerLON: 129.0004, lowerLAT: -25.9995, upperLON: 138.0012, upperLAT: -10.9659),
         "Darwin": BBOX(lowerLON: 130.8151,lowerLAT: -12.8619,upperLON: 131.3967,upperLAT: -12.0010),
         "Northern Territory - Outback": BBOX(lowerLON: 129.0004,lowerLAT: -25.9995,upperLON: 138.0012,upperLAT: -10.9659),
         
         
         "WA-All": BBOX(lowerLON: 112.9211, lowerLAT: -35.1348, upperLON: 129.0019, upperLAT: -13.6895),
         "Bunbury": BBOX(lowerLON: 114.9746,lowerLAT: -35.0689,upperLON: 116.8568,upperLAT: -32.7552),
         "Mandurah": BBOX(lowerLON: 115.6068,lowerLAT: -32.8019,upperLON: 116.0315,upperLAT: -32.4446),
         "Perth - Inner": BBOX(lowerLON: 115.7500,lowerLAT: -32.0251,upperLON: 115.8934,upperLAT: -31.9075),
         "Perth - North East": BBOX(lowerLON: 115.8769,lowerLAT: -32.0626,upperLON: 116.4151,upperLAT: -31.5972),
         "Perth - North West": BBOX(lowerLON: 115.5607,lowerLAT: -31.9330,upperLON: 115.8999,upperLAT: -31.4551),
         "Perth - South East": BBOX(lowerLON: 115.8266,lowerLAT: -32.4775,upperLON: 116.3581,upperLAT: -31.9159),
         "Perth - South West": BBOX(lowerLON: 115.4495,lowerLAT: -32.4582,upperLON: 115.9162,upperLAT: -31.9873),
         "Western Australia - Outback": BBOX(lowerLON: 112.9211,lowerLAT: -34.4747,upperLON: 129.0019,upperLAT: -13.6895),
         "Western Australia - Wheat Belt": BBOX(lowerLON: 114.9704,lowerLAT: -35.1348,upperLON: 120.5815,upperLAT: -29.6123)
            
         
         ]
    
}


class DataSet {
    
    static let invalidData: [String: Int] = [
        "AU_Emp_LabourSec": 1,
        "AU_Emp_LabourSec_detail": 1,
        "AU_Freight_Vehicle_Stock": 1,
        "AU_Fuel_Use": 1,
        "AU_Intercity_Travel_Vehicles": 1,
        "AU_exports_OFD_goods": 1,
        "AU_exports_OI_goods": 1,
        "AU_exports_energy": 1,
        "AU_exports_materials": 1,
        "AU_exports_new_vehicles": 1,
        "AU_exports_primary_materials": 1,
        "AU_exports_recycled_materials": 1,
        "AU_imports_OFD_goods": 1,
        "AU_imports_OI_goods": 1,
        "AU_imports_energy": 1,
        "AU_imports_materials": 1,
        "AU_imports_new_vehicles": 1,
        "AU_imports_primary_materials": 1,
        "AU_imports_recycled_materials": 1,
        "AU_secLightIndustry_Fuel_Use": 1,
        "GCCSA Urban Transit Vehicles 1946-2006 for Australia": 1,
        "STE Male Age Profile 1946-2006 for Australia": 1,
        "STE Light Commercial Vehicle Stock 1946-2006 for Australia": 1,
        "STE Female International Migration 1946-2006 for Australia": 1,
        "STE Female Domestic Migration 1946-2006 for Australia": 1,
        "STE Female Age Profile 1946-2006 for Australia": 1,
        "STE Male Domestic Migration 1946-2006 for Australia": 1,
        "STE Male International Migration 1946-2006 for Australia": 1,
        "STE Number of Female Deaths 1946-2006 for Australia": 1,
        "STE Number of Live Births 1946-2006 for Australia": 1,
        "STE Number of Male Deaths 1946-2006 for Australia": 1,
        "STE Personal Use Passenger Vehicle Stock 1946-2006 for Australia": 1,
        "STE_Elect_Use": 1,
        "STE_CommInstEmp": 1,
        "bld_footprints": 1,
        "dist_coast_log_by_10": 1,
        "footpaths_aug2015": 1,
        "trees_july2015": 1,
        
        "SSD Commercial and Industrial Building Space 1951-2006 for Australia": 2,
        "SSD_secHeavyIndustry_Fuel_Use": 2,
        "SSD Residential Buildings 1951-2006 for Australia": 2,
        "SD_Land_Use": 2
        
    ]
    
    
    static var savedDataset = Set<String>()
    
    static var filterBBOX = BBOX(lowerLON: 0, lowerLAT: 0, upperLON: 0, upperLAT: 0)
    
}


class Numbers {
    static var newSavedItem = 0

}