//
//  ClassMagicDetailViewController.swift
//  ClassMagic
//
//  Created by Ishank Tandon on 10/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import Photos

class ClassMagicDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let classMagicEntityName = "ClassMagicEntity"
    let photoCellIdentifier = "PhotoCell"
    let showFullPhotoSegueIdentifier = "ShowFullViewIdentifier"
    let showClassMatesIdentifier = "ShowClassMates"
    
    var classEntity : ClassMagicEntity?
    var albumName =  "Class Magic "
    var assetCollection: PHAssetCollection?
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    var albumFound = false
    var notesArray : [String]? = [String]()
    
    @IBOutlet weak var className: UINavigationItem!
    
    var managedObjectContext : NSManagedObjectContext?
    
    @IBAction func cameraBtn(sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
            
        }else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
 
    @IBAction func importBtn(sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.className.title = self.classEntity?.name
        self.albumName += self.className.title!
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let _:AnyObject = collection.firstObject{
           
            self.albumFound = true
            self.assetCollection = collection.firstObject as? PHAssetCollection
            self.notesArray = self.classEntity?.notes.componentsSeparatedByString(",~!")
        }else{
            var albumPlaceholder:PHObjectPlaceholder!
            self.notesArray = [String]()
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                }, completionHandler: { (success, error) -> Void in
                    self.albumFound = success ? true : false
                    if success {
                        let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collection.firstObject as? PHAssetCollection
                    }
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosAsset != nil ? self.photosAsset.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CollectionThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! CollectionThumbnail
        
        let asset: PHAsset = self.photosAsset[indexPath.item] as! PHAsset
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.assetThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: {(result, info) in
            cell.setThumbnailImage(result!)
        })
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        self.assetThumbnailSize = CGSizeMake(cellSize.width, cellSize.height)
        
        self.navigationController?.hidesBarsOnTap = false
        
        self.helper()
        self.collectionView.reloadData()
        self.notesArray = self.classEntity?.notes.componentsSeparatedByString(",~!")
    }
    
    func helper() {
        if self.assetCollection != nil {
            self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection!, options: nil)
            print("Got here: \(self.photosAsset)")
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier! == showFullPhotoSegueIdentifier) {
            let controller : FullPhotoViewController = segue.destinationViewController as! FullPhotoViewController
            let indexPath : NSIndexPath = self.collectionView.indexPathForCell(sender as! UICollectionViewCell)!
            controller.index = indexPath.item
            controller.photosAsset = self.photosAsset
            controller.assetCollection = self.assetCollection
            controller.managedObjectContext = self.managedObjectContext
            controller.classEntity = self.classEntity
            controller.notesArray = self.notesArray
        }
        if(segue.identifier! == showClassMatesIdentifier){
            let controller : ClassMatesTableViewController = segue.destinationViewController as! ClassMatesTableViewController
            controller.managedObjectContext = self.managedObjectContext
            //controller.classmagicObject = self.classEntity
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                print("got to picker::::")
                self.helper()
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection!, assets: self.photosAsset)
                albumChangeRequest!.addAssets([assetPlaceholder!])
      
                }, completionHandler: {(success, error)in
                    dispatch_async(dispatch_get_main_queue(), {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        if success {
                            self.notesArray?.append("")
                            self.classEntity?.notes = (self.notesArray!).joinWithSeparator(",~!")
                            self.saveManagedObjectContext()
                        }
                        picker.dismissViewControllerAnimated(true, completion: nil)
                    })
            })
        })
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
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
}
