//
//  NetWork.swift
//  C_RxSwift
//
//  Created by biprogybank01 on 2023/4/23.
//

import Foundation
import Moya

enum NetWork {
    case getJokers(page:String)
}

extension NetWork:TargetType{
    var baseURL: URL {
        return URL(string: "https://www.mxnzp.com/api/")!
    }
    
    var path: String {
        switch self {
        case .getJokers:
            return "jokes/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getJokers:
            return .get
        }
    }
    
    var task: Moya.Task {
        var params:[String:Any] = [:]
        switch self {
        case .getJokers(let page):
            params["app_id"] = "tpdmpsofripilego"
            params["app_secret"] = "U3RhUDFPWDRJUEh0U2FJSDBER3pjdz09"
            params["page"] = page
            break
        default:
            break
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
