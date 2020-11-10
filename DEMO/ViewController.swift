//
//  ViewController.swift
//  DEMO
//
//  Created by CaiSanze on 2020/11/10.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let testBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        testBtn.backgroundColor = .black
        testBtn.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        testBtn.setTitle("Test", for: .normal)
        testBtn.setTitleColor(.white, for: .normal)
        testBtn.addTarget(self, action: #selector(handleTestBtnClick), for: .touchUpInside)
        view.addSubview(testBtn)

    }

    @objc func handleTestBtnClick() {
        let vc = TestVC()
        navigationController?.pushViewController(vc, animated: true)
    }


}

