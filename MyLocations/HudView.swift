//
//  HudView.swift
//  MyLocations
//
//  Created by christopher dwyer-perkins on 2016-04-14.
//  Copyright © 2016 christopher dwyer-perkins. All rights reserved.
//

import UIKit

class HudView: UIView {
  var text = ""
  
  class func hudInView(view: UIView, animated: Bool) -> HudView {
    let hudView = HudView(frame: view.bounds)
    hudView.opaque = false
    
    view.addSubview(hudView)
    view.userInteractionEnabled = false
    
    hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    return hudView
  }
}
