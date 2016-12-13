//
//  UserPicker.swift
//  Cara
//
//  Created by Kim Nguyen on 2016-12-12.
//  Copyright © 2016 NexttApps. All rights reserved.
//

import Foundation
import UIKit

class UserPicker: BaseController {

    
    @IBOutlet weak var driverBtn: UIButton!
    @IBOutlet weak var custBtn: UIButton!
    
    override func viewDidLoad() {
        custBtn.addTarget(self, action: #selector(self.onButtonTap(sender:)), for: .touchUpInside)
        driverBtn.addTarget(self, action: #selector(self.onButtonTap(sender:)), for: .touchUpInside)
    }
    
    func onButtonTap(sender: UIButton!) {
        if (sender == custBtn) {
            loadCustomerView()
        } else {
            loadDriverView()
        }
    }
    
    func loadCustomerView() {
        let view = Cusotmer(nibName: "CustomerView", bundle: nil)
        self.navigationController?.pushViewController(view, animated: true)
        view.setViewType(isCust: true)
    }
    
    func loadDriverView() {
        let view = Cusotmer(nibName: "CustomerView", bundle: nil)
        self.navigationController?.pushViewController(view, animated: true)
        view.setViewType(isCust: false)
    }
    
    
}
