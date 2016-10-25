//
//  YelpAPIClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey     = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret  = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken           = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret     = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"

enum YelpSortMode: Int {
    case bestMatched = 0, distance, highestRated
}

enum YelpDistanceRadius: Int {
    case bestMatched = 0, twoBlocks, sixBlocks, oneMile, fiveMiles
}

class YelpAPIClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    //MARK: Shared Instance
    
    static let shared = YelpAPIClient(consumerKey: yelpConsumerKey,
                                      consumerSecret: yelpConsumerSecret,
                                      accessToken: yelpToken,
                                      accessSecret: yelpTokenSecret)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = URL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(_ term: String, completion: @escaping ([Business]?, Error?) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, sort: nil, categories: nil, deals: nil, distance: nil, offset: nil, completion: completion)
    }
    
    func searchWithTerm(_ term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Int?, offset:Int?, completion: @escaping ([Business]?, Error?) -> Void) -> AFHTTPRequestOperation {

        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // Search Term keyword
        var parameters: [String : AnyObject] = [YelpSearch.term: term as AnyObject]
        
        // Default location: San Francisco
        parameters[YelpSearch.location] = "37.785771,-122.406165" as AnyObject
//        parameters["location"] = "San Francisco" as AnyObject

        // Sort mode: 0=Best matched (default), 1=Distance, 2=Highest Rated.
        if sort != nil {
            parameters[YelpSearch.sort] = sort!.rawValue as AnyObject?
        }
        
        // Category to filter search results with. See the list of supported categories: https://www.yelp.com/developers/documentation/v2/all_category_list
        if categories != nil && categories!.count > 0 {
            parameters[YelpSearch.category] = (categories!).joined(separator: ",") as AnyObject?
        }
        
        // Whether to exclusively search for businesses with deals
        if deals != nil {
            parameters[YelpSearch.deals] = deals! as AnyObject?
        }

        if distance != nil {
            parameters[YelpSearch.distance] = distance! as AnyObject?
        }

        if offset != nil {
            parameters[YelpSearch.offset] = offset! as AnyObject?
        }

        print("Search: \(parameters)")
        
        return self.get("search", parameters: parameters,
                        success: { (operation: AFHTTPRequestOperation, response: Any) -> Void in
                            if let response = response as? [String: Any]{
                                let dictionaries = response["businesses"] as? [NSDictionary]
                                if dictionaries != nil {
                                    completion(Business.businesses(array: dictionaries!), nil)
                                }
                            }
            },
                        failure: { (operation: AFHTTPRequestOperation?, error: Error) -> Void in
                            completion(nil, error)
        })!
    }
}
