//
//  FullPhotoViewController.swift
//  ClassMagic
//
//  Created by Ishank Tandon on 10/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import MessageUI
import UIKit
import Photos

class FullPhotoViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    var assetCollection :PHAssetCollection!
    var photosAsset: PHFetchResult!
    var index : Int!
    var classEntity : ClassMagicEntity?
    var classmatesList : [Classmate]!
    var managedObjectContext : NSManagedObjectContext?
    let classmateEntityName = "Classmate"
    var notesArray : [String]?
    
    let shareSegueIdentifier = "shareSegue"
  
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func pressedNotesBtn(sender: AnyObject) {
        let alert = UIAlertController(title: "Edit your note", message: self.notesArray![self.index], preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler( { (textField: UITextField) in
            textField.placeholder = "Add a note"
            textField.text = self.notesArray![self.index]
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {(alertNo) in
            let notesTextField = alert.textFields![0] as UITextField
            self.notesArray![self.index] = notesTextField.text!
            self.classEntity?.notes = (self.notesArray!).joinWithSeparator(",~!")
            self.saveManagedObjectContext()
        }))

        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveManagedObjectContext() {
        var error: NSError? = nil
        do {
            try managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("Unresolved Core Data error \(error?.userInfo)")
            abort()
        }
    }
    
    
    @IBAction func pressedTrashBtn(sender: AnyObject) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default,
            handler: {(alertAction)in
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    //Delete Photo
                    let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                    request!.removeAssets([self.photosAsset[self.index]])
                    },
                    completionHandler: {(success, error)in
                        NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        if(success){
                            self.notesArray?.removeAtIndex(self.index)
                            self.classEntity?.notes = (self.notesArray!).joinWithSeparator(",~!")
                            self.saveManagedObjectContext()
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                                if(self.photosAsset.count == 0){
                                    print("No Images Left!!")
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }else{
                                    if(self.index >= self.photosAsset.count){
                                        self.index = self.photosAsset.count - 1
                                    }
                                    self.displayPhoto()
                                }
                                
                            })
                        }else{
                            print("Error: \(error)")
                        }
                })
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction)in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        self.navigationController?.navigationBarHidden=false
    }
    
    override func viewWillAppear(animated: Bool) {
       // self.navigationController?.hidesBarsOnTap = true
        
       
    }
    
    func displayPhoto(){
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let targetSize = CGSizeMake(screenSize.width, screenSize.height)
        
        let imageManager = PHImageManager.defaultManager()
        _ = imageManager.requestImageForAsset(self.photosAsset[self.index] as! PHAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFit, options: nil, resultHandler: { (result, info) -> Void in
            self.imgView.image = result
//            self.navigationController?.hidesBarsOnTap = true
        
        })
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.minimumZoomScale=1;
        self.scrollView.maximumZoomScale=6.0;
        self.scrollView.contentSize=self.imgView.frame.size;
        self.scrollView.delegate=self;
        self.displayPhoto()
        let fetchRequest = NSFetchRequest(entityName: classmateEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            try classmatesList = managedObjectContext?.executeFetchRequest(fetchRequest) as! [Classmate]
        } catch let error as NSError {
            print("Unresolved Core Data error \(error.userInfo)")
            abort()
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == shareSegueIdentifier) {
            (segue.destinationViewController as! ShareTableTableViewController).managedObjectContext = self.managedObjectContext
            (segue.destinationViewController as! ShareTableTableViewController).image = self.imgView.image
        }
    }

}
