import Foundation

extension Module {
    public static let allModules: [Module] = {
        var count: CUnsignedInt = 0
        var results: [Module] = []
        guard let methods = class_copyPropertyList(object_getClass(Module.self), &count) else {
            return results
        }
   
        for i in 0..<count {
            let selector = property_getName(methods.advanced(by: Int(i)).pointee)
            if let key = String(cString: selector, encoding: .utf8) {
                if let res = Module.value(forKey: key) as? Module {
                    results.append(res)
                }

            }
        }
        return results
    }()
}
