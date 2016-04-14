//
//  FirstViewController.swift
//  MyLocations
//
//  Created by christopher dwyer-perkins on 2016-04-14.
//  Copyright © 2016 christopher dwyer-perkins. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
  
  // UI refs
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabelL: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  
  // instance vars
  let locationManager = CLLocationManager()
  
  @IBAction func getLocation() {
    
    print(">> getting location")
    let authStatus = CLLocationManager.authorizationStatus()
    
    print(authStatus)
    if authStatus == .NotDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: = CLLocationManagerDelegate
  
  func locationManageer(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError \(error)")
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
  }

}

