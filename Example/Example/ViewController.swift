//
//  ViewController.swift
//  Example
//
//  Created by jeeny on 04/03/2020.
//  Copyright © 2020 Jeeny. All rights reserved.
//

import UIKit
import UIProgressRing

class ViewController: UIViewController {

    @IBOutlet weak var progressRing: UIProgressRingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      progressRing.setBackgroundConfig(config: RingShapeLayer.Config(color: UIColor.orange))
      progressRing.setForeGroundConfig(config: RingShapeLayer.Config(color: UIColor.blue))
      progressRing.showPercentageSign = false
        progressRing.setProgress(progress: 50, totalProgress: 50, animated: false)
        progressRing.progressLabelFont = UIFont.systemFont(ofSize: 30, weight: .bold)
        progressRing.progressLabelColor = .red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.progressRing.setProgress(progress: Double.random(in: 10...100), totalProgress: 200, animated: true)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                self.progressRing.setProgress(progress: Double.random(in: 10...100), totalProgress: 200, animated: true)
            }
        }
        
    }
    

}

