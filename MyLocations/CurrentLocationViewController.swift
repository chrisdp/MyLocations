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
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  
  // instance vars
  let locationManager = CLLocationManager()
  
  // location vars
  var location: CLLocation?
  var updateingLocation = false
  var lastLocationError: NSError?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    updateLabels()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func getLocation() {
    
    print(">> getting location")
    let authStatus = CLLocationManager.authorizationStatus()
    
    // ask for location access
    if authStatus == .NotDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    // check if location access was denied or turned off
    if authStatus == .Denied || authStatus == .Restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    // request location
    startLocationManager()
    updateLabels()
  }
  
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
    
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    
    alert.addAction(okAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      
      tagButton.hidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.hidden = true
      
      // status text logic
      let statusMessage: String
      if let error = lastLocationError {
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Location Services Disabled"
      } else if updateingLocation {
        statusMessage = "Searching..."
      } else {
        statusMessage =  "Tap 'Get My Location' to Start"
      }
      messageLabel.text = statusMessage
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updateingLocation = true
    }
  }
  
  func stopLocationManager() {
    if updateingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updateingLocation = false
    }
  }
  
  // MARK: = CLLocationManagerDelegate
  
  func locationManageer(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError \(error)")
    
    if error.code == CLError.LocationUnknown.rawValue {
      return
    }
    
    lastLocationError = error
    
    stopLocationManager()
    updateLabels()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    
    lastLocationError = nil
    location = newLocation
    updateLabels()
  }

}

