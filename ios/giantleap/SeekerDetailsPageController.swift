//
//  SeekerDetailsPage.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class SeekerDetailsPageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var seekerId: String?
    var seeker: Seeker?
    var isOwner : Bool = false
    var toPayAmount : Int?
    
    @IBOutlet weak var barGraphView: UIView!
    @IBOutlet weak var payTabView: UIView!
    @IBOutlet weak var ownerAccountDetailsView: UIView!
    
    @IBOutlet weak var requirementTable: UITableView!
    
    @IBOutlet weak var descriptionTextField: UILabel!
    

    @IBOutlet weak var emailTextField: UILabel!
    
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var accountAmountLabel: UILabel!
    var hasWithDrawn: Bool = false
    
    override func viewDidLoad() {
        print("view did load")
        if (isOwner && seekerId == nil) {
            seekerId = seeker!.id!
        }
        getSeekerDetails();
        playWithLabels()
        requirementTable.delegate = self
        requirementTable.dataSource = self
    }
    

    @IBAction func selectPayTab(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0 :
            toPayAmount = 1;
        case 1:
            toPayAmount = 2;
        default:
            toPayAmount = 5;
        }
        
        let paymentObj = Payment.getFromUserDefault()
        if paymentObj == nil {
            performSegueWithIdentifier("registerPayCard", sender: self)
        } else {
            paymentObj!.transaction(seeker!, money: toPayAmount!, callHandler: afterPayment);
        }
        
        
    }
    func playWithLabels() {
        print("playing with labels")
        if (isOwner) {
            ownerAccountDetailsView.hidden = false
            payTabView.hidden = true

        } else {
            payTabView.hidden = false

            ownerAccountDetailsView.hidden = true
        }
        print("playes with labels")
    }
    func getSeekerDetails() {
        print("getSeekerDetails")
        print(seekerId)
        Seeker.fetchById(seekerId!, handler: seekerDetailHandler)
    }
    

    
    func afterPayment(response: String) {
        var message : String?
        if (response == "Success") {
            message = "Successfully sent"
        } else {
            message = "Error in sending"
        }
        let alertController = UIAlertController(title: "Required", message:
            message!, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "registerPayCard") {
            let vc = segue.destinationViewController as! PayDetailsViewController
            vc.moneyToPay = toPayAmount
            vc.seeker = seeker
        } else if(segue.identifier == "withDraw") {
            print("trying to withdraw")
            let vc = segue.destinationViewController as! withDrawViewController
            vc.seeker = seeker
            vc.partAmount = getTodaysRequirement()
            vc.totalAmout = seeker!.accountMoney! ?? 0
            vc.prev = self
        }
    }
    

    func seekerDetailHandler(seeker: Seeker) {
        self.seeker = seeker
        nameTextField.text = seeker.name!
        emailTextField.text = seeker.id!
        descriptionTextField.text = seeker.description
        print(isOwner)
        if (isOwner) {
            let todayReq = getTodaysRequirement()
            print("todayReg\(todayReq)")
            createBargraph(todayReq, partCount:  seeker.accountMoney! ?? 0)
            print("createBarGraph")
            accountAmountLabel.text = "You have $\(seeker.accountMoney! ?? 0)"
        }

        
        requirementTable.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("7")
        if (seeker?.requirements != nil) {
            return seeker!.requirements!.count
        } else {
            print("damn")
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("seekerCell") as! SeekerCell
        var currReq = seeker!.requirements![indexPath.row]
        cell.reqAmountLabel.text = currReq["amount"]!
        cell.reqReasonLabel.text = currReq["reason"]!
        cell.reqRecurrDaily.text = currReq["recurring"]!
        return cell
    }

    @IBAction func refreshContent(sender: UIButton) {
        getSeekerDetails();
    }
    
    @IBAction func logOut(sender: UIButton) {
        if (isOwner) {
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "seekerId")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "paymentDetails")
        }
        performSegueWithIdentifier("detailToLanding", sender: self)
    }
    

    func getTodaysRequirement() -> Int{
        var todayTotal : Int = 0;
        if (seeker!.requirements != nil) {
            for (var i = 0 ; i < seeker!.requirements!.count; i++) {
                print("i  -> \(i)")
                print(seeker!.requirements![i]["recurring"])
                if (seeker!.requirements![i]["recurring"]! == "Daily") {
                    todayTotal = todayTotal + Int(seeker!.requirements![i]["amount"]!)!
                }
            }
        }
        return todayTotal
    }
    
    
    func createWithDrawButton() {
        let withdrawBtn = UIButton()
        withdrawBtn.backgroundColor = UIColor.blueColor()
        withdrawBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        withdrawBtn.setTitle("WithDraw Money", forState: UIControlState.Normal)
        withdrawBtn.addTarget(self, action: "withDrawAction:", forControlEvents: UIControlEvents.TouchUpInside)
        withdrawBtn.frame.size.height = 40.0
        withdrawBtn.frame.size.width = 150.0
        barGraphView.addSubview(withdrawBtn)
        
        let topPartConstraint = NSLayoutConstraint(item: withdrawBtn, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let leadingPartContraint = NSLayoutConstraint(item: withdrawBtn, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10)
        self.view.addConstraints([topPartConstraint, leadingPartContraint])
        

    }
    
    func withDrawAction(sender:UIButton!) {
        print("withdraw action");
        performSegueWithIdentifier("withDraw", sender: self)
    }
    
    func createBargraph(totalCount: Int, partCount: Int) {
        
        for sview in barGraphView.subviews {
            sview.removeFromSuperview()
        }
        if (partCount >= totalCount) {
            createWithDrawButton();
            return
        }
        let containerView = UIView()
        containerView.backgroundColor = UIColor.redColor()
        let partView = UIView()
        partView.backgroundColor = UIColor.greenColor()
        containerView.frame.size.height = 40.0
        partView.frame.size.height = 40.0
        containerView.frame.size.width = self.view.layer.frame.size.height
        var percent : CGFloat?
        if (totalCount != 0 ) {
            print("calculating percent")
            percent = CGFloat(Float(partCount) / Float(totalCount))
            print(percent)
        } else {
            percent = 0;
        }
        partView.frame.size.width = self.view.layer.frame.size.width * percent!
        
        


        
        barGraphView.addSubview(containerView)
        barGraphView.addSubview(partView)
        
        let topContainerConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let leadingContainerContraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10)
        self.view.addConstraints([topContainerConstraint, leadingContainerContraint])
        
        let topPartConstraint = NSLayoutConstraint(item: partView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let leadingPartContraint = NSLayoutConstraint(item: partView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10)
        self.view.addConstraints([topPartConstraint, leadingPartContraint])


        let label = UILabel()
        label.frame.size.width = self.view.layer.frame.size.width
        label.frame.size.height = 40
        label.textColor = UIColor.whiteColor()
        barGraphView.addSubview(label)
        let topLabelConstraint = NSLayoutConstraint(item: partView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let leadingLabelContraint = NSLayoutConstraint(item: partView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: barGraphView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 40)
        self.view.addConstraints([topLabelConstraint, leadingLabelContraint])
        if (hasWithDrawn) {
            label.text = "You have withdrawn for today"
        } else {
        
            label.text = "Earned: $\(partCount) out of Daily Target : \(totalCount)"
        }
    }
    
}


class SeekerCell : UITableViewCell {
    @IBOutlet weak var reqAmountLabel: UILabel!
    
    @IBOutlet weak var reqRecurrDaily: UILabel!
    @IBOutlet weak var reqReasonLabel: UILabel!
}
