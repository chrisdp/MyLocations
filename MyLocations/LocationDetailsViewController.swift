//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by christopher dwyer-perkins on 2016-04-14.
//  Copyright © 2016 christopher dwyer-perkins. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UITableViewController {
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dataLabel: UILabel!
  
  @IBAction func done() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
