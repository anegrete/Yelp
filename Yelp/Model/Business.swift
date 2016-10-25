//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit

class Business: NSObject {
    let name: String?
    let address: String?
    let imageURL: URL?
    let categories: String?
    let distance: String?
    let ratingImageURL: URL?
    let reviewCount: NSNumber?

    // MARK: - View Lifecycle

    init(dictionary: NSDictionary) {
        
        // Name
        name = dictionary[YelpBusiness.name] as? String

        // Image URL
        let imageURLString = dictionary[YelpBusiness.imageURL] as? String
        if imageURLString != nil {
            imageURL = URL(string: imageURLString!)!
        } else {
            imageURL = nil
        }

        // Address
        let location = dictionary[YelpBusiness.location] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location![YelpBusiness.address] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }

            let neighborhoods = location![YelpBusiness.neighborhoods] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.address = address
        
        // Categories
        let categoriesArray = dictionary[YelpBusiness.categories] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        
        // Distance
        let distanceMeters = dictionary[YelpBusiness.distance] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        // Rating
        let ratingImageURLString = dictionary[YelpBusiness.ratingImageURL] as? String
        if ratingImageURLString != nil {
            ratingImageURL = URL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary[YelpBusiness.reviewCount] as? NSNumber
    }
 
    // MARK: - Get all Businesses

    class func businesses(array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    // MARK: - Search Yelp API

    class func searchWithTerm(term: String, completion: @escaping ([Business]?, Error?) -> Void) {
        _ = YelpAPIClient.shared.searchWithTerm(term, completion: completion)
    }

    class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?,
                              distance:Int?, offset:Int?, completion: @escaping ([Business]?, Error?) -> Void) -> Void {
        _ = YelpAPIClient.shared.searchWithTerm(term, sort: sort, categories: categories, deals: deals, distance: distance, offset: offset, completion: completion)
    }
}
