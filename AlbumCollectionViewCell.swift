//
//  AlbumCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/4/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var cellActivityIndicator: UIActivityIndicatorView!
    override func prepareForReuse() {
       super.prepareForReuse()
        cellActivityIndicator.isHidden = false
        myImage.image = UIImage(named: "placeholder.png")
        cellActivityIndicator.startAnimating()
    }
}
