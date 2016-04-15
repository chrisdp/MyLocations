//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by christopher dwyer-perkins on 2016-04-14.
//  Copyright © 2016 christopher dwyer-perkins. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Dispatch

class LocationDetailsViewController: UITableViewController  {
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  // instance vars
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  
  // private global constant date formatter
  private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
  }()
  
  // CoreData vars
  var managedObjectContext: NSManagedObjectContext!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionTextView.text = ""
    categoryLabel.text = categoryName
    
    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    
    if let placemark = placemark {
      addressLabel.text = stringFromPlacemark(placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    
    dateLabel.text = formatDate(NSDate())
    
    let gesterReconginizer = UITapGestureRecognizer(target: self, action: #selector(LocationDetailsViewController.hideKeyboard(_:)))
    gesterReconginizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gesterReconginizer)
  }
  
  func formatDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
  }
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    var text = ""
    
    if let s = placemark.subThoroughfare {
      text += s + " "
    }
    
    if let s = placemark.thoroughfare {
      text += s + ", "
    }
    
    if let s = placemark.locality {
      text += s + ", "
    }
    
    if let s = placemark.administrativeArea {
      text += s + " "
    }
    
    if let s = placemark.postalCode {
      text += s + ", "
    }
    
    if let s = placemark.country {
      text += s
    }
    
    return text
  }
  
  func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.locationInView(tableView)
    let indexPath = tableView.indexPathForRowAtPoint(point)
    
    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
      return
    }
    
    descriptionTextView.resignFirstResponder()
  }

  // MARK: - UITableViewDelegate
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 && indexPath.row == 0 {
      return 88
    } else if indexPath.section == 2 && indexPath.row == 2 {
      addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
      addressLabel.sizeToFit()
      addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
      return addressLabel.frame.size.height + 20
    } else {
      return 44
    }
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if indexPath.section == 0 || indexPath.section == 1 {
      return indexPath
    } else {
      return nil
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    }
  }
  
  @IBAction func done() {
    //dismissViewControllerAnimated(true, completion: nil)
    let hudView = HudView.hudInView(navigationController!.view, animated: true)
    
    hudView.text = "Tagged"
    
    afterDelay(0.8, closure:{
      self.dismissViewControllerAnimated(true, completion: nil)
    })
  }

  @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
    let controller = segue.sourceViewController as! CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destinationViewController as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
  }
  
}
