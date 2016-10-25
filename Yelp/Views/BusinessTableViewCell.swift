//
//  BusinessTableViewCell.swift
//  Yelp
//
//  Created by anegrete on 10/22/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var ratingsLabel: UILabel!

    var index:Int? {
        didSet {
            nameLabel.text = "\(index!). " + business.name!
        }
    }

    var business: Business! {
        didSet {
            nameLabel.text = "\(index). " + business.name!
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
        }
    }

    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = 3
        thumbnailImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
