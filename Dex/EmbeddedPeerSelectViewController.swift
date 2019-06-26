//
//  EmbeddedPeerSelectViewController.swift
//  Dex
//
//  Created by Felipe Campos on 1/28/18.
//  Copyright © 2018 Orange Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class EmbeddedPeerSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PeerSelectDelegate {
    
    // MARK: Properties
    
    @IBOutlet var tableView: UITableView!
    var users: [DexUser] = []
    var ids: [MCPeerID] = []
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        for i in 0..<ids.count {
            // (tableView.cellForRow(at: IndexPath(i)) as! PeerSelectTableViewCell).delegate = self
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! PeerSelectTableViewCell
            cell.delegate = self
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Protocols
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! PeerSelectTableViewCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        
        cell.displayName.text = users[indexPath.row].name()
        cell.profileImage.image = users[indexPath.row].primaryCard().profilePicture()
        cell.peerID = ids[indexPath.row]
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height / 2
        
        return cell
    }
    
    // MARK: Protocols
    
    func selected(id: MCPeerID) {
        //
    }
    
    func deselected(id: MCPeerID) {
        //
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
