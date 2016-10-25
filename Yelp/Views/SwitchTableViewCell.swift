//
//  SwitchTableViewCell.swift
//  Yelp
//
//  Created by anegrete on 10/22/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit

@objc protocol SwitchTableViewCellDelegate {
    @objc optional func switchCell(switchCell: SwitchTableViewCell, didChangeValue value:Bool)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!

    weak var delegate: SwitchTableViewCellDelegate?

    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - UI Actions

    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
    }
}
