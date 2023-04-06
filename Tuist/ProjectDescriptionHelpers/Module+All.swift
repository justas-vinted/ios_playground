import Foundation

extension Module {
    public static let allModules: [Module] = {
        var count: CUnsignedInt = 0
        let methods = class_copyPropertyList(object_getClass(Module.self), &count)!
        var results: [Module] = []
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
