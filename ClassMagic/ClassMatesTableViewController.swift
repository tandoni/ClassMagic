//
//  ClassMatesTableViewController.swift
//  ClassMagic
//
//  Created by Ishank Tandon on 10/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import CoreData

class ClassMatesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let classmateIdentifier = "classmateCell"
    let noClassmateIdentifier = "noClassmateCell"
    let classmateEntityName = "Classmate"
    var managedObjectContext : NSManagedObjectContext?
    
    //var classmagicObject : ClassMagicEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addClassmate")
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func addClassmate(){
        let alertController = UIAlertController(title: "Create a new classmate", message: "", preferredStyle: .Alert);
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "sample@domain"
            textField.keyboardType = UIKeyboardType.EmailAddress
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Phone number: 5555555555"
            textField.keyboardType = UIKeyboardType.PhonePad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            print("You pressed cancel")
        }
        
        let createClassmateAction = UIAlertAction(title: "Create Classmate", style: UIAlertActionStyle.Default) { (action) -> Void in
            print("You pressed create Classmate");
            
            let nameTextField = alertController.textFields![0] as UITextField
            let emailTextField = alertController.textFields![1] as UITextField
            let phoneTextField = alertController.textFields![2] as UITextField
            
            //            println("class text fied: \(classTextField.text)")
            
            
            let newClassmate = NSEntityDescription.insertNewObjectForEntityForName(self.classmateEntityName, inManagedObjectContext: self.managedObjectContext!) as! Classmate
            
            newClassmate.name = nameTextField.text
            newClassmate.email = emailTextField.text
            newClassmate.phone = phoneTextField.text
            self.saveManagedObjectContext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createClassmateAction);
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
        return max(classmateCount,1)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return classmateCount > 0
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if classmateCount == 0 {
            super.setEditing(false, animated: false)
        }
        else {
            super.setEditing(editing, animated: animated)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let classmateToDelete = getClassmateAtIndexPath(indexPath)
            managedObjectContext?.deleteObject(classmateToDelete)
            saveManagedObjectContext()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if classmateCount == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(noClassmateIdentifier, forIndexPath: indexPath) as UITableViewCell
        } else{
            cell = tableView.dequeueReusableCellWithIdentifier(classmateIdentifier, forIndexPath: indexPath) as UITableViewCell
            
            //configure the cell
            let classmate = getClassmateAtIndexPath(indexPath)
            cell.textLabel?.text = classmate.name
            cell.detailTextLabel?.text = classmate.email
        }
        return cell
    }
    
    func getClassmateAtIndexPath(indexPath: NSIndexPath) -> Classmate{
        return fetchedResultsController.objectAtIndexPath(indexPath) as! Classmate
    }

    // MARK: - Table view data source

    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest(entityName: classmateEntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "ClassmateCache")
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
    
    var classmateCount : Int{
        return fetchedResultsController.sections![0].numberOfObjects
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if(self.classmateCount == 1) {
                self.tableView.reloadData()
            } else {
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
        case .Delete:
            if classmateCount == 0 {
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
