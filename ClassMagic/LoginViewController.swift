//
//  LoginViewController.swift
//  ClassMagic
//
//  Created by Ishank Tandon on 10/17/15.
//  Copyright © 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let login : FBSDKLoginButton = FBSDKLoginButton()
        
        login.center = self.view.center
        self.view.addSubview(login)
        
        login.addTarget(self, action: "loginButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
    }
    
    func loginButtonClicked() {
//        let navigationController = self.window!.rootViewController as! UINavigationController
//        let controller = navigationController.topViewController as! ClassMagicTableViewController
//        controller.managedObjectContext = self.managedObjectContext
    
        let logged : FBSDKLoginManager = FBSDKLoginManager()
        logged.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            if (error != nil) {
                print("couldn't login")
            } else if result.isCancelled {
                print("Canceled")
            } else {
                let temp = ClassMagicTableViewController()
                self.presentViewController(temp, animated: true, completion: nil)
            }
        }
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
