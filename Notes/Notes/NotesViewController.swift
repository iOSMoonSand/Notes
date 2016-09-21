//
//  NotesViewController.swift
//  Notes
//
//  Created by Alexis Schreier on 09/19/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit
import CoreData

// MARK:
// MARK: - NotesViewController Class
// MARK:
class NotesViewController: UIViewController {
    // MARK:
    // MARK: - Properties
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    var notesArray = [NSManagedObject]()
    var newNoteTitle: String?
    var newNoteText: String?
    var newNoteDate: String?
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
    }
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NotesToDetailNote" {
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            let note = self.notesArray[selectedIndexPath.row]
            guard let destinationVC = segue.destinationViewController as? DetailNoteViewController else { return }
            destinationVC.delegate = self
            destinationVC.noteTitle = note.valueForKey("noteTitle") as? String
            destinationVC.noteText = note.valueForKey("noteText") as? String
            destinationVC.tableViewIndex = selectedIndexPath.row
        }
    }
    // MARK:
    // MARK: - Search Button Action
    // MARK:
    
//search IBAciton here
    
    // MARK:
    // MARK: - AddNoteViewController Unwind Segue Methods
    // MARK:
    @IBAction func didTapDoneAddNote(segue: UIStoryboardSegue) {
        guard let
            title = self.newNoteTitle,
            text = self.newNoteText
        else { return }
        
        let date = NSDate()
        
        self.saveNoteWith(title, text: text, date: date)
        self.tableView.reloadData()
    }
    
    func saveNoteWith(title: String, text: String, date: NSDate) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Note",
                                                        inManagedObjectContext:managedContext)
        let note = NSManagedObject(entity: entity!,
                                   insertIntoManagedObjectContext: managedContext)
        note.setValue(title, forKey: "noteTitle")
        note.setValue(text, forKey: "noteText")
        note.setValue(date, forKey: "dateCreated")
        do {
            try managedContext.save()
            self.notesArray.append(note)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func didTapCancelAddNote(segue: UIStoryboardSegue) {
        
    }
    // MARK:
    // MARK: - DetailNoteViewController Unwind Segue Methods
    // MARK:
    @IBAction func didTapBackDetailNote(segue: UIStoryboardSegue) {
        
    }
}
// MARK:
// MARK: - UITableViewDelegate & UITableViewDataSource Protocols
// MARK:
extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK:
    // MARK: - UITableViewDelegate & UITableViewDataSource Methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! NoteCell
        let note = self.notesArray[indexPath.row]
        cell.titleLabel.text = note.valueForKey("noteTitle") as? String
        cell.previewTextLabel.text = note.valueForKey("noteText") as? String
        guard let dateCreated = note.valueForKey("dateCreated") as? NSDate else { return UITableViewCell() }
        let date: String = {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            let formattedDate = formatter.stringFromDate(dateCreated)
            return formattedDate
        }()
        cell.dateCreatedLabel.text = date
        return cell
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let note = self.notesArray[indexPath.row]
            managedContext.deleteObject(note)
            self.notesArray.removeAtIndex(indexPath.row)
            do {
                try managedContext.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("NotesToDetailNote", sender: self)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
// MARK:
// MARK: - DetailNoteViewControllerDelegate Protocol
// MARK:
extension NotesViewController: DetailNoteViewControllerDelegate {
    // MARK:
    // MARK: - DetailNoteViewControllerDelegate Methods
    // MARK:
    func updateNoteWith(title: String, text: String, index: Int) {
        let note = self.notesArray[index]
        let date = NSDate()
        note.setValue(title, forKey: "noteTitle")
        note.setValue(text, forKey: "noteText")
        note.setValue(date, forKey: "dateCreated")
        do {
            try note.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
        self.tableView.reloadData()
    }
}








