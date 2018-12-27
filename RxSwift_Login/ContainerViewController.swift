//
//  ContainerViewController.swift
//  RxSwift_Login
//
//  Created by herbalife_han on 2018/12/27.
//  Copyright © 2018 anchnet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContainerViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    var searchBarText: Observable<String> {
        return searchBar.rx.text.orEmpty
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    // 不需要设置 dataSource
    // 将数据绑定到 tableview 的 items 元素，这是 RxCocoa 对 tableView 的一个扩展方法
    // 在 MVVM 模式中，model 层不应该暴露给 ViewController，
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = ContainerViewModel(withSearchText: searchBarText, service: SearchService.shareInstance)
        
        // 这是科里化的方法,不用 section 的时候使用这个，有两个参数，一个是循环利用 cell 的 identity，一个是 cell 的类型。后面会返回一个闭包，在闭包里对 cell 进行设置
        viewModel.models
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = element.desc
                cell.imageView?.image = UIImage(named: element.icon)
        }.disposed(by: disposeBag)
    }
}
