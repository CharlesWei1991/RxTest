//
//  MoyaTestViewModel.swift
//  C_RxSwift
//
//  Created by biprogybank01 on 2023/4/23.
//

import Foundation
import Moya
import RxCocoa
import RxSwift
class MoyaVM {
    var dataArr:[Model] = []
    lazy var bag: DisposeBag = {return DisposeBag()}()
    lazy var notifySuccess: PublishSubject<Void> = .init()//成功信号
    lazy var notifyError: PublishSubject<Error> = .init()//失败信号
    //    lazy var loading: BehaviorSubject<Bool> = .init(value: false)
    //数据模型
    struct JokerRes: Codable {
        let code: Int
        let msg: String
        let data: DataClass?
    }
    struct DataClass: Codable {
        let page, totalCount, totalPage, limit: Int
        let list: [Model]?
    }
    struct Model: Codable {
        let content, updateTime: String
        init(content: String, updateTime: String) {
            self.content = content
            self.updateTime = updateTime
        }
    }
    
    //给cell赋值用
    func cellModelWithItem(indexPath:IndexPath) -> CellModel?{
        if dataArr.count > indexPath.row{
            let item = dataArr[indexPath.row]
            return CellModel(content: item.content, time: item.updateTime)
        }
        return nil
    }
    //cell数量
    func numberOfItems() -> Int {
        return dataArr.count
    }
    //获得Model(点击事件传值用)
    func getModelWithIndex(at indexPath:IndexPath) -> Model{
        return dataArr[indexPath.row]
    }
    
    //网络请求
    func getData(){
        let provider = MoyaProvider<NetWork>()
        let target = NetWork.getJokers(page: "1")
        provider.request(target) {[weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let response):
                print("请求成功")
                let json = try? JSONDecoder().decode(JokerRes.self, from: response.data)
                if let jModel:JokerRes = json {
                    if let dataModel:MoyaVM.DataClass = jModel.data,
                       let modelList:[Model] = dataModel.list {
                        this.dataArr = modelList
                        this.notifySuccess.onNext(())
                    }
                }
                break
            case .failure(let error):
                print("请求失败")
                this.notifyError.onNext(error)
                break
            }
        }
    }
}
