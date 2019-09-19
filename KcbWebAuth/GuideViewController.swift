//
//  GuideViewController.swift
//  CustomWebView
//
//  Created by yoseop park on 19/09/2019.
//  Copyright © 2019 HSOCIETY. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {

    var authCheckSuccessCallback: ((AuthModel) -> Void)?
    var backButtonCallback: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarButton = UIBarButtonItem.init(image: UIImage.init(named: "blackClose"), style: .plain, target: self, action: #selector(closeButtonAction))
        rightBarButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func pushAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        vc.authCheckSuccessCallback = authCheckSuccessCallback
        vc.backButtonCallback = backButtonCallback
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func closeButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
