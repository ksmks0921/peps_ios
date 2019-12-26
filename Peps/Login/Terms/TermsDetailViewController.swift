//
//  TermsDetailViewController.swift
//  MyUmbrella
//
//  Created by KP Tech on 31/10/17.
//  Copyright © 2017 KP Tech. All rights reserved.
//

import UIKit

class TermsDetailViewController: UIViewController {
    @IBOutlet var webView: UIWebView!
    var urlString: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = false

        if let pdf = Bundle.main.url(forResource: urlString, withExtension: "pdf", subdirectory: nil, localization: nil) {
            let req = URLRequest(url: pdf)
            webView.loadRequest(req)
            view.addSubview(webView)
        }

//        if let s = urlString, let w = URL(string: s) {
//            webView.loadRequest(URLRequest(url: w))
//        }
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.topItem?.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
