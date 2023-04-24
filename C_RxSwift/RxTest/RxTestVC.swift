//
//  RxTestVC.swift
//  C_RxSwift
//
//  Created by biprogybank01 on 2023/4/23.
//

import UIKit
import RxSwift
import RxCocoa
class RxTestVC: UIViewController {
    var tf1: UITextField!
    var tf0: UITextField!
    var lab1: UILabel!
    var lab0: UILabel!
    var btn0: UIButton!
    var imgV: UIImageView!
    
    var disposeBag = DisposeBag()
    struct Student{
        let score:Int
        let sex:Int
        let baba:Baba
        init(score: Int, sex: Int) {
            self.score = score
            self.sex = sex
            self.baba = Baba()
        }
        func speak(){
            print("I wanna be a guy!")
        }
    }
    
    struct Baba{
        func lingJiang(){
            print("My Son is best!")
        }
    }
    
    enum DataError:Error{
        case cantParseJSON
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubViews()
//        self.test00()//关于输入框和按钮控制
//        self.test01()//关于筛选 排序 和映射
//        self.test02()//可监听序列
//        self.test03()//Driver
//        self.test04()//观察者
//        self.test05()//既是可观察序列  又是观察者
        self.test06()//操作符
        
    }
    func createSubViews(){
        
    }
    func test06(){
        //filter 过滤 产生一个符合条件的新的序列
        let observable = Observable.of(28,29.30,31,32,33,34,35)
        observable.filter{tem in tem > 33}
            .subscribe(onNext:{tem in
            print("高温:\(tem)")
            }).disposed(by: disposeBag)
        //map 映射
//        struct Model{
//            let a:String
//        }
//        let json:Observable<Any> = Observable.just("100")
//        json.map(Model.init).subscribe(onNext:{ model in
//            print("取得Model:\(model)")
//        }).disposed(by: disposeBag)
        
        
    }
    func test05(){
        //AsyncSubject : 在onCompleted事件后发出最后一个元素,如果没有元素,就只发出completed
//        let subject = AsyncSubject<String>()
//        subject.subscribe{print("Subscription: 1 Event:",$0)}.disposed(by: disposeBag)
//        subject.onNext("0")
//        subject.onNext("1")
//        subject.onNext("2")
//        subject.onCompleted()
        //PublishSubject: 发送订阅后产生的元素,之前的不发,如果产生error终止,就只发error
//        let subject = PublishSubject<String>()
//        subject.subscribe{print("Subscription: 1 Event:",$0)}.disposed(by: disposeBag)
//        subject.onNext("0")
//        subject.onNext("1")
//        subject.subscribe{print("Subscription: 2 Event:",$0)}.disposed(by: disposeBag)
//        subject.onNext("2")
//        subject.onNext("3")
        //ReplaySubject: 发送最后的n个元素,不管是什么时候订阅的
//        let subject = ReplaySubject<String>.create(bufferSize: 2)
//        subject.onNext("0")
//        subject.onNext("1")
//        subject.onNext("2")
//        subject.onNext("3")
//        subject.onNext("4")
//        subject.subscribe{print("Subscription: 1 Event:",$0)}.disposed(by: disposeBag)
        //BehaviorSubject: 订阅时,将最新的元素发出来,如果没有最新的就发默认的,随后发出新产生的,如果产生了error,就只发出error
        let subject = BehaviorSubject(value: "默认")
        subject.subscribe{print("Subscription: 1 Event:",$0)}.disposed(by: disposeBag)
        subject.onNext("0")
        subject.onNext("1")
        subject.onNext("2")
        subject.subscribe{print("Subscription: 2 Event:",$0)}.disposed(by: disposeBag)
        subject.onNext("3")
        subject.onNext("4")
        
    }
    func test04(){
        //使用普通观察者效果
//        let observer: AnyObserver<Bool> = AnyObserver {[weak self] (event) in
//            switch event {
//            case .next(let isHidden):
//                self?.lab0.isHidden = isHidden
//            default:
//                break
//            }
//        }
        //使用Binder的效果
        let observer1: Binder<Bool> = Binder(lab0){(view,isHidden) in
            view.isHidden = isHidden
        }
        let tf0Key = tf0.rx.text.orEmpty
            .map{$0.count > 2}
            .share(replay: 1)
            .bind(to: observer1).disposed(by: disposeBag)
//        tf0Key.bind(to: observer1).disposed(by: disposeBag)
        
        //以下代码和上面等价
//        tf0Key.bind(to: lab1.rx.isHidden).disposed(by: disposeBag)
        
        
    }
    func test03(){
        //比较稳妥的处理方案
        let result = tf0.rx.text.skip(2)
            .flatMap{[weak self](input) -> Observable<Any> in
                return (self?.dealwithData(inputText: input ?? ""))!
                    .observe(on: MainScheduler())//切换到主线程更新UI
                    .catchAndReturn("检测到错误代码")//检测错误事件  防止返回error
        }.share(replay:1,scope: .whileConnected)//开启网络共享(防止请求多次)
        
        result.subscribe(onNext: {(element) in
            print("订阅到了:\(element)")
        }).disposed(by: disposeBag)
        result.subscribe(onNext: {(element) in
            print("订阅到了2:\(element)")
        }).disposed(by: disposeBag)
        
        
        //使用Driver的处理方案(推荐)
        let result1 = tf1.rx.text.orEmpty.asDriver()
            .skip(2)
            .flatMap{
            return self.dealwithData(inputText: $0).asDriver(onErrorJustReturn: "检测到了错误事件")
        }
        result1.map{"长度:\(($0 as! String).count)"}
            .drive(self.lab1.rx.text)
        
        result1.map{"长度:\(($0 as! String).count)"}
            .drive(self.lab0.rx.text)
        
    }
    //模拟网络请求
    func dealwithData(inputText:String)-> Observable<Any>{
        print("请求网络了 \(Thread.current)") // data
        return Observable<Any>.create({ (ob) -> Disposable in
            if inputText == "123" {
                ob.onError(NSError.init(domain: "模拟报错", code: 400, userInfo: nil))
            }
            DispatchQueue.global().async {
                print("发送之前看看: \(Thread.current)")
                ob.onNext("已经输入:\(inputText)")
                ob.onCompleted()
            }
            return Disposables.create()
        })
    }
    func test02(){
        //Single: 1个元素 | 1个错误
        //Completable: 1个completed事件 | 1个错误
        //Maybe: 1个元素 | 1个completed事件 | 1个错误
        //Driver: 不会产生error事件,一定在主线程监听
        //可监听序列
        let taps:Observable<Void> = btn0.rx.tap.asObservable()
        taps.subscribe(onNext:{
            print("被点击了")
        }).disposed(by: disposeBag)
        
        typealias JSON = Any
        let json: Observable<JSON> = Observable.create{(observer) -> Disposable in
            let task = URLSession.shared.dataTask(with: URL(string: "www.baidu.com")!){data,_,error in
                guard error == nil else{
                    observer.onError(error!)
                    return
                }
                guard let data = data,
                      let jsonObject = try? JSONSerialization.jsonObject(with: data,options: .mutableLeaves)
                else{
                    observer.onError(DataError.cantParseJSON)
                    return
                }
                observer.onNext(jsonObject)
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
        
        json.subscribe(onNext: {json in
            print("取得数据成功")
        }, onError: {error in
            print("出现错误")
        }, onCompleted: {
            print("任务已完成")
        }).disposed(by: disposeBag)
    }
    
    func test01(){
        var allStu:[Student] = Array()
        let stu1 = Student.init(score: 99, sex: 0)
        let stu2 = Student.init(score: 50, sex: 1)
        let stu3 = Student.init(score: 30, sex: 0)
        let stu4 = Student.init(score: 89, sex: 1)
        let stu5 = Student.init(score: 10, sex: 0)
        let stu6 = Student.init(score: 20, sex: 1)
        allStu.append(stu1)
        allStu.append(stu2)
        allStu.append(stu3)
        allStu.append(stu4)
        allStu.append(stu5)
        allStu.append(stu6)
        //筛选  0为女 1为男
        
        //筛选男生  然后每个人speak
        allStu
            .filter{ stu in stu.sex == 1 }
            .forEach{ nan in nan.speak() }
        
        //排序
        let sortArr = allStu.sorted{s0,s1 in s0.score > s1.score}
        print(sortArr)
        
        //映射为家长 然后家长lingJiang
        allStu
            .filter{stu in stu.score > 60}
            .map{stu in stu.baba}
            .forEach{ba in ba.lingJiang()}
    }
    func test00(){
        //简单的举例
        //tf1的判断
        let tf0Key = tf0.rx.text.orEmpty
            .map{$0.count > 2}
            .share(replay: 1)
        
        tf0Key.bind(to: lab0.rx.isHidden)
            .disposed(by: disposeBag)
        tf0Key.bind(to: tf1.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //tf2的判断
        let tf1key = tf1.rx.text.orEmpty
            .map{$0.count > 2}
            .share(replay:1)
        tf1key.bind(to: lab1.rx.isHidden)
            .disposed(by: disposeBag)
        //合并两个输入框的判断
        let allOk = Observable.combineLatest(tf0Key,tf1key){
            $0 && $1
        }.share(replay: 1)
        allOk.bind(to: btn0.rx.isEnabled)
            .disposed(by: disposeBag)
        //点击事件
        btn0.rx.tap.subscribe(onNext: {[weak self] in
            self?.doSomething()
        }).disposed(by: disposeBag)
    }
    func doSomething(){
        print("打印数据")
    }
    
    
}
