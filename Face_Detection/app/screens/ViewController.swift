//
//  ViewController.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 17/10/24.
//

import UIKit
import SnapKit
import RealmSwift

class ViewController: UIViewController {
    let stack = UIStackView()
    let button1 = UIButton(configuration: .filled())
    let button2 = UIButton(configuration: .filled())
    let button3 = UIButton(configuration: .filled())
    
    override func viewDidAppear(_ animated: Bool) {
        button2Tap()
    }
    
    override func viewDidLoad() {
        button1.addTarget(self, action: #selector(button1Tap), for: .touchUpInside)
        button2.addTarget(self, action: #selector(button2Tap), for: .touchUpInside)
        button3.addTarget(self, action: #selector(button3Tap), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubviews(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        stack.addArrangedSubviews(button1, button2, button3)
        stack.axis = .vertical
        stack.spacing = 10
        
        button1.configuration?.baseBackgroundColor = .systemCyan
        button1.configuration?.title = "Photo Detection"
        
        button2.configuration?.baseBackgroundColor = .systemCyan
        button2.configuration?.title = "Live Detection"
        
        button3.configuration?.baseBackgroundColor = .systemCyan
        button3.configuration?.title = "Clear data"
    }
    
    @objc func button1Tap() {
        let vc = PhotoVC()
        present(vc, animated: true)
    }
    
    @objc func button2Tap() {
        let vc = LiveVC()
        present(vc, animated: true)
    }
    
    @objc func button3Tap() {
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
    }
    
    @objc func test() {
        let vc = NameAddVC()
        vc.cropImage = .jav
        present(vc, animated: true)
    }
}
