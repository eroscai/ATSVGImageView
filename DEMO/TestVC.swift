//
//  TestVC.swift
//
//  Created by CaiSanze on 2020/10/27.
//

import UIKit
import PocketSVG

class TestVC: UIViewController {

    var views: [UIImageView] = []
    var maskViews: [ATSVGImageView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let imageName = "test.jpg"
        let width: CGFloat = 100
        let height: CGFloat = 100
        let svgNames: [String] = [
            "test1",
            "test2",
            "test3",
            "test4",
            "test5",
            "test6",
            "test7",
            "test8",
            "test9",
            "test10",
        ]

        var offsetX: CGFloat = 20
        var offsetY: CGFloat = 100

        for svgName in svgNames {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.frame = CGRect(x: offsetX, y: offsetY, width: width, height: height)
            imageView.contentMode = .scaleAspectFill
            view.addSubview(imageView)
            views.append(imageView)

            let url = Bundle.main.url(forResource: svgName, withExtension: "svg")!

            let maskView = ATSVGImageView(contentsOf: url)
            maskView.frame = imageView.bounds
            imageView.mask = maskView
            maskViews.append(maskView)

            offsetX += width + 30
            if offsetX > view.bounds.width - width - 20 {
                offsetX = 20
                offsetY += height + 50
            }
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let duration: Double = 1
        self.startAction(duration: duration, width: 100, height: 200) {
            self.startAction(duration: duration, width: 120, height: 150) {
                self.startAction(duration: duration, width: 100, height: 100) {
                    self.changeRaidus(from: 0, to: 100)
                }
            }
        }
    }

    func startAction(duration: Double,
                     width: CGFloat,
                     height: CGFloat,
                     completion: @escaping () -> Void)
    {
        UIView.animate(withDuration: duration) {
            var offsetX: CGFloat = 20
            var offsetY: CGFloat = 100
            for i in 0..<self.views.count {
                let subview = self.views[i]
                let maskView = self.maskViews[i]

                subview.frame = CGRect(x: offsetX, y: offsetY, width: width, height: height)
                maskView.frame = subview.bounds
                maskView.disableActions = false
                maskView.animateDuration = duration
                offsetX += width + 30
                if offsetX > self.view.bounds.width - width - 20 {
                    offsetX = 20
                    offsetY += height + 50
                }
            }
        } completion: { (_) in
            completion()
        }
    }

    func changeRaidus(from: Int, to: Int) {
        let queue = DispatchQueue(label: "testQueue")
        for i in from..<to {
            queue.async {
                Thread.sleep(forTimeInterval: 1 / Double(30))

                DispatchQueue.main.async {
                    for j in 0..<self.views.count {
                        let maskView = self.maskViews[j]
                        maskView.disableActions = true
                        maskView.cornerRadius = CGFloat(i)
                    }
                }
            }
        }
    }

}
