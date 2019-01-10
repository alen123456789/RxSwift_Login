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
    
    //密码框
    func validatePassword(_ password: String) -> Result {
        if password.count == 0 {
            return .empty
        }
        
        if password.count < minCharacterCount {
            return .failed(message: "密码长度至少6个字符")
        }
        
        return .ok(message: "密码可用")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPasswordword: String) -> Result {
        if repeatedPasswordword.count == 0 {
            return .empty
        }
        
        if repeatedPasswordword == password {
            return .ok(message: "密码可用")
        }
        
        return .failed(message: "两次密码不一样")
    }
    
    //    上面的返回结果都是一个Result类型的值，因为我们外面不要对这个处理过程进行监听，所以不必返回一个新的序列
    
    //注册方法
    //这里把注册信息写到本地的 plist 文件，写入成功就返回 ok ，否则就是 failed
    func register(_ username: String, password: String) -> Observable<Result> {
        let userDic = [username: password]
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        if (userDic as NSDictionary).write(toFile: filePath, atomically: true) {
            return .just(.ok(message: "注册成功"))
        }
        return .just(.failed(message: "注册失败"))
    }
    
    // 登录相关
    // 判断用户名是否可用，如果本地 plist 文件中有这个用户名，就可以使用这个用户名登录，用户名可用
    func loginUsernameValid(_ username: String) -> Observable<Result> {
        if username.count == 0 {
            return .just(.empty)
        }
        
        if usernameValid(username) {
            return .just(.ok(message: "用户名可用"))
        }
        return .just(.failed(message: "用户名不存在"))
    }
    
    // 登录方法，如果 username 和 password 都正确的话，就是登录成功，否则就是密码错误了
    func login(_ username: String, password: String) -> Observable<Result> {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        let userDic = NSDictionary(contentsOfFile: filePath)
        if let userPass = userDic?.object(forKey: username) as? String {
            if userPass == password {
                return .just(.ok(message: "登录成功"))
            }
        }
        return .just(.failed(message: "密码错误"))
    }
}

//搜索
class SearchService {
    static let shareInstance = SearchService()
    private init() {}
    
    // 从本地拉去数据，然后转换成 hero 模型
    // 返回的是一个 元素是 Hero 数组的 Observable 流。更新UI的操作要在主线程中
    func getHeros() -> Observable<[Hero]> {
        let herosString = Bundle.main.path(forResource: "heros", ofType: "plist")
        let herosArray = NSArray(contentsOfFile: herosString!) as! Array<[String: String]>
        var heros = [Hero]()
        herosArray.forEach { item in
            let hero = Hero(name: item["name"]!, desc: item["intro"]!, icon: item["icon"]!)
            heros.append(hero)
        }
        return Observable.just(heros).observeOn(MainScheduler.instance)
    }
    
    func getHeros(withName name: String) -> Observable<[Hero]> {
        if name == "" {
            return getHeros()
        }
        
        let herosString = Bundle.main.path(forResource: "heros", ofType: "plist")
        let herosArray = NSArray(contentsOfFile: herosString!) as! Array<[String: String]>
        var heros = [Hero]()
        herosArray.forEach { item in
            let hero = Hero(name: item["name"]!, desc: item["intro"]!, icon: item["icon"]!)
            heros.append(hero)
        }
        return Observable.just(heros)
            .observeOn(MainScheduler.instance)
    }
}
