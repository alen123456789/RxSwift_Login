//
//  LoginViewModel.swift
//  RxSwift_Login
//
//  Created by herbalife_han on 2018/12/27.
//  Copyright © 2018 anchnet. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    //output:
    // 声明这些 output 是 Driver 类型的，第一个是 username 处理结果流，第二个登录按钮是否可用的流，第三个是登录结果流
    let usernameUsable: Driver<Result>
    let loginButtonEnabled: Driver<Bool>
    let loginResult: Driver<Result>
    
    // 这个跟刚才的注册界面不同，注册界面参考了官方文档的写法，不推荐，如果 controller 中有很多元素，不可能一个一个传过来
    // 初始化方法中传入的是一个 input 元组，包括 username 的 Driver 序列，password 的 Driver 序列，还有一个登录按钮点击的 Driver 序列，还有 Service 对象，需要 Controller 传递过来，其实 Controller 不应该拥有 Service 对象
    // 初始化方法中，对传入的序列进行处理和转换成对应的 output 序列
    // 使用了 Driver 不再需要 shareReplay(1)
    
    init(input: (username: Driver<String>, password: Driver<String>, loginTaps: Driver<Void>), service: ValidationService) {
        usernameUsable = input.username.flatMapLatest { username in
            return service.loginUsernameValid(username)
                .asDriver(onErrorJustReturn: .failed(message: "连接service失败"))
        }
        
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) {
            ($0, $1)
        }
        
        loginResult = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                return service.login(username, password: password)
                    .asDriver(onErrorJustReturn: .failed(message: "连接service失败"))
        }
        
        loginButtonEnabled = input.password
            .map{ $0.count > 0 }
            .asDriver()
        
        
    }
    
    
    
    
    
}
