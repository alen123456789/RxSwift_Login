//
//  ContainerViewModel.swift
//  RxSwift_Login
//
//  Created by herbalife_han on 2018/12/27.
//  Copyright © 2018 anchnet. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ContainerViewModel {
    //output:
    var models: Driver<[Hero]>  // output 是一个 Driver 流，因为更新 tableview 是 UI 操作
    
    // 使用了service 拉去数据的操作应该是在后台流程去运行，所以添加了 observeOn 操作
    // 使用 flapMap 返回新的 Observable 流，转换成 output 的 Driver 流
    init(withSearchText searchText: Observable<String>, service: SearchService) {
        models = searchText
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap { text in
                return service.getHeros(withName: text)
            }.asDriver(onErrorJustReturn: [])
        }
    
    
    
}
