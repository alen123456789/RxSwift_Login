//
//  LoginViewController.swift
//  RxSwift_Login
//
//  Created by herbalife_han on 2018/12/27.
//  Copyright © 2018 anchnet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var viewModel: LoginViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给 viewModel 传入相应的 input 的 Driver 序列
        viewModel = LoginViewModel(input: (username: usernameTextField.rx.text.orEmpty.asDriver(), password: passwordTextField.rx.text.orEmpty.asDriver(), loginTaps: loginButton.rx.tap.asDriver()), service: ValidationService.instance)
        
        // 将 viewModel 中的 output 进行相应的监听，如果是 Driver 序列，不使用 bind 而是使用 Driver ，用法和 bind 一样
        // Driver 的监听一定发生在 主流程，适合更新 UI 的操作
        viewModel.usernameUsable
            .drive(usernameLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.loginButtonEnabled
            .drive(onNext:{ [unowned self] valid in
                self.loginButton.isEnabled = valid
                self.loginButton.alpha = valid ? 1 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.loginResult
            .drive(onNext: { [unowned self] result in
                switch result {
                case let .ok(message):
                    self.performSegue(withIdentifier: "container", sender: self)
                    self.showAlert(message: message)
                case .empty:
                    self.showAlert(message: "")
                case let .failed(message):
                    self.showAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
    }

    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
}
