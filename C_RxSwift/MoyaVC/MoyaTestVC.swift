//
//  MoyaTestVC.swift
//  C_RxSwift
//
//  Created by biprogybank01 on 2023/4/23.
//

import UIKit
import RxCocoa
import RxSwift
import Moya
class MoyaTestVC: UIViewController {
    var vm:MoyaVM = MoyaVM()
    var disposeBag = DisposeBag()
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubViews()
        vm.notifySuccess.asObserver()
            .observe(on: MainScheduler.instance)
            .subscribe({[weak self] _ in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        vm.notifyError.asObserver()
            .observe(on: MainScheduler.instance)
            .subscribe({error in
                print("请求失败:\(error)")
            }).disposed(by: disposeBag)
        vm.getData()
    }
    func createSubViews(){
        view.backgroundColor = .white
        tableView = UITableView(frame: view.bounds)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
}
extension MoyaTestVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.numberOfItems()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = vm.cellModelWithItem(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = cellModel?.content
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
