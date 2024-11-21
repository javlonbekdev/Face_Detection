//
//  NameAddVC.swift
//  Face_Detection
//
//  Created by Javlonbek Dev on 13/11/24.
//

import UIKit

class NameAddVC: UIViewController {
    var cropImage: UIImage?
    
    let vectorHelper = VectorHelper()
    
    let stack = UIStackView()
    let image = UIImageView()
    let space = UIView()
    let nameField = TextField()
    let saveButton = UIButton(configuration: .filled())
    
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        saveButton.addTarget(self, action: #selector(saveButtonTap), for: .touchUpInside)
        image.image = cropImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(stack)
        stack.snp.makeConstraints { $0.top.centerX.equalToSuperview() }
        stack.addArrangedSubviews(image, space, nameField, saveButton)
        stack.axis = .vertical
        stack.spacing = 10
        
        image.snp.makeConstraints { $0.width.height.equalTo(200) }
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        
        space.snp.makeConstraints { $0.height.equalTo(30) }
        nameField.backgroundColor = .secondarySystemBackground
        nameField.layer.cornerRadius = 8
        nameField.placeholder = "Enter name"
        saveButton.configuration?.title = "Save"
    }
    
    @objc func saveButtonTap() {
        vectorHelper.saveVector(name: nameField.text, image: cropImage)
        dismiss(animated: true)
    }
}
