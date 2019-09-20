//
//  ViewController.swift
//  CustomWebView
//
//  Created by yoseop park on 16/09/2019.
//  Copyright © 2019 HSOCIETY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Direct
    @IBAction func modalAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        vc.authCheckSuccessCallback = { authModel in
            print("인증 성공하고나서 화면 갱신")
            print("AuthModel : \(authModel)")
        }
        vc.backButtonCallback = {
            print("뒤로가기로 나와서 화면 갱신")
        }
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }
    
    
    // Guide
    @IBAction func pushActionWithGuide(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideViewController") as! GuideViewController
        vc.authCheckSuccessCallback = { authModel in
            print("인증 성공하고나서 화면 갱신")
            print("AuthModel : \(authModel)")
        }
        vc.backButtonCallback = {
            print("뒤로가기로 나와서 화면 갱신")
        }
//        self.navigationController?.pushViewController(vc, animated: true)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: true, completion: nil)
    }

}

