//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by chenjs on 15/3/24.
//  Copyright (c) 2015年 TOMMY. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate
{
    var waypointToEdit: EditableWaypoint? {
        didSet {
            name = waypointToEdit?.name
            info = waypointToEdit?.info
            updateUI()
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }
    
    private var name: String?
    private var info: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Waypoint"

        updateUI()
        nameTextField?.becomeFirstResponder()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        if let waypoint = waypointToEdit {
            waypointToEdit?.name = name
            waypointToEdit?.info = info
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: queue) { (notification) -> Void in
            if let waypoint = self.waypointToEdit {
                self.name = self.nameTextField.text
            }
        }
        itfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField, queue: queue) { (notification) -> Void in
            if let waypoint = self.waypointToEdit {
                self.info = self.infoTextField.text
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        nameTextField?.resignFirstResponder()
        infoTextField.resignFirstResponder()
        
        if let observer = ntfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = itfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    private func updateUI() {
        nameTextField?.text = name
        infoTextField?.text = info
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
