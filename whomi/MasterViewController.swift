//
//  MasterViewController.swift
//  whomi
//
//  Created by Tobias Robert Brysiewicz on 12/16/15.
//  Copyright © 2015 Tobias Brysiewicz. All rights reserved.
//

import UIKit
import Parse

class MasterViewController: ViewController, UITableViewDataSource, UITableViewDelegate {

    // -----------------------
    // TABLE VIEW CODE
    // -----------------------
    
    var messages = [String]()
    var username = [String]()
    var imageFiles = [PFFile]()
    var user = PFUser.currentUser()
    
    @IBOutlet weak var myFeedTableView: UITableView!
    
    // -----------------------
    
    
    // -----------------------
    // LOGOUT CODE
    // -----------------------
    var currentUser = PFUser.currentUser()!.username
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
            currentUser = PFUser.currentUser()!.username
        }
    }
    
    // -----------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        
        var query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let user = objects {
                
                self.messages.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                
            }
            
            var getMyPosts = PFQuery(className: "Post")
            getMyPosts.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
            getMyPosts.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if let objects = objects {
                    for object in objects {
                        
                        self.messages.append(object["message"] as! String)
                        self.imageFiles.append(object["imageFile"] as! PFFile)
                        self.username.append(PFUser.currentUser()!.username!)
                        
                        self.myFeedTableView.reloadData()
                        
                    }
                    
                }
                
            }
            
        })
        
        
        myFeedTableView.delegate = self
        myFeedTableView.dataSource = self
        myFeedTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // -----------------------
    // TABLE VIEW CODE
    // -----------------------
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! cell
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
            
            if let downloadedImage = UIImage(data: data!) {
                
                myCell.myPostedImage.image = downloadedImage
                
            }
            
        }
        
        myCell.myUsername.text = username[indexPath.row]
        myCell.myMessage.text = messages[indexPath.row]
        
        return myCell
    }
    
    // -----------------------
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
