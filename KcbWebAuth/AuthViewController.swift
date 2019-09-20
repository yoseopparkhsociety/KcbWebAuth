//
//  WebViewController.swift
//  CustomWebView
//
//  Created by yoseop park on 16/09/2019.
//  Copyright © 2019 HSOCIETY. All rights reserved.
//

import UIKit
import WebKit

class AuthViewController: UIViewController {
    
    
    @IBOutlet weak var goback: UIButton!
    private var webView: WKWebView!
    private let webUrl = "https://kcb.routedate.com/kcb/popup2"
    private let SCRIPT_MESSAGE_HANDLER = "kcbResult"
    private var indicator: UIActivityIndicatorView?
    
    var authCheckSuccessCallback: ((AuthModel) -> Void)?
    var backButtonCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        loadWebview()
    }
    
    @IBAction func buttonTouched(_ sender: Any) {
        self.webView.goBack()
    }
    
    override func loadView() {
        super.loadView()
    }
    
    func authCheckFinished(auth: AuthModel) {
        self.dismiss(animated: true, completion: {
            self.authCheckSuccessCallback?(auth)
        })
    }
}

private extension AuthViewController {
    func isModal() -> Bool {
        return self.navigationController?.viewControllers.count == 1
    }
    
    func initialize() {
        if isModal() {
            let rightBarButton = UIBarButtonItem.init(image: UIImage.init(named: "blackClose"), style: .plain, target: self, action: #selector(closeButtonAction))
            rightBarButton.tintColor = UIColor.black
            self.navigationItem.rightBarButtonItem = rightBarButton
            
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.hidesBackButton = true
            return
        }
        
        let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "blackBack"), style: .plain, target: self, action: #selector(closeButtonAction))
        leftBarButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func closeButtonAction() {
        backButtonCallback?()
        if isModal() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadWebview() {
        
        //
        let config = WKWebViewConfiguration()
        
        // 자바 스크립트 콜백 연결
        /*
         https://m.blog.naver.com/PostView.nhn?blogId=banhong&logNo=220563623492&proxyReferer=https%3A%2F%2Fwww.google.com%2F
         */
        let contentController = WKUserContentController()
        contentController.add(self, name: SCRIPT_MESSAGE_HANDLER)
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        self.view.bringSubviewToFront(goback)
        
        // 인디케이터
        indicator = UIActivityIndicatorView.init(style: .gray)
        self.view.addSubview(indicator!)
        DispatchQueue.main.async {
            self.webView.frame = self.view.bounds
            self.indicator?.center = self.view.center
        }
        
        let url = URL(string: webUrl)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
}

extension AuthViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    /*
     웹뷰 로드 시작시
     인디케이터 start
     */
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.indicator?.isHidden = false
        self.indicator?.startAnimating()
    }
    
    /*
     웹뷰 로드 종료시
     인디케이터 stop
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.indicator?.isHidden = true
        self.indicator?.stopAnimating()
    }
    
    /*
     자바스크립트 Alert 구현
     */
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction( UIAlertAction.init(title: "확인", style: .default, handler: nil) )
        self.present(alertController, animated: true, completion: { completionHandler() })
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "확인", style: .default, handler: { _ in completionHandler(true)
            self.closeButtonAction()
        }))
        alertController.addAction(UIAlertAction.init(title: "취소", style: .default, handler: { _ in
            completionHandler(false)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     자바스크립트 SCRIPT_MESSAGE_HANDLER 콜백 구현
     본인인증 완료시 웹뷰에서 데이터를 보내면 여기서 받는다.
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == SCRIPT_MESSAGE_HANDLER {
            print(message.body)
            // string 포멧으로 내려올 경우
            if let strJson = message.body as? String, let auth = AuthModel.init(messageBody: strJson) { authCheckFinished(auth: auth); return }
            // json 포멧으로 내려올 경우
            if let json = message.body as? [String: AnyObject], let auth = AuthModel.init(json: json) { authCheckFinished(auth: auth); return }
        }
    }
    
    /*
     웹뷰에서 팝업으로 화면으로 이동시
     새로운 웹뷰로 url을 띄워준다.
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            self.webView.load(navigationAction.request)
        }
        
        if let surl = navigationAction.request.url?.absoluteString {
            print("웹뷰 새창으로 이동 [\(surl)]")
            let web = WKWebViewViewController(nibName: "WKWebViewViewController", bundle: nil)
            web.webUrl = surl
            let navi = UINavigationController.init(rootViewController: web)
            self.present(navi, animated: true, completion: nil)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let surl = navigationAction.request.url?.absoluteString {
            print("탐색..... [\(surl)]")
        }
        decisionHandler(.allow) // 탐색 허용
    }
}


class AuthModel: NSObject {
    let SUCCESS = "B000"
    var resultCd: String = "" // B000
    var resultMsg: String = "" //본인인증 완료
    var name: String = "" //박요섭
    var gender: String = "" //M
    var birthday: String = "" //19860106
    var localYn: String = "" //Y
    var telCo: String = "" //01
    var mbNo: String = "" //01089997677
    var ci: String = "" //ickEbutKH/fsADJv65R4QyP4iswUT4uk3BI+ISuB+lLJKcZ9c9vud1+dcZY48AW1IUPr5UAaxExnnUDvXY3ulg==
    
//    var userAge: Int {
//        let birthStr = self.birthday
//        let index = birthStr.index(birthStr.startIndex, offsetBy: 4)
//        let yearStr = birthStr[..<index]
//        let userBirthYear = Int(yearStr)!
//        let age = (Date().year() - userBirthYear) + 1
//        return age
//    }
    
    convenience init?(messageBody: Any) {
        if let bodyStr = messageBody as? String, let data = bodyStr.data(using: .utf8) {
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            self.init(json: json)
        } else {
            return nil
        }
    }
    
    init?(json: [String: AnyObject]) {
        if let value = json["resultCd"] as? String {
            if value != SUCCESS { return nil }
            self.resultCd = value
        }
        if let value = json["resultMsg"] as? String { self.resultMsg = value }
        if let value = json["name"] as? String { self.name = value }
        if let value = json["gender"] as? String { self.gender = value }
        if let value = json["birthday"] as? String { self.birthday = value }
        if let value = json["localYn"] as? String { self.localYn = value }
        if let value = json["telCo"] as? String { self.telCo = value }
        if let value = json["mbNo"] as? String { self.mbNo = value }
        if let value = json["ci"] as? String { self.ci = value }
    }
    
    override var description: String {
        return """
        ┏[ UserInfoModel ]━━━━━━━━━━
        ┃ * resultCd : \(resultCd)
        ┃ * name : \(name)
        ┃ * gender : \(gender)
        ┃ * birthday : \(birthday)
        ┃ * localYn : \(localYn)
        ┃ * telCo : \(telCo)
        ┃ * mbNo : \(mbNo)
        ┃ * ci : \(ci)
        ┗👾👾👾👾👾
        
        """
    }
}
