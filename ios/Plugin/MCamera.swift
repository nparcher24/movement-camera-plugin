import Foundation

@objc public class MCamera: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    @objc public func showCamera(_ testValue: String) {
        print("CALLED SHOWCAMERA ON NATIVE")
        print(testValue)
    }
    
    @objc public func updateUI(goodReps: Int, badReps: Int, time: Int) {
        print("Good Reps: ",  goodReps , ", Bad Reps: ",  badReps,  ", Time: ",  time)
    }
}
