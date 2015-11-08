//
//  Seeker.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//


import Foundation
import Alamofire


class Seeker {
    var image: String?
    var name : String?
    var description : String?
    var requirements : [[String: String]]?
    var id : String?
    var accountMoney: Int?
    
    func addRequirements (amount: Int, reason : String, recurring: String) {
        if self.requirements == nil {
            requirements = [[
                "amount": "\(amount)",
                "reason": reason,
                "recurring": recurring
                ]]
        } else {
            requirements!.append([
                "amount": "\(amount)",
                "reason": reason,
                "recurring": recurring
                ])
        }
    }
    
    func save (){
        var otherUserDetails :[String : AnyObject] = [String : AnyObject]()
        
        if self.description != nil {
            otherUserDetails["description"] = self.description
        }
        
        
        if self.image != nil {
            otherUserDetails["image"] = self.image!
        }
        
        if self.requirements != nil {
            otherUserDetails["requirements"] = self.requirements!
        }
        var jsonUserDetails : NSData?
        print(otherUserDetails)
        
        do {
            jsonUserDetails = try NSJSONSerialization.dataWithJSONObject(otherUserDetails, options: NSJSONWritingOptions())
        } catch {
            print("error while stringifying")
            return
        }
        let str = NSString(data: jsonUserDetails!, encoding:NSUTF8StringEncoding)
        print(jsonUserDetails)
        
        let newSeeker = [
            "userAlias" : self.name!,
            "userId" : self.id!,
            "otherUserDetails" : str!
        ]
        NSUserDefaults.standardUserDefaults().setObject(self.id!, forKey: "seekerId")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        Alamofire.request(.POST, "http://\(Constants.serverIp):\(Constants.serverPort)/v1/money/createuser", parameters: (newSeeker)).responseJSON { response in
            debugPrint(response)
        }
    }
    
    static func fetchById(seekerId : String, handler: (Seeker) -> Void) -> Void {
        let parameters = [
            "userId" : seekerId
        ]
        print("requesting details")
        Alamofire.request(.POST, "http://\(Constants.serverIp):\(Constants.serverPort)/v1/money/getuserdetails", parameters: parameters).responseJSON { response in
            let seeker = Seeker()
            print("received it")
            switch response.result {
            case .Success(let data):
                print("success")

                let responseObj = data as! [String : NSObject]
                
                let obj = responseObj["data"] as! [String : NSObject]
                print(obj)                
                seeker.name = (obj["SubscriberAlias"] as! String)
                seeker.id = (obj["SubscriberId"] as! String)
                print("121")
                print(obj["otherUserDetails"])
                let str = (obj["otherUserDetails"] as! NSString).dataUsingEncoding(NSUTF8StringEncoding)
                var otherUserDetails :  Dictionary<String, AnyObject>?
                do {
                    otherUserDetails = try NSJSONSerialization.JSONObjectWithData(str!, options: NSJSONReadingOptions()) as? Dictionary<String, AnyObject>
                } catch {
                    print("error in converting back");
                    return;
                }
                if otherUserDetails!["description"] != nil {
                    seeker.description = (otherUserDetails!["description"] as! String)
                }
                if otherUserDetails!["image"] != nil {
                    seeker.image = (otherUserDetails!["image"] as! String)
                }
                let a = otherUserDetails!["requirements"]!
                print(a)
                if otherUserDetails!["requirements"] != nil {
                    let seeker_requirements = otherUserDetails!["requirements"] as! NSArray
                    for( var i = 0; i < seeker_requirements.count; i++ ) {
                        print("*********")
                        print(seeker_requirements[i]);
                        let eachSeeker = seeker_requirements[i] as! [String: String]
                        let amt = Int(eachSeeker["amount"]!)
                        
                        seeker.addRequirements(amt! , reason: eachSeeker["reason"]!, recurring: eachSeeker["recurring"]!)
                        print(eachSeeker);
                    }
                }
                print("3333")
                seeker.accountMoney = obj["totalMoney"] as? Int
                handler(seeker)
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
            
            
        }
    }
    
    static func getCurrentSeeker(handler: (Seeker) -> Void) -> Void  {
        let seekerId = NSUserDefaults.standardUserDefaults().objectForKey("seekerId") as? String
        self.fetchById(seekerId!, handler: handler)
    }
    
}