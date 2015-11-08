//
//  Payment.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import Foundation
import Alamofire


class Payment {
    var cardNumber: Int?
    var cardHolderName: String?
    var cardCvv: Int?
    var cardExpDate: String?
    var zipCode : Int?
    var cardEmail: String?

    
    static func getFromUserDefault() -> Payment? {
        let obj = NSUserDefaults.standardUserDefaults().objectForKey("paymentDetails") as? NSDictionary
        var payment : Payment? = nil
        if (obj != nil) {
            payment = Payment()
            payment!.cardCvv = (obj!["cardCvv"] as! Int)
            payment!.cardExpDate = (obj!["cardExpDate"] as! String)
            payment!.cardHolderName = (obj!["cardHolderName"] as! String)
            payment!.cardNumber = (obj!["cardNumber"] as! Int)
            payment!.zipCode = (obj!["zipCode"] as! Int)
            payment!.cardEmail = (obj!["cardEmail"] as! String)
        }
        return payment;
    }
    
    func save() {
        var paymentDict = [String: AnyObject]()
        paymentDict["cardCvv"] = self.cardCvv
        paymentDict["cardExpDate"] = self.cardExpDate
        paymentDict["cardNumber"] = self.cardNumber
        paymentDict["cardHolderName"] = self.cardHolderName
        paymentDict["zipCode"] = self.zipCode
        paymentDict["cardEmail"] = self.cardEmail
        NSUserDefaults.standardUserDefaults().setObject(paymentDict, forKey: "paymentDetails")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func transaction(seeker : Seeker, money: Int, callHandler : (response : String) -> Void) {
        self.cardEmail = "homeless_ppls_helper@mastercard.com"
        self.cardHolderName = "Homeless help Card"

        let parameters  = [
            "fromSubscriberId": self.cardEmail!,
            "fromSubscriberAlias" : self.cardHolderName!,
            "amount": money,
            "toSubscriberId": seeker.id!
        ]
        
        Alamofire.request(.POST, "http://\(Constants.serverIp):\(Constants.serverPort)/v1/money/getfromuseracount", parameters: (parameters as! [String : AnyObject])).responseJSON { response in
            switch response.result {
            case .Success( _):
                callHandler(response: "Success")
            case .Failure( _):
                callHandler(response: "error")
            }
            
        }
    }
    
}