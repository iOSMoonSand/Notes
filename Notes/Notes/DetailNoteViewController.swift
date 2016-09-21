//
//  DetailNoteViewController.swift
//  Notes
//
//  Created by Alexis Schreier on 09/20/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

import UIKit

// MARK:
// MARK: - DetailNoteViewControllerDelegate Class Protocol
// MARK:
protocol DetailNoteViewControllerDelegate: class {
    // MARK:
    // MARK: - DetailNoteViewControllerDelegate Methods
    // MARK:
    func updateNoteWith(title: String, text: String, index: Int)
}
// MARK:
// MARK: - DetailNoteViewController Class
// MARK:
class DetailNoteViewController: UIViewController {
    // MARK:
    // MARK: - Properties
    // MARK:
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    weak var delegate: DetailNoteViewControllerDelegate?
    var noteTitle: String?
    var noteText: String?
    var tableViewIndex: Int?
    // MARK:
    // MARK: - UIViewController Methods
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noteTitleTextField.text = self.noteTitle
        self.noteTextView.text = self.noteText
        self.noteTitleTextField.delegate = self
        self.noteTextView.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let
            title = self.noteTitleTextField.text,
            text = self.noteTextView.text,
            index = self.tableViewIndex
        else { return }
        delegate?.updateNoteWith(title, text: text, index: index)
    }
    // MARK:
    // MARK: - Share Button Action
    // MARK:
    @IBAction func didTapShareDetailNote(sender: UIBarButtonItem) {
        presentActivityVC()
    }
    
    func presentActivityVC() {
        guard let
            noteTitle = self.noteTitleTextField.text,
            noteText = self.noteTextView.text
        else { return }
        var noteToShare = [AnyObject]()
        noteToShare.append(noteTitle)
        noteToShare.append(noteText)
        let activityVC = UIActivityViewController(activityItems: noteToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
}
// MARK:
// MARK: - UITextFieldDelegate Protocol
// MARK:
extension DetailNoteViewController: UITextFieldDelegate {
    // MARK:
    // MARK: - UITextFieldDelegate Methods
    // MARK:
    func textFieldDidBeginEditing(textField: UITextField) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(stopEditingTextField))
    }
    
    func stopEditingTextField() {
        self.noteTitleTextField.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: nil)
    }
}
// MARK:
// MARK: - UITextViewDelegate Protocol
// MARK:
extension DetailNoteViewController: UITextViewDelegate {
    // MARK:
    // MARK: - UITextViewDelegate Methods
    // MARK:
    func textViewDidBeginEditing(textView: UITextView) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(stopEditingTextView))
    }
    
    func stopEditingTextView() {
        self.noteTextView.resignFirstResponder()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(presentActivityVC))
    }
}





