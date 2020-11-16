//
//  SlideViewButton.swift
//  Petri
//
//  Created by Karolczyk, Maciej on 02/11/2020.
//

import UIKit

class SlideViewButton: UIButton {
    
    @IBOutlet var contentView: UIView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SlideViewButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
