//
//  SplashViewController.swift
//  TwitterSplash
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    var logoIsHidden: Bool = false
    
    static let logoImageBig: UIImage = UIImage(named: "TwitterLogoBig")!

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.isHidden = logoIsHidden
    }
    
}
