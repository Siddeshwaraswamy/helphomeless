//
//  PayDetailsViewController.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class PayDetailsViewController: UIViewController {

    @IBOutlet weak var cardHolderNamerTextField: UITextField!
    
    @IBOutlet weak var expDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    var seeker : Seeker?
    var moneyToPay : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerPaymentDetails(sender: AnyObject) {
        let payment = Payment()
        payment.cardCvv = Int(cvvTextField.text!)
        payment.cardExpDate = expDateTextField.text!
        payment.cardHolderName = cardHolderNamerTextField.text!
        payment.cardNumber = Int(cardNumberTextField.text!)
        payment.zipCode = Int(zipcodeTextField.text!)
        payment.cardEmail = emailTextField.text!
        payment.save()
        
        payment.transaction(seeker!, money: moneyToPay!, callHandler: afterPayment)
        
    }
    
    func afterPayment(response: String) {
        var message : String?
        if (response == "Success") {
            message = "Successfully sent"
        } else {
            message = "Error in sending"
        }
        let alertController = UIAlertController(title: "Message", message:
            message!, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: onSuccess))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func onSuccess(action: UIAlertAction) {
        performSegueWithIdentifier("paymentToSeeker", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! SeekerDetailsPageController
        vc.seekerId = seeker!.id
    }
    
}
