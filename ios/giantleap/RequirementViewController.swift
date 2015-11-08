//
//  RequirementViewController.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class RequirementViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    var currentSeeker : Seeker?
    var prev: FormViewController?
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var reasonTextField: UITextField!
    
    
    @IBOutlet weak var recurringPicker: UIPickerView!
    var pickerData = ["One time", "Daily", "Weekly", "Monthly"]
    var reqRecur : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        recurringPicker.dataSource = self
        recurringPicker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reqRecur = pickerData[row]
    }
    
    @IBAction func cancelView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    @IBAction func save(sender: AnyObject) {
        let amountText = amountTextField.text
        
        if amountText == "" {
            return
        }
        let amount = Int(amountText!)
        let reason = reasonTextField.text
        let recurring = reqRecur
        
        
        currentSeeker?.addRequirements(amount!, reason: reason!, recurring: recurring)
        print("reloading table");
        prev?.requirementTable.reloadData()
        
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
}
