//
//  ViewController.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    var seekerId : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func seekAssistance(sender: UIButton) {
        seekerId = NSUserDefaults.standardUserDefaults().objectForKey("seekerId") as? String
        if (seekerId == nil) {
            performSegueWithIdentifier("landingToForm", sender: self)
        } else {
            performSegueWithIdentifier("landingToDetail", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier!) {
        case "landingToDetail":
            let vc = segue.destinationViewController as! SeekerDetailsPageController
            vc.seekerId = seekerId!
            vc.isOwner = true
        default:
            print("other scenario")
        }
    }

}

