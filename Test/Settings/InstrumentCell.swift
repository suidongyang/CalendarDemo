//
//  InstrumentCell.swift
//  Test
//
//  Created by 隋冬阳 on 2023/8/31.
//

import UIKit

class InstrumentCell: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @objc var image: String? {
        didSet {
            guard let imageName = image else {
                UIView.animate {
                    self.imageView?.alpha = 0
                }
                return
            }
            var image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
            if image == nil {
                image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            }
            imageView.alpha = 0;
            imageView.image = image
            UIView.animate {
                self.imageView.alpha = 1;
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.tintColor = UIColor(hexString: "#333333")
        backgroundColor = UIColor(hexString: "#f7f7f7")
    }
}
