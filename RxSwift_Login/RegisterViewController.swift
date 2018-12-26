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
        
        
        
    }
}



