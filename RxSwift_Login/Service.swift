//
//  Service.swift
//  RxSwift_Login
//
//  Created by Han on 2018/12/21.
//  Copyright © 2018 anchnet. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

//注册VC的textField处理代码
class ValidationService {

    static let instance = ValidationService()
    private init() {}
    let minCharacterCount = 6

    //这里返回一个observable对象，因为我们这个请求过程需要被监听
    func validateUsername(_ username: String) -> Observable<Result> {

        //just是创建一个sequence只能发出一种特殊的事件，能正常结束
        if username.count == 0 {
            return .just(.empty) //当字符数等于0时什么都不做
        }

        if username.count < minCharacterCount { //当小于6的时候返回failed
            return .just(.failed(message: "号码长度至少6个字符"))
        }

        if usernameValid(username) { //检测本地数据库中是否已经存在这个名字
            return .just(.failed(message: "账号已存在"))
        }

        return .just(.ok(message: "用户名可用"))
    }

    //从本地数据库中检测用户名是否已经存在
    func usernameValid(_ username: String) -> Bool {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        let userDic = NSDictionary(contentsOfFile: filePath)
        let usernameArray = userDic?.allKeys
        guard usernameArray != nil else {
            return false
        }

        if (usernameArray! as NSArray) .contains(username) {
            return true //无效
        } else {
            return false
        }
    }



}
