import Foundation

public protocol NetworkService {
    associatedtype RequestObject
    associatedtype ErrorType: Swift.Error
    
    func send(
        _ request: Request,
        onSuccess successClosure:@escaping (Any) -> Void,
        onFail failClosure: @escaping (ErrorType) -> Void
    )
    
    func cancelAllRequests()
}
