//
//  NetworkManager.swift
//  AtilzeCunsumer
//
//  Created by Sreejith on 07/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {

    var manager = Alamofire.SessionManager.default
    
    func isNetworkRechable() -> Bool {
        if (NetworkReachabilityManager()?.isReachable)! { return true }
        return false
    }
    
    convenience required init(timeoutInterval:Double) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        self.init()
        
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    //Put MethHiHihh
     func putMethod(_ strURL: String, params : [String: Any]?, success:@escaping (Any?) -> Void, failure:@escaping (Error) -> Void) {
        let headers: HTTPHeaders = [ "Authorization" : Utility.getToken(), "X-Requested-With" : "XMLHttpRequest" ]
        manager.request(strURL, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) in
            if responseObject.result.isSuccess {
                var successDict : [String : Any] = [String : Any]()
                successDict["status_code"] = responseObject.response?.statusCode
                if responseObject.response?.statusCode == 200 {
                    successDict["data"] = responseObject.result.value
                } else {
                    successDict["error"] = responseObject.result.value
                }
                success(successDict)
                
               // success(responseObject.result.value)
                
            }
            if responseObject.result.isFailure {
                guard let error = responseObject.result.error else {
                    return
                }
                failure(error)
            }

        }
    }

    /// Get Method
    func getMethod(_ strURL: String, params : [String: Any]?, success:@escaping (Any?) -> Void, failure:@escaping (Error) -> Void) {
        let headers: HTTPHeaders = [ "Authorization" : Utility.getToken(), "X-Requested-With" : "XMLHttpRequest" ]
        manager.request(strURL, method: .get, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) in
            
            if responseObject.result.isSuccess {
                var successDict : [String : Any] = [String : Any]()
                successDict["status_code"] = responseObject.response?.statusCode
                if responseObject.response?.statusCode == 200 {
                    successDict["data"] = responseObject.result.value
                } else {
                    successDict["error"] = responseObject.result.value
                }
                success(successDict)
                
              //  success(responseObject.result.value)
            }
            if responseObject.result.isFailure {
                guard let error = responseObject.result.error else {
                    return
                }
                failure(error)
            }
        }
    }

    /// Post Methods
    func postMethod(_ strURL: String, params : [String: Any]?, success:@escaping (Any?) -> Void, failure:@escaping (Error) -> Void) {
       // let _: HTTPHeaders = [ "Content-Type": "application/json"]
        var headers: HTTPHeaders = ["X-Requested-With" : "XMLHttpRequest"]
        if Utility.getToken().characters.count > 0 {
            headers["Authorization"] = Utility.getToken()
        }
        manager.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) in
            if responseObject.result.isSuccess {
                var successDict : [String : Any] = [String : Any]()
                successDict["status_code"] = responseObject.response?.statusCode
                if responseObject.response?.statusCode == 200 {
                    successDict["data"] = responseObject.result.value
                } else {
                    successDict["error"] = responseObject.result.value
                }
                success(successDict)
                
              //  success(responseObject.result.value)
            }
            if responseObject.result.isFailure {
                guard let error = responseObject.result.error else {
                    return
                }
                failure(error)
            }
        }
    }
    
    // DELETE methods 
    func deleteMethod(_ strURL: String, params : [String: Any]?, success:@escaping (Any?) -> Void, failure:@escaping (Error) -> Void) {
        let headers: HTTPHeaders = ["Authorization" : Utility.getToken(), "X-Requested-With" : "XMLHttpRequest"]
        
        manager.request(strURL, method: .delete, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) in
            if responseObject.result.isSuccess {
                success(responseObject.result.value)
            }
            if responseObject.result.isFailure {
                
//                if responseObject.response?.statusCode == 200 {
//                    
//                }
                guard let error = responseObject.result.error else {
                    return
                }
                failure(error)
            }
        }
    }
}
