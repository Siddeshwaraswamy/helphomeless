//
//  SeekerQRViewController.swift
//  giantleap
//
//  Created by Golak Sarangi on 11/7/15.
//  Copyright © 2015 Golak Sarangi. All rights reserved.
//

import UIKit

class SeekerQRViewController: UIViewController {
    var currentSeeker: Seeker?
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        let data = currentSeeker!.id?.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        let qrcodeImage = filter!.outputImage
        qrImageView.image = UIImage(CIImage: qrcodeImage!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! SeekerDetailsPageController
        vc.seeker = currentSeeker!
        vc.isOwner = true
    }
}
