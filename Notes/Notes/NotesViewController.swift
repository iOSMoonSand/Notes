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
final class NotesViewController: UIViewController {
    // MARK:
    // MARK: - Properties
    // MARK:
    @IBOutlet weak var tableView: UITableView!
    var notesArray = [NSManagedObject]()
    var filteredNotes = [NSManagedObject]()
    var newNoteTitle: String?
    var newNoteText: String?
    var newNoteDate: String?
    
    private lazy var searchController: UISearchController = {
       let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self
        return searchController
    }()
    
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        searchController.searchResultsUpdater = self
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadAllNotes()
    }
    
    private func reloadAllNotes() {
        let managedContext = DataManager.sharedInstance.managedObjectContext
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
            searchController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    // MARK:
    // MARK: - Search Button Action
    // MARK:
    
    @IBAction func presentSearchBar(sender: UIBarButtonItem) {
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
    }
    private var fetchRequest: NSFetchRequest = {
        let tempFetchRequest = NSFetchRequest(entityName: "Note")
        return tempFetchRequest
    }()
    
    private func searchBarFetchRequest(searchText: String) {
        let managedContext = DataManager.sharedInstance.managedObjectContext
        
        let predicate1: NSPredicate = NSPredicate(format: "noteTitle CONTAINS[cd] %@", argumentArray: [searchText])
        let predicate2: NSPredicate = NSPredicate(format: "noteText CONTAINS[cd] %@", argumentArray: [searchText])
        let predicate: NSPredicate  = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1,predicate2])
        
        fetchRequest.predicate = predicate
        do {
            self.notesArray = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError  {
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
        
        let date = NSDate()
        
        self.saveNoteWith(title, text: text, date: date)
        self.tableView.reloadData()
    }
    
    private func saveNoteWith(title: String, text: String, date: NSDate) {
        let managedContext = DataManager.sharedInstance.managedObjectContext
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
    
    @IBAction private func didTapCancelAddNote(segue: UIStoryboardSegue) {
        
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
            let managedContext = DataManager.sharedInstance.managedObjectContext
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


extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchBarFetchRequest(text)
        self.tableView.reloadData()
    }

}

extension NotesViewController: UISearchControllerDelegate {
    func didDismissSearchController(searchController: UISearchController) {
        reloadAllNotes()
        self.tableView.reloadData()
    }
}






