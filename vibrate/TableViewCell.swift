//
//  TableViewCell.swift
//  vibrate
//
//  Created by christopher putra setiawan on 23/01/19.
//  Copyright © 2019 christopher putra setiawan. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var songtitle: UILabel!
    @IBOutlet weak var songartist: UILabel!
    @IBOutlet weak var songicon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            self.contentView.backgroundColor = .black
            self.alpha = 0.5
        }
        else{
            self.alpha = 1
        }
    }
}
