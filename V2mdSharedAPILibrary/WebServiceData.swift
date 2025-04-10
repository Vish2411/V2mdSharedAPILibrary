//
//  WebServiceData.swift
//  V2mdSharedAPILibrary
//
//  Created by Mac mini on 10/04/25.
//

import Foundation
import Moya
import SVProgressHUD

public class WebServiceData: NSObject {
    
    public var fileProgress : ((String?, String?) -> Void)?
    public var session : URLSession?
    public var sesionTaskAr = [URLSessionUploadTask]()
    
//    private let provider = MoyaProvider<NetworkEndPoints>()
    
    private static var instance = WebServiceData()
    public static var shared : WebServiceData {
        return instance
    }

//    public var baseURL = getBaseURL()
    public var ischangePasswordAPI = false
    public var retryCount : Int = 2
    
    public static func getBaseURL() -> String {
        return "Test Library"
    }
    /*
    public func showIndicator() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
    }
    
    public func showIndicatorClear() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setForegroundColor(.clear)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.show()
    }
    
    public func hideIndicator() {
        SVProgressHUD.dismiss()
    }
     */
    /*
    public func requestUserLoginOr2FA(count: Int = 0, isLogin: Bool, username: String, password: String, completion: @escaping ((Int, UserLoginModel?, ErrorModel?, Response?, ProgressBlock?) -> Void)) {
        self.showIndicator()
        if isLogin {
            self.provider.request(.userLogin(username: username, password: password)) { (result) in
                self.processResponse(count: count, isRetry: true, result: result, finalCompletion: completion) { (count, isCallAgain) in
                    if isCallAgain {
                        self.requestUserLoginOr2FA(count: count, isLogin: isLogin, username: username, password: password, completion: completion)
                    }
                }
            }
        }
        else {
            self.provider.request(.user2FA(username: username, password: password)) { (result) in
                self.processResponse(count: count, isRetry: true, result: result, finalCompletion: completion) { (count, isCallAgain) in
                    if isCallAgain {
                        self.requestUserLoginOr2FA(count: count, isLogin: isLogin, username: username, password: password, completion: completion)
                    }
                }
            }
        }
    }
    
    public func requestUserForgotOrResend(count: Int = 0, isForgot: Bool, username: String, completion: @escaping ((Int, String?, ErrorModel?, Response?, ProgressBlock?) -> Void)) {
        //response is string "ok" so no need to make model for this
        self.showIndicator()
        if isForgot {
            self.provider.request(.userForgotPassword(username: username)) { (result) in
                self.processResponse(count: count, isRetry: true, result: result, finalCompletion: completion) { (count, isCallAgain) in
                    if isCallAgain {
                        self.requestUserForgotOrResend(count: count, isForgot: isForgot, username: username, completion: completion)
                    }
                }
            }
        }
        else {
            self.provider.request(.userResendPassword(username: username)) { (result) in
                self.processResponse(count: count, isRetry: true, result: result, finalCompletion: completion) { (count, isCallAgain) in
                    if isCallAgain {
                        self.requestUserForgotOrResend(count: count, isForgot: isForgot, username: username, completion: completion)
                    }
                }
            }
        }
    }
     */
    /*
    func CheckIfJwtExpired(isFromBackground : Bool,token : String? = nil ,isLoaderEnabled : Bool = true ,kcompletion:@escaping  (Bool) -> Void)  {
        var jwtTokencurrent = ""
        if let token = token {
            jwtTokencurrent = token
        }else{
            jwtTokencurrent = userDefault.value(forKey: DefaultsKey.kJwtToken) as? String ?? ""
        }
        
        do {
            let calendar = Calendar.current
            let jwt = try decode(jwt: jwtTokencurrent)
            let expDate = jwt.expiresAt?.toLocalTime() ?? Date().toLocalTime()
            //            let issueDate = jwt.issuedAt ?? Date()
            let currentdate = Date().toLocalTime()
            let curTime = currentdate.timeIntervalSinceReferenceDate
            let expTime = expDate.timeIntervalSinceReferenceDate
            let diffMonth = calendar.dateComponents([.month], from: currentdate, to: expDate)
            let diffTime = expTime - curTime
            let expMinuts = Int(diffTime) / 60
            
            
            if expDate < currentdate || expMinuts <= 15 {
                if isFromBackground {
                    kcompletion(true)
                    return
                }
                self.requestRefreshToken(token: "",isLoaderEnabled: isLoaderEnabled) { (code,response, error,moyaResponse,progress) in
                    if error != nil {
                        Global.shared.onTapLogout()
                        kcompletion(true)
                        return
                    }
                    guard let response = response else {
                        Global.shared.onTapLogout()
                        kcompletion(true)
                        return
                    }
                    userDefault.setValue(response.jwttoken ?? "", forKey: DefaultsKey.kJwtToken)
                    userDefault.synchronize()
                    do {
                        let refreshJwt = try decode(jwt: response.jwttoken ?? "")
                        let refreshExpDate = refreshJwt.expiresAt?.toLocalTime() ?? Date().toLocalTime()
                        kcompletion(refreshExpDate < currentdate)
                    } catch {
                        kcompletion(true)
                        prin("\(error.localizedDescription )")
                    }
                }
            }
            else if diffMonth.month ?? 0 <= -1 {
                print("login Diff with month open login vc: \(diffMonth.month)")
                Global.shared.onTapLogout()
                kcompletion(true)
            }
            
            else {
                kcompletion(false)
            }
        }
        catch {
            kcompletion(true)
            prin("\(error.localizedDescription )")
        }
    }
    
    func IsNetworkAvail() -> Bool {
        let reachability = try! Reachability()
        var isReach = true
        if reachability.connection == .unavailable {
            isReach = false
        }
        return isReach
    }
    
    func processResponse<T>(_ isShowLoader:Bool = true ,progress: ProgressBlock? = .none ,count : Int = 0,isRetry : Bool = false,result: Result<Moya.Response, MoyaError>, finalCompletion: (Int,T?,ErrorModel?,Response?,ProgressBlock?) -> (), complition: @escaping((_ count: Int, _ isCallAgain: Bool)->Void)) where T: Codable {
        
        if !IsNetworkAvail(){
            finalCompletion(0,nil, .unknown(error: Global.shared.getinternationalizationValue(Key: ErrorMessage.kInternetError)),nil,progress)
            return
        }
        
        switch result {
        case .success(let response):
            let attemptCount = count + 1
            printResponce(jsonData: response.data)
            prin("Response Code ",response.response?.statusCode ?? 0)
            switch  response.statusCode {
            case 200...299:
                do {
                 
                    prin("Response MapJson: \(try response.mapJSON())")
                    let json = try JSONDecoder().decode(T.self, from: response.data)
                    finalCompletion(response.statusCode,json, nil,response,progress)
                    if isShowLoader {
                        self.hideIndicator()
                    }
                } catch  {
                    prin("Error 200: ",error.localizedDescription)
                    FirebaseLogHelper.crashEventWithDetail("200 error code", error as NSError)
                    finalCompletion(response.statusCode,nil, .unknown(error: error.localizedDescription),response,progress)
                    if isShowLoader {
                        self.hideIndicator()
                    }
                }
            case 401...499:
                
                if 408 == response.statusCode && isRetry{
                   
                    if attemptCount <= self.retryCount{
                        complition(attemptCount, attemptCount <= self.retryCount)
                        return
                    }
                }
                do {
                    let json = try JSONDecoder().decode(ErrorCodableModel.self, from: response.data)
                    if ischangePasswordAPI{
                        ischangePasswordAPI = false
                        finalCompletion(response.statusCode,nil, .unknown(error: json.errorCode ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong")),response,progress)
                    }else{
                        if  json.errorCode == "user.forbidden"{
                            finalCompletion(response.statusCode,nil, .unknown(error: Global.shared.getinternationalizationValue(Key: "user.forbidden")),response,progress)
                        }else{
                            finalCompletion(response.statusCode,nil, .unknown(error: json.message ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong")),response,progress)
                        }
                       
                    }
                    if isShowLoader {
                        self.hideIndicator()
                    }
                    FirebaseLogHelper.crashEventWithDetail(json.message ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong"))
                    prin("Error 401 ",json.message ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong"))
                } catch  {
                    prin("Error 401 catch ",error.localizedDescription)
                    FirebaseLogHelper.crashEventWithDetail("401 error code", error as NSError)
                    finalCompletion(response.statusCode,nil, .unknown(error: error.localizedDescription),response,progress)
                    if isShowLoader {
                        self.hideIndicator()
                    }
                }
            case 500...599:
                prin("Error 500 ")
                if (500 == response.statusCode) || (502 == response.statusCode) || (503 == response.statusCode) || (504 == response.statusCode) && isRetry{
                   
                    if attemptCount <= self.retryCount{
                        complition(attemptCount, attemptCount <= self.retryCount)
                        return
                    }
                }
                print(response)
                finalCompletion(response.statusCode,nil, .serverError,response,progress)
                if isShowLoader {
                    self.hideIndicator()
                }
            default:
                prin("Error default",Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong"))
                finalCompletion(response.statusCode,nil, .unknown(error: Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong")),response,progress)
                if isShowLoader {
                    self.hideIndicator()
                }
            }
        case .failure(let error):
            
            prin("Response Error ",error.localizedDescription)
            FirebaseLogHelper.crashEventWithDetail("Response eorror", error as NSError)
            finalCompletion(1,nil, .unknown(error: error.localizedDescription),nil,progress)
            if isShowLoader {
                self.hideIndicator()
            }
        }
    }
    
    func decodeStringResponse(data: Data) -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func processStringResponse(_ isShowLoader: Bool = true, progress: ProgressBlock? = .none, count: Int = 0, isRetry: Bool = false, result: Result<Moya.Response, MoyaError>, finalCompletion: (Int, String?, ErrorModel?, Response?, ProgressBlock?) -> (), completion: @escaping ((_ count: Int, _ isCallAgain: Bool) -> Void)) {
        if !IsNetworkAvail() {
            finalCompletion(0, nil, .unknown(error: ErrorMessage.kInternetError), nil, progress)
            return
        }

        switch result {
        case .success(let response):
            let attemptCount = count + 1
            printResponce(jsonData: response.data)
            prin("Response Code ", response.response?.statusCode ?? 0)
            switch response.statusCode {
            case 200...299:
                finalCompletion(response.statusCode, self.decodeStringResponse(data: response.data), nil, response, progress)
                if isShowLoader {
                    self.hideIndicator()
                }
            case 401...499:
                if 408 == response.statusCode && isRetry {
                    if attemptCount <= self.retryCount {
                        completion(attemptCount, attemptCount <= self.retryCount)
                        return
                    }
                }
                do {
                    let json = try JSONDecoder().decode(ErrorCodableModel.self, from: response.data)
                    if ischangePasswordAPI {
                        ischangePasswordAPI = false
                        finalCompletion(response.statusCode, nil, .unknown(error: json.errorCode ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong")), response, progress)
                    } else {
                        if json.errorCode == "user.forbidden" {
                            finalCompletion(response.statusCode, nil, .unknown(error: Global.shared.getinternationalizationValue(Key: "user.forbidden")), response, progress)
                        } else {
                            finalCompletion(response.statusCode, nil, .unknown(error: json.message ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong")), response, progress)
                        }
                    }
                    if isShowLoader {
                        self.hideIndicator()
                    }
                    FirebaseLogHelper.crashEventWithDetail(json.message ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong"))
                    prin("Error 401 ", json.message ?? Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong"))
                } catch {
                    prin("Error 401 catch ", error.localizedDescription)
                    FirebaseLogHelper.crashEventWithDetail("401 error code", error as NSError)
                    finalCompletion(response.statusCode, nil, .unknown(error: error.localizedDescription), response, progress)
                    if isShowLoader {
                        self.hideIndicator()
                    }
                }
            case 500...599:
                prin("Error 500 ")
                if (500 == response.statusCode) || (502 == response.statusCode) || (503 == response.statusCode) || (504 == response.statusCode) && isRetry {
                    if attemptCount <= self.retryCount {
                        completion(attemptCount, attemptCount <= self.retryCount)
                        return
                    }
                }
                print(response)
                finalCompletion(response.statusCode, nil, .serverError, response, progress)
                if isShowLoader {
                    self.hideIndicator()
                }
            default:
                prin("Error default", Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong"))
                finalCompletion(response.statusCode, nil, .unknown(error: Global.shared.getinternationalizationValue(Key: "uhOhSomethingWentWrong")), response, progress)
                if isShowLoader {
                    self.hideIndicator()
                }
            }
        case .failure(let error):
            prin("Response Error ", error.localizedDescription)
            FirebaseLogHelper.crashEventWithDetail("Response eorror", error as NSError)
            finalCompletion(1, nil, .unknown(error: error.localizedDescription), nil, progress)
            if isShowLoader {
                self.hideIndicator()
            }
        }
    }
     */
}
