//
//  ShareTableTableViewController.swift
//  ClassMagic
//
//  Created by Ishank Tandon on 10/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import UIKit
import MessageUI

class ShareTableTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var shareNavBar: UINavigationBar!
    
    var image : UIImage?
    let classmateEntityName = "Classmate"
    let shareCellIdentifier = "ShareCell"
    let noShareCellIdentifier = "emptyShareCell"
    var managedObjectContext : NSManagedObjectContext?
    var classmatesEmails : NSMutableArray = NSMutableArray()
    var classmatesNumbers : NSMutableArray = NSMutableArray()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "goToMailAction")
        
    }
    
    func goToMailAction() {
        let actionSheet = UIAlertController(title: "Sharing", message: "", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let emailAction = UIAlertAction(title: "Send as Email", style: .Default) { (action) -> Void in
            let mailComposeViewController = self.configuredMailComposeViewController(self.classmatesEmails)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendEmailErrorAlert()
            }

        }
        let messageAction = UIAlertAction(title: "Send as Text Message", style: .Default) { (action) -> Void in
            let messageComposeViewController = self.configuredMessageComposeViewController()
            if MFMessageComposeViewController.canSendAttachments() {
                self.presentViewController(messageComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMessageErrorAlert()
            }
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(emailAction)
        actionSheet.addAction(messageAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeViewController = MFMessageComposeViewController()
        messageComposeViewController.messageComposeDelegate = self
        
        messageComposeViewController.recipients = classmatesNumbers as NSArray as? [String]
        messageComposeViewController.body = "Sending a ClassMagic image!"
        
        let imageAsData = UIImageJPEGRepresentation(self.image!, 0.5)
        messageComposeViewController.addAttachmentData(imageAsData!, typeIdentifier: "image/jpeg", filename: "ClassMagicPhoto.jpeg")
        
        return messageComposeViewController
    }
    
    
    
    func configuredMailComposeViewController(emails : NSMutableArray) -> MFMailComposeViewController {
        let mailComposerViewController = MFMailComposeViewController()
        mailComposerViewController.mailComposeDelegate = self
        

        mailComposerViewController.setToRecipients(emails as NSArray as? [String])
        mailComposerViewController.setSubject("Sharing a ClassMagic image")
        mailComposerViewController.setMessageBody("Here you go. Have a ClassMagic Image", isHTML: false)
        
        let imageAsData = UIImageJPEGRepresentation(self.image!, 0.5)
        mailComposerViewController.addAttachmentData(imageAsData!, mimeType: "image/jpeg", fileName: "ClassMagicPhoto.jpeg")
        
        return mailComposerViewController
    }
    
    func showSendEmailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Error", message: "Could not send email", delegate: self, cancelButtonTitle: "Ok")
    }
    
    func showSendMessageErrorAlert() {
        let sendMessageErrorAlert = UIAlertView(title: "Error", message: "Could not send message", delegate: self, cancelButtonTitle: "Ok")
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source
       
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(classmateCount,1)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let classmate = getClassmateAtIndexPath(indexPath)
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.classmatesEmails.addObject(classmate.email)
            self.classmatesNumbers.addObject(classmate.phone)
            print("NUMERBS::::::: \(self.classmatesNumbers)")
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            self.classmatesEmails.removeObject(classmate.email)
            self.classmatesNumbers.removeObject(classmate.phone)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if classmateCount == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(noShareCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        } else{
            cell = tableView.dequeueReusableCellWithIdentifier(shareCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
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
       
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
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
