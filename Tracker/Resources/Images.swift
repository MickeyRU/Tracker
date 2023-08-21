//
//  Images.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

struct Images {
    static let trackerTabBarImage = UIImage(named: "trackerTabBarImage")
    static let statisticsTabBarImage = UIImage(named: "statisticsTabBarImage")
    static let addTrackerButtonImage = UIImage(named: "addTrackerButtonImage")
    static let addDaysButtonImage = UIImage(named: "addDaysButtonImage")?.withRenderingMode(.alwaysTemplate)
    static let addDaysButtonClickedImage = UIImage(named: "addDaysButtonClickedImage")?.withRenderingMode(.alwaysOriginal)
    static let arrowImage = UIImage(named: "arrowImage")
    static let emptyOnScreenImage = UIImage(named: "emptyOnScreenImage")
    static let emptyScreenSmileImage = UIImage(named: "emptyScreenSmileImage")
    static let selectedImage = UIImage(named: "selectedImage")
    
    static let onBoardingRedImage = UIImage(named: "red")
    static let onBoardingBlueImage = UIImage(named: "blue")
    
    static let pinnedTrackerImage = UIImage(named: "pinnedTrackerImage")
}
