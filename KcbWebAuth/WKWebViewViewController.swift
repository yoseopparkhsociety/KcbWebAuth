//
//  WKWebViewViewController.swift
//  CustomWebView
//
//  Created by yoseop park on 16/09/2019.
//  Copyright © 2019 HSOCIETY. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewViewController: UIViewController {

    private var webView: WKWebView!

    private let SCRIPT_MESSAGE_HANDLER = "kcbResult"
    private var indicator: UIActivityIndicatorView?

    var webUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        loadWebview()
    }

    override func loadView() {
        super.loadView()
    }
}

private extension WKWebViewViewController {
    func initialize() {
        if let count = self.navigationController?.viewControllers.count {
            let isEnterByModal = count == 1
            if isEnterByModal {
                let rightBarButton = UIBarButtonItem.init(image: UIImage.init(named: "blackClose"), style: .plain, target: self, action: #selector(closeButtonAction))
                rightBarButton.tintColor = UIColor.black
                self.navigationItem.rightBarButtonItem = rightBarButton

                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.hidesBackButton = true
            } else {
                let leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "blackBack"), style: .plain, target: self, action: #selector(closeButtonAction))
                leftBarButton.tintColor = UIColor.black
                self.navigationItem.leftBarButtonItem = leftBarButton
            }
        }
    }

    @objc func closeButtonAction() {
        if let count = self.navigationController?.viewControllers.count {
            let isEnterByPush = count > 1
            if isEnterByPush {
                self.navigationController?.popViewController(animated: true)
                return
            }
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    func loadWebview() {
        let config = WKWebViewConfiguration()
        webView = WKWebView.init(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)

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

extension WKWebViewViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

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
        self.present(alertController, animated: true, completion: nil)
    }

    /*
     자바스크립트 SCRIPT_MESSAGE_HANDLER 콜백 구현
     본인인증 완료시 웹뷰에서 데이터를 보내면 여기서 받는다.
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        if message.name == SCRIPT_MESSAGE_HANDLER {
            
        }
    }

    /*
     웹뷰에서 팝업으로 화면으로 이동시
     새로운 웹뷰로 url을 띄워준다.
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let surl = navigationAction.request.url?.absoluteString {
//            print("웹뷰 새창으로 이동 [\(surl)]")
//            if surl.contains("itunes.apple.com") {
//                if let url = URL(string: surl) {
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(url, options: [:])
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                }
//                return nil
//            }
            
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
