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
    // MARK:
    // MARK: - AddNoteViewController Unwind Segue Methods
    // MARK:
    @IBAction func didTapDoneAddNote(segue: UIStoryboardSegue) {
        guard let
            title = self.newNoteTitle,
            text = self.newNoteText
        else { return }
        self.saveNoteWith(title, text: text)
        self.tableView.reloadData()
    }
    
    func saveNoteWith(title: String, text: String) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Note",
                                                        inManagedObjectContext:managedContext)
        let note = NSManagedObject(entity: entity!,
                                   insertIntoManagedObjectContext: managedContext)
        note.setValue(title, forKey: "noteTitle")
        note.setValue(text, forKey: "noteText")
        do {
            try managedContext.save()
            self.notesArray.append(note)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func didTapCancelAddNote(segue: UIStoryboardSegue) {
        
    }
}
// MARK:
// MARK: - UITableViewDelegate & UITableViewDataSource Protocols
// MARK:
extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK:
    // MARK: - UITableViewDelegate & UITableViewDataSource Protocol Methods
    // MARK:
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! NoteCell
        let note = self.notesArray[indexPath.row]
        cell.titleLabel.text = note.valueForKey("noteTitle") as? String
        cell.previewTextLabel.text = note.valueForKey("noteText") as? String
        return cell
    }
}









