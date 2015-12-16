//
//  PostImageViewController.swift
//  whomi
//
//  Created by Tobias Robert Brysiewicz on 12/16/15.
//  Copyright © 2015 Tobias Brysiewicz. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @available(iOS 8.0, *)
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let tryAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            print("OK")
        })
        
        alert.addAction(tryAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    @IBAction func chooseImage(sender: AnyObject) {

        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageToPost.image = image
        
    }
    
    @available(iOS 8.0, *)
    @IBAction func postImage(sender: AnyObject) {
        
        if message.text != "" && imageToPost.image != UIImage(named: "user-default.png") {
            
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            
            var post = PFObject(className: "Post")
            post["message"] = message.text
            post["userId"] = PFUser.currentUser()!.objectId!
            
            let imageData = UIImageJPEGRepresentation(imageToPost.image!, 0.5)
            
            let imageFile = PFFile(name: "image.png", data: imageData!)
            
            post["imageFile"] = imageFile
            
            post.saveInBackgroundWithBlock { (success, error) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    
                    self.displayAlert("Success!", message: "Your image has been posted.")
                    
                    self.imageToPost.image = UIImage(named: "whoami-2.png")
                    self.message.text = ""
                    self.chooseImageButton.setTitle("Choose Another!", forState: UIControlState.Normal)
                    
                } else {
                    
                    self.displayAlert("Failure", message: "Could not post image")
                    
                }
            }
            
        } else {
            
            self.displayAlert("Required", message: "Image and Message")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postImageButton.layer.cornerRadius = 5

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
