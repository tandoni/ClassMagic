//
//  ClassMagicTableViewController.swift
//  ClassMagic
//
//  Created by Ishank Tandon on 10/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import CoreData

class ClassMagicTableViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    var managedObjectContext : NSManagedObjectContext?
    

    
    let classNameIdentifier = "ClassCell"
    let noClassNameIdentifier = "NoClassCell"
    let classMagicEntityName = "ClassMagicEntity"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    
    var detailViewController : ClassMagicDetailViewController? = nil
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "showAddClass")
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ClassMagicDetailViewController
        }

    }
    
    var classCount : Int{
        return fetchedResultsController.sections![0].numberOfObjects
    }
    
    func getClassAtIndexPath(indexPath: NSIndexPath) -> ClassMagicEntity{
        return fetchedResultsController.objectAtIndexPath(indexPath) as! ClassMagicEntity
    }
    
    func showAddClass(){
        let alertController = UIAlertController(title: "Create a new class", message: "", preferredStyle: .Alert);
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print("You pressed cancel")
        }
        
        let createClassAction = UIAlertAction(title: "Create Class", style: UIAlertActionStyle.Default) { (action) -> Void in
            print("You pressed create Class");
            
            let classTextField = alertController.textFields![0] as UITextField
//            println("class text fied: \(classTextField.text)")
            
            
            let newClass = NSEntityDescription.insertNewObjectForEntityForName(self.classMagicEntityName, inManagedObjectContext: self.managedObjectContext!) as! ClassMagicEntity
            
            newClass.name = classTextField.text
            newClass.notes = ""
            newClass.lastTouchDate = NSDate()
            
            self.saveManagedObjectContext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createClassAction);
        presentViewController(alertController, animated: true, completion: nil);
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(classCount,1)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if classCount == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(noClassNameIdentifier, forIndexPath: indexPath) as UITableViewCell
        } else{
            cell = tableView.dequeueReusableCellWithIdentifier(classNameIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        //configure the cell
        let classEntity = getClassAtIndexPath(indexPath)
        cell.textLabel?.text = classEntity.name
        }
        return cell
    }

    
            // To use for checkMarks
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
//        if cell.accessoryType == UITableViewCellAccessoryType.None {
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryType.None
//        }
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
    
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return classCount > 0
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if classCount == 0 {
            super.setEditing(false, animated: false)
        }
        else {
            super.setEditing(editing, animated: animated)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let classToDelete = getClassAtIndexPath(indexPath)
            managedObjectContext?.deleteObject(classToDelete)
            
            saveManagedObjectContext()
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let classEntity = getClassAtIndexPath(selectedIndexPath)
            (segue.destinationViewController as! ClassMagicDetailViewController).classEntity = classEntity
            (segue.destinationViewController as! ClassMagicDetailViewController).managedObjectContext = managedObjectContext
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest(entityName: classMagicEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastTouchDate", ascending: false)]
        fetchRequest.fetchBatchSize = 20
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "ClassMagicCache")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("Unresolved Core Data error \(error?.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if(self.classCount == 1) {
                self.tableView.reloadData()
            } else {
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
        case .Delete:
            if classCount == 0 {
                tableView.reloadData()
                setEditing(false, animated: true)
            } else {
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
        default:
            return
        }

    }
    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
    
}
