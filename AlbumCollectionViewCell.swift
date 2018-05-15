//
//  AlbumCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/4/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate: class {
    func delete(cell: AlbumCollectionViewCell)
}


class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var myImage: UIImageView!
    
  
    
}
