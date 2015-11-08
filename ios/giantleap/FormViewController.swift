//
//  FormViewController.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class FormViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var requirementTable: UITableView!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    var currentSeeker : Seeker?
    override func viewDidLoad() {
        currentSeeker = Seeker()
        requirementTable.dataSource = self
        requirementTable.delegate = self
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier!) {
        case "addRequirement":
            let vc = segue.destinationViewController as! RequirementViewController
            vc.prev = self
            vc.currentSeeker = currentSeeker
        case "saveForm":
            let vc = segue.destinationViewController as! SeekerQRViewController
            saveButtonClicked();
            vc.currentSeeker = currentSeeker
        default:
            print("invalid segue")
        }
        
    }
    
    func showRequiredFieldError() {
        let alertController = UIAlertController(title: "Required", message:
            "Name and Email are required", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func saveButtonClicked() {
        if (nameTextField.text == "" || emailTextField.text == "") {
            showRequiredFieldError();
            return;
        }
        currentSeeker!.name = nameTextField.text
        currentSeeker!.description = descriptionTextField.text
        currentSeeker!.id = emailTextField.text
        currentSeeker!.save()
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentSeeker?.requirements != nil) {
            return currentSeeker!.requirements!.count
        } else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("formReqCell") as! formTableViewCell
        var currReq = currentSeeker!.requirements![indexPath.row]
        cell.reqAmountLabel.text = currReq["amount"]!
        cell.reqReasonLabel.text = currReq["reason"]!
        cell.reqRecurringLabel.text = currReq["recurring"]!
        return cell
    }
}

class formTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reqReasonLabel: UILabel!

    @IBOutlet weak var reqRecurringLabel: UILabel!
    @IBOutlet weak var reqAmountLabel: UILabel!
}
