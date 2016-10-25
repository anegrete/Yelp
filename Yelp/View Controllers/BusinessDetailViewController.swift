//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by anegrete on 10/24/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var writeReviewView: UIView!
    var business: Business! {
        didSet {
            nameLabel.text = business.name!
            if let imageURL = business.imageURL {
                thumbnailImageView.setImageWith(imageURL)
            } else {
                thumbnailImageView.image = nil
            }
            ratingsImageView.setImageWith(business.ratingImageURL!)
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            distanceLabel.text = business.distance
            ratingsLabel.text = "\(business.reviewCount!) Reviews"
            addressLabel.text = business.address
            
            setupMapView()
        }
    }
    
    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        thumbnailImageView.addSubview(blurEffectView)
        thumbnailImageView.alpha = 0.6
        
        writeReviewView.layer.cornerRadius = 5
        writeReviewView.clipsToBounds = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - MapView

    func setupMapView() {
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(centerLocation.coordinate, span)
        mapView.setRegion(region, animated: false)
        
        addAnnotationAtAddress(address: business.address!, title: business.name!, subtitle: business.address!)
    }
    
    func addAnnotationAtAddress(address: String, title: String, subtitle: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    annotation.subtitle = subtitle
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
}
