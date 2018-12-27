//
//  RegisterViewController.swift
//  RxSwift_Login
//
//  Created by Han on 2018/12/21.
//  Copyright © 2018 anchnet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordTextFeild: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextWord: UITextField!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var registerButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = RegisterViewModel()
        
        usernameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag) // 把TextFiled的text变成了一个Observable，后面的orEmpty我们可以Command点进去看下，他会把String?过滤nil帮我们变为String类型
        // 因为我们的username既是一个observable也是一个observer，此时此刻我们把他当成一个Observer绑定到usernameTextFiled上，监听我们的usernameTextField流。绑定就是监听，bingTo里面里面的就是监听者也就是Observer
        // 因为我们有监听，就要有监听资源的回收，所以我们创建一个disposeBag来盛放我们的这些监听资源。
        
        viewModel.usernameUsable
            .bind(to: usernameLabel.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.usernameUsable
            .bind(to: passwordTextFeild.rx.inputEnabled)
            .disposed(by: disposeBag)
        //将ViewModel中username处理结果usernameUsable绑定到usernameLabel显示文案上，根据不同的结果显示不同的文案
        //将ViewModel中username处理结果usernameUsable绑定到passwordTextField是否可以输入，根据不同的结果判断password是否可以输入。
        
        
        /*
         总结一下这个过程：
         输入文本框Observable流->ViewModel中username对文本框进行监听->然后username调用service进行处理得到usernameUsable结果流->提示lable对usernameUsable进行监听刷新UI。
         其实就是两个流的过程
         UI操作->ViewModel->改变数据
         数据改变->ViewModel->UI刷新
         这就是响应式编程，一路的监听
         */
        
        
        
        // 添加 passwordTextField 绑定
        // 将 viewModel 中的 password 对 passwordTextField 进行监听
        // 将 viewmodel 中的 repoeadPassword 对 repeatPasswordTextField 进行监听
        passwordTextFeild.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        repeatPasswordTextWord.rx.text.orEmpty
            .bind(to: viewModel.repeatPassword)
            .disposed(by: disposeBag)
        
        //对 ViewModel 的 output 进行处理
        viewModel.passwordUsable
            .bind(to: passwordLabel.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.passwordUsable
            .bind(to: repeatPasswordTextWord.rx.inputEnabled)
            .disposed(by: disposeBag)
        
        viewModel.repeatPasswordUsable
            .bind(to: repeatPasswordLabel.rx.validationResult)
            .disposed(by: disposeBag)
        
        // passwordLabel 对 viewModel.passwordUsable 进行监听，显示不同的文案提示
        // repeatPasswordTextField 对 passwordUsable 进行监听，结果 ok 可输入状态，否则就是不可输入
        // repeatPasswordTextField 对 repeatPasswordUsable 进行监听，显示不同文案提示
        
        //注册按钮的绑定
        registerButton.rx.tap
            .bind(to: viewModel.registerTaps)
            .disposed(by: disposeBag)
        
        //对 viewModel 中的 output 进行处理
        
        // unowned 和 weak 区别 ？？？
        /*
         [unowned self] ： 在闭包中经常使用来解决循环引用的问题。 当我们确定两个对象属于相互引用的情况，而且二者需要销毁的时机是一样的，那么就可以用    例如：viewController 对tableView强引用，tableView强拥有tableViewCell,而二者是需要在 vc销毁的时候，同时销毁的，那么cell里面的点击事件通过闭包传到vc时就可以用[unowned self]
         
         [weak self] : 也可以用来解决循环引用，其他的作用，以我目前的知识还没有意识到。 [ weak self] 时self 可能是为nil的，最常见的crash是，当我们在一个下拉刷新请求数据时，再网络请求还没有完成时，就立刻退出当前页面，那么vc就被销毁了，网络请求完成的闭包再用self就会造成crash
         */
        viewModel.registerButtonEnabled
            .subscribe(onNext: { [unowned self]  valid in
                self.registerButton.isEnabled = valid
                self.registerButton.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.registerResult
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case let .ok(message):
                    self.showAlert(message: message)
                case .empty:
                    self.showAlert(message: "")
                case let .failed(message):
                    self.showAlert(message: message)
                }
            })
            .disposed(by: disposeBag)
        // 对 registerButtonEnabled 进行监听，根据不同的 item 对注册按钮进行设置
        // 对 registerResult 进行监听，显示不同的弹框信息
    }
    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
}



