//
//  withDrawViewController.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/8/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit
import Alamofire

class withDrawViewController: UIViewController {
    var seeker: Seeker?
    var totalAmout: Int?
    var partAmount: Int?
    var prev : SeekerDetailsPageController?
    
    @IBOutlet weak var merchantLabel: UITextField!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var withDrawLabel: UILabel!
    override func viewDidLoad() {
        leftLabel.text = "Amount left after withdrawal: $\(totalAmout! - partAmount!)"
        withDrawLabel.text = "Amount allowed for withdrawal: $\(partAmount!)"
    }

    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    @IBAction func withDraw(sender: UIButton) {
        
        let parameters  = [
            "toSubscriberId": seeker!.id!,
            "toSubscriberAlias" : seeker!.name!,
            "amount": "\(partAmount!)",
            "merchant": merchantLabel!.text!
        ]

        Alamofire.request(.POST, "http://\(Constants.serverIp):\(Constants.serverPort)/v1/money/putToHomelessAcount", parameters: parameters ).responseJSON { response in
            switch response.result {
            case .Success( _):
                self.callHandler("Successfuly Withdrawn")
            case .Failure( _):
                self.callHandler("Error while withdrawing")
            }
            
        }
    }
    
    func onComplete(act :UIAlertAction) {
        prev?.getSeekerDetails()
        prev?.hasWithDrawn = true
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func callHandler(response: String)  {
        let alertController = UIAlertController(title: "Message", message: response, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: onComplete))
        self.presentViewController(alertController, animated: true, completion: nil)

    }
}
