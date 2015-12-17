//
//  StartViewController.swift
//  Whomi
//
//  Created by Tobias Robert Brysiewicz on 12/15/15.
//  Copyright © 2015 Tobias Brysiewicz. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4

class StartViewController: UIViewController {
    
    var signupActive = true
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var registerText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @available(iOS 8.0, *)
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            print("Ok")
        })
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @available(iOS 8.0, *)
    @IBAction func signup(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Error", message: "Invalid username or password")
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"
            
            
            if signupActive == true {
                
                var user = PFUser()
                user.username = username.text
                user.password = password.text
                
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        // Signup Successful
                        
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        if let errorString = error!.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Failed Signup", message: errorMessage)
                        
                    }
                })
                
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { ( user, error ) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        
                        // Logged In!
                        
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                        if let errorString = error!.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Failed Login", message: errorMessage)
                    }
                    
                })
            }
            
        }
        
    }
    
    
    @available(iOS 8.0, *)
    @IBAction func loginWithFacebook(sender: AnyObject) {
        
        // ----------------
        // FACEBOOK SIGNUP
        // ----------------
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile","email"], block: { (user:PFUser?, error:NSError?) -> Void in
            
            if(error != nil) {
                //Display an alert message
                var myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated:true, completion:nil);
                
                return
            } else {
                
                let loginWithFacebook = FBSDKLoginButton()
                
                if(FBSDKAccessToken.currentAccessToken() != nil) {
                    var errorMessage = "Please try again later"
                    
                    if self.signupActive == true {
                        
                        var requestParameters = ["fields": "id, first_name"]
                        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
                        userDetails.startWithCompletionHandler({ (connection, result, error) -> Void in
                            
                            if error != nil {
                                return
                            }
                            
                            if result != nil {
                                
                                let userId:String = result["id"] as! String
                                let userFirstName:String? = result["first_name"] as? String
                                
                                var user = PFUser()
                                user.password = String("password")
                                user.objectId = userId
                                
                                // GET FACEBOOK NAME
                                if userFirstName != nil {
                                    user.username = String!(userFirstName)
                                }
                                
                                // GET FACEBOOK PROFILE PICTURE
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                    var userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                                    let profilePictureUrl = NSURL(string: userProfile)
                                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                                    
                                    if profilePictureData != nil {
                                        let profileFileObject = PFFile(data: profilePictureData!)
                                        user.setObject(profileFileObject!, forKey: "profile_picture")
                                    }
                                }
                                
                                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                                    
                                    self.activityIndicator.stopAnimating()
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    
                                    if error == nil {
                                        
                                        // Signup Successful
                                        
                                        self.performSegueWithIdentifier("login", sender: self)
                                        
                                    } else {
                                        if let errorString = error!.userInfo["error"] as? String {
                                            errorMessage = errorString
                                        }
                                        
                                        self.displayAlert("Failed Signup", message: errorMessage)
                                    }
                                })
                            }
                        })
                    } else {
                        
                        // ----------------
                        // FACEBOOK LOGIN 
                        // ----------------
                        
                        var requestParameters = ["fields": "id, first_name"]
                        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
                        userDetails.startWithCompletionHandler({ (connection, result, error) -> Void in
                            
                            if error != nil {
                                return
                            }
                            
                            if result != nil {
                                
                                let userId:String = result["id"] as! String
                                let userFirstName:String? = result["first_name"] as? String
                                
                                var user = PFUser()
                                user.password = String("password")
                                user.objectId = userId
                                
                                // GET FACEBOOK NAME
                                if userFirstName != nil {
                                    user.username = String!(userFirstName)
                                }
                                
                                
                                PFUser.logInWithUsernameInBackground(user.username!, password: user.password!, block: { ( user, error ) -> Void in
                            
                                    self.activityIndicator.stopAnimating()
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                                    if user != nil {
                                
                                        // Logged In!
                                
                                        self.performSegueWithIdentifier("login", sender: self)
                                
                                    } else {
                                        if let errorString = error!.userInfo["error"] as? String {
                                            errorMessage = errorString
                                        }
                                
                                        self.displayAlert("Failed Login", message: errorMessage)
                                    }
                            
                                })
                        
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    @IBAction func login(sender: AnyObject) {
        
        if signupActive == true {
            
            signupButton.setTitle("Log in with Whomi", forState: UIControlState.Normal)
            registerText.text = "Not Registered?"
            loginButton.setTitle("Sign Up", forState: UIControlState.Normal)
            fbLoginButton.setTitle("Log in with Facebook", forState: UIControlState.Normal)
            signupActive = false
            
        } else {
            
            signupButton.setTitle("Sign up with Whomi", forState: UIControlState.Normal)
            registerText.text = "Already Registered?"
            loginButton.setTitle("Login", forState: UIControlState.Normal)
            fbLoginButton.setTitle("Sign up with Facebook", forState: UIControlState.Normal)
            signupActive = true
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signupButton.layer.cornerRadius = 5
        self.loginButton.layer.cornerRadius = 5
        self.fbLoginButton.layer.cornerRadius = 5
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
  
    
/*
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            
            self.performSegueWithIdentifier("login", sender: self)
            
        }
        
    }
*/
    
    


    
}
