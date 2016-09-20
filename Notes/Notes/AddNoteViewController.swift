//
//  AddNoteViewController.swift
//  Notes
//
//  Created by Alexis Schreier on 09/19/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

// MARK:
// MARK: - AddNoteViewController Class
// MARK:
class AddNoteViewController: UIViewController {
    // MARK:
    // MARK: - Properties
    // MARK:
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("tap fired: Done")
        guard let
            title = self.titleTextField.text,
            text = self.noteTextView.text,
            destinationVC = segue.destinationViewController as? NotesViewController
        else { return }
        destinationVC.newNoteTitle = title
        destinationVC.newNoteText = text
    }
}










