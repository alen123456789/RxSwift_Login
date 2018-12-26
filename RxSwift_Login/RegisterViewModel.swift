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
    //input:
    let username = Variable<String>("") //username 既是一个observable也是一个observer,声明为一个variable对象

    //output
    let usernameUsable: Observable<Result>

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
            .share(replay: 1)
        

        /*因为username是Variable类型，既可以当observer也可以当observable，viewModel中我们把它当成observable，然后对里面的元素进行监听和处理，这里面我们使用了flatMap，因为我们需要返回一个新的序列，也就是返回处理结果，因为涉及到数据库操作或者网络请求（当然是模拟的网络请求），所以这个序列需要我们去监听，这种情况我们使用flatMap
         后面使用.shareReplay(1)是因为我们要保证无论多少个Observer来监听我们这个序列，username的处理代码我们只执行一次，这一次请求结果供多有的observer去使用。
         */
        
        
        
        
        
    }

}
