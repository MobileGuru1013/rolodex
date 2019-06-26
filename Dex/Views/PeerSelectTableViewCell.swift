//
//  PeerSelectTableViewCell.swift
//  Dex
//
//  Created by Felipe Campos on 1/27/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol PeerSelectDelegate: class {
    func selected(id: MCPeerID)
    func deselected(id: MCPeerID)
}

class PeerSelectTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet var cellView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var displayName: UILabel!
    @IBOutlet var selectAction: UIButton!
    var picked: Bool = false
    var peerID: MCPeerID!
    
    var delegate: PeerSelectDelegate?
    
    // MARK: Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Methods
    
    func selectPressed(_ sender: UIButton) {
        if picked {
            selectAction.titleLabel?.text = "Deselect"
            displayName.textColor = UIColor.green
            self.delegate?.deselected(id: peerID)
        } else {
            selectAction.titleLabel?.text = "Select"
            displayName.textColor = UIColor.black
            self.delegate?.selected(id: peerID)
        }
    }

}
