//
//  NotesViewController.swift
//  Notes
//
//  Created by Alexis Schreier on 09/19/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var notesArray = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Note")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            notesArray = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func didTapAddNote(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Note",
                                      message: "Add a new note",
                                      preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        
                                        let textField = alert.textFields!.first
                                        self.saveNoteWith(textField!.text!)
                                        self.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }
    
    func saveNoteWith(text: String) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Note",
                                                        inManagedObjectContext:managedContext)
        let note = NSManagedObject(entity: entity!,
                                     insertIntoManagedObjectContext: managedContext)
        note.setValue(text, forKey: "noteText")
        do {
            try managedContext.save()
            self.notesArray.append(note)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        let note = self.notesArray[indexPath.row]
        cell!.textLabel!.text = note.valueForKey("noteText") as? String
        return cell!
    }
}
