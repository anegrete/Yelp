//
//  OptionTableViewCell.swift
//  Yelp
//
//  Created by anegrete on 10/24/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!

    // MARK: - View Lifecycle

    var optionSelected: Bool = false {
        didSet {
            updateImage()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - UI Actions

    func didSelect() {
        optionSelected = !optionSelected
        updateImage()
    }

    // MARK: - Views

    func updateImage() {
        statusImageView.image = optionSelected
            ? UIImage(named: "icon-selected")
            : UIImage(named: "icon-unselected")
    }
}
