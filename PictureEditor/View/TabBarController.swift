//
//  TabBarController.swift
//  PictureEditor
//
//  Created by Denis Raiko on 27.08.24.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "scribble.variable"), tag: 0)
        let mainNavController = UINavigationController(rootViewController: mainVC)
        
        let settingsVC = SettingsViewController(userName: "Райко Денис")
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "scribble.variable"), tag: 1)
        let SettingsNavController = UINavigationController(rootViewController: settingsVC)
        
        viewControllers = [mainNavController, SettingsNavController]
        
        tabBar.backgroundColor = .systemGray5
             
    }
}
