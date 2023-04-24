//
//  ViewController.swift
//  C_RxSwift
//
//  Created by biprogybank01 on 2023/4/18.
//

import UIKit
import RxSwift
import RxCocoa
class ViewController: UIViewController {
   
    @IBAction func goMoyaClicked(_ sender: Any) {
        self.present(MoyaTestVC(), animated: true)
    }
    @IBAction func goRxSwiftClicked(_ sender: Any) {
        
    }
}

