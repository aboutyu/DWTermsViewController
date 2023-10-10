//
//  THTermsMenuViewCell.swift
//  idsTrustTestApp
//
//  Created by 유태훈 on 2023/10/06.
//

import UIKit

class THTermsMenuViewCell: UICollectionViewCell {
    lazy private var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .black
        return label
    }()
    
    lazy private var bottomLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = self.selectedColor
        line.isHidden = true
        
        return line
    }()
    
    var index: Int = 0
    var name: String = ""
    var font: UIFont?
    var selectedColor: UIColor?
    var diSelectedColor: UIColor?
    var bottomLineHeight: CGFloat = 1
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reload(_ currentRow: Int) {
        [nameLabel, bottomLine].forEach { self.addSubview($0) }
        self.backgroundColor = .clear
        
        self.nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.bottomLine.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 3).isActive = true
        self.bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        self.bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        self.bottomLine.heightAnchor.constraint(equalToConstant: self.bottomLineHeight).isActive = true
        
        self.nameLabel.text = name
        self.nameLabel.textColor = (index == currentRow ? selectedColor : diSelectedColor)
        self.nameLabel.font = font
        
        self.bottomLine.isHidden = !(index == currentRow)
    }
}
