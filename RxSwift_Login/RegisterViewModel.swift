//
//  RegisterViewModel.swift
//  RxSwift_Login
//
//  Created by Han on 2018/12/21.
//  Copyright © 2018 anchnet. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel {
    
    /*
     泛型的栈
     struct Stack<Element> {
     var items = [Element]()
     mutating func push(_ item: Element) {
     items.append(item)
     }
     mutating func pop() -> Element {
     return items.removeLast()
     }
     }
     
     var stackOfStrings = Stack<String>()
     print("字符串元素入栈: ")
     stackOfStrings.push("google")
     stackOfStrings.push("runoob")
     print(stackOfStrings.items)
     
     let deletetos = stackOfStrings.pop()
     print("出栈元素: " + deletetos)
     
     var stackOfInts = Stack<Int>()
     print("整数元素入栈: ")
     stackOfInts.push(1)
     stackOfInts.push(2)
     print(stackOfInts.items)
     */
    
    //input:
    let username = Variable<String>("") // username 既是一个 observable 也是一个 observer ,声明为一个 variable 对象
    
    let password = Variable<String>("")
    let repeatPassword = Variable<String>("")
    
    //注册按钮 input
    let registerTaps = PublishSubject<Void>() // 使用了 PublishSubject ，因为不需要有初始元素
    
    //output
    let usernameUsable: Observable<Result>
    let passwordUsable: Observable<Result> // 密码是否可用
    let repeatPasswordUsable: Observable<Result> // 密码确定是否正确
    //注册 output
    let registerButtonEnabled: Observable<Bool> // 注册按钮是否可用的输出，关系到 username 和 password
    let registerResult:Observable<Result> // 注册结果的 output
    
    init() {
        
        //        map函数只能返回原来的那一个序列，里面的参数的返回值被当做原来序列中所对应的元素。
        //        flatMap函数返回的是一个新的序列，将原来元素进行了处理，返回这些处理后的元素组成的新序列
        //        map函数 + 合并函数 = flatMap函数
        //        flatMapLatest其实就是flatMap的另一个方式，只发送最后一个合进来的序列事件。上面认证username是一个网络请求，我们需要对这个过程进行处理。
        
        let service = ValidationService.instance
        usernameUsable = username.asObservable()
            .flatMapLatest{ username in
                return service.validateUsername(username)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(.failed(message: "username检测出错"))
            }
            .share(replay: 1, scope: .forever)
        
        /*因为username是Variable类型，既可以当observer也可以当observable，viewModel中我们把它当成observable，然后对里面的元素进行监听和处理，这里面我们使用了flatMap，因为我们需要返回一个新的序列，也就是返回处理结果，因为涉及到数据库操作或者网络请求（当然是模拟的网络请求），所以这个序列需要我们去监听，这种情况我们使用flatMap
         后面使用.shareReplay(1)是因为我们要保证无论多少个Observer来监听我们这个序列，username的处理代码我们只执行一次，这一次请求结果供多有的observer去使用。
         */
        
        passwordUsable = password.asObservable()
            .map { password in
                return service.validatePassword(password)
            }
            .share(replay: 1, scope: .forever)
        
        repeatPasswordUsable = Observable.combineLatest(password.asObservable(), repeatPassword.asObservable()) {
            return service.validateRepeatedPassword($0, repeatedPasswordword: $1)
            }.share(replay:1, scope: .forever)
        // 这里使用 map，因为处理密码不需要去联网操作，不需要对他进行监控处理，只需要对流中的每一个 item 转换result 的值
        // 下面对确定面膜的处理，使用了 combineLatest 进行联合，也就是对两个 item 进行处理，返回处理结果流
        
        // 处理注册按钮的点击
        // 把 username，password 和 repeatPassword 的处理结果绑定到一起，返回一个总的结果流，是一个 bool 值的流
        registerButtonEnabled = Observable.combineLatest(usernameUsable, passwordUsable, repeatPasswordUsable) { (username, password, repeatPassword) in
            username.isValid && password.isValid && repeatPassword.isValid
            }
            .distinctUntilChanged()
            .share(replay: 1, scope: .forever)
        
        // 将 username 和 password 进行结合，得到一个元素是他们组合的元组的流
        let usernameAndPassword = Observable.combineLatest(username.asObservable(), password.asObservable()) {
            ($0, $1)
        }
        
        // 然后对 registerTaps 事件进行监听，拿到每一个元组进行注册行为，涉及到耗时数据库操作，需要对这个过程进行监听，使用 flatMap 函数，返回一个新的流
        registerResult = registerTaps.asObservable().withLatestFrom(usernameAndPassword)
            .flatMapLatest { (arg) -> Observable<Result> in
                let (username, password) = arg
                return service.register(username, password: password)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(.failed(message: "注册出错"))
            } 
            .share(replay: 1, scope: .forever)
    }
}
