//
//  Protocol.swift
//  RxSwift_Login
//
//  Created by Han on 2018/12/21.
//  Copyright © 2018 anchnet. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum Result {
    case ok(message: String)
    case empty
    case failed(message: String)
}

/*
 我们首先对Result进行了扩展，添加了一个isValid属性，如果他的状态是ok，这个属性就返回true，否则就返回false
 
 然后对Result添加了一个textColor属性，如果Result属性为ok的时候颜色就是绿色，否则即使红色
 
 下面我们自定义了一个Observer，对UIlabel进行了扩展，根据result结果，进行他的text和textColor的显示
 
 最后我们对UITextField进行扩展，根据result结果，进行他的isEnabled进行设置
 
 */
extension Result {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension Result {
    var textColor: UIColor {
        switch self {
        case .ok:
            return UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
        case .empty:
            return UIColor.black
        case .failed:
            return UIColor.red
        }
    }
}

extension Result {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case let .failed(message):
            return message
        }
    }
}



//extension Reactive where Base: UILabel {
//    var validationResult: UIBindingObserver<Base, Result> {
//        return UIBindingObserver(UIElement: base) { label, result in
//            label.textColor = result.textColor
//            label.text = result.description
//        }
//    }
//}


extension Reactive where Base: UILabel {
    var validationResult: Binder<Result> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

// UIBindingObserver 弃用 现在改为 Binder
// UIBindingObserver这个东西很有用的，创建我们自己的监听者，有时候RxCocoa(RxSwift中对UIKit的一个扩展库)给的扩展不够我们使用，比如一个UITextField有个isEnabled属性，我想把这个isEnabled变为一个observer，我们可以这样做：

// public init<Target: AnyObject>(_ target: Target, scheduler: ImmediateSchedulerType = MainScheduler(), binding: @escaping (Target, Value) -> ())


extension Reactive where Base: UITextField {
    var inputEnabled: Binder<Result> {
        return Binder(base) { textFiled, result in
            textFiled.isEnabled = result.isValid
        }
    }
}

extension Reactive where Base: UIBarButtonItem {
    var tapEnabled: Binder<Result> {
        return Binder(base) { button, result in
            button.isEnabled = result.isValid
        }
    }
}

