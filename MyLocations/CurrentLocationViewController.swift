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
  var timer: NSTimer?
  
  // location vars
  var location: CLLocation?
  var updateingLocation = false
  var lastLocationError: NSError?
  
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError : NSError?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    updateLabels()
    configureGetButton()
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
    if updateingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      placemark = nil
      lastGeocodingError = nil
      startLocationManager()
    }

    updateLabels()
    configureGetButton()
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
      if let placemark = placemark {
        addressLabel.text = stringFromPlacemark(placemark)
      } else if performingReverseGeocoding {
        addressLabel.text = "Searching for Address..."
      } else if lastLocationError != nil {
        addressLabel.text = "Error Finding Address"
      } else {
        addressLabel.text = "No Address Found"
      }
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
  
  func configureGetButton() {
    if updateingLocation {
      getButton.setTitle("Stop", forState: .Normal)
    } else {
      getButton.setTitle("Get My Location", forState: .Normal)
    }
  }
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    var line1 = ""
    if let s = placemark.subThoroughfare {
      line1 += s + " "
    }
    
    if let s = placemark.thoroughfare {
      line1 += s
    }
    
    var line2 = ""
    
    if let s = placemark.locality {
      line2 += s + " "
    }
    
    if let s = placemark.administrativeArea {
      line2 += s + " "
    }
    if let s = placemark.postalCode {
      line2 += s
    }
    
    return line1 + "\n" + line2
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updateingLocation = true
      timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
    }
  }
  
  func stopLocationManager() {
    if updateingLocation {
      if let timer = timer {
        timer.invalidate()
      }
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updateingLocation = false
    }
  }
  
  func didTimeOut() {
    print(">> Request Timed Out")
    
    if location == nil {
      stopLocationManager()
      
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      
      updateLabels()
      configureGetButton()
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
    configureGetButton()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    
    // check if new location is a cached result
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    // if accuracy is less then 0 its is a invalid result
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    var distance = CLLocationDistance(DBL_MAX)
    if let location = location {
      distance = newLocation.distanceFromLocation(location)
    }
    
    // are the new results more accurate then the last set?
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      location = newLocation
      updateLabels()
      
      // once desired accuracy is acheived stop location services
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print(">> Desired Accuracy Acheved")
        stopLocationManager()
        configureGetButton()
        if distance > 0 {
          performingReverseGeocoding = false
        }
      }
      
      if !performingReverseGeocoding {
        print(">> Reverse Geocoding Started")
        
        performingReverseGeocoding = true
        
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
          placemarks, error in
          print(">> Found Placemarks: \(placemarks), Error: \(error)")
          self.lastLocationError = error
          if error == nil, let p = placemarks where !p.isEmpty {
            self.placemark = p.last!
          } else {
            self.placemark = nil
          }
          
          self.performingReverseGeocoding = false
          self.updateLabels()
          })
      }
    } else if distance < 1.0 {
      let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
      
      if timeInterval > 10 {
        print(">> Force Finish")
        stopLocationManager()
        updateLabels()
        configureGetButton()
      }
    }
  }
}

