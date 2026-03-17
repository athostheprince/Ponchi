//
//  LaunchScreenController.swift
//  Ponchi
//
//  Created by mary romanova on 12.11.2025.
//

import Foundation
import UIKit
import SwiftUI

class LaunchScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let launchView = LaunchScreenView()
        let hostingController = UIHostingController(rootView: launchView)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
