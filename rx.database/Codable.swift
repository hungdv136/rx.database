//
//  Codable.swift
//  rx.flux
//
//  Created by Hung Dinh Van on 6/26/17.
//  Copyright © 2017 ChuCuoi. All rights reserved.
//

import Foundation

public typealias Coder = NSCoder

public protocol Codable {
    init?(coder: Coder)
    func encode(with coder: Coder)
}

extension Codable {
    public var archivedData: Data {
        return NSKeyedArchiver.archivedCodableData(withRootObject: self)
    }
    
    public static func from(_ data: Data) -> Self? {
        return NSKeyedUnarchiver.unarchiveCodableObject(with: data)
    }
}

private final class CoderHelper<T: Codable>: NSObject, NSCoding {
    init(object: T) {
        self.object = object
        super.init()
    }
    
    @objc required init?(coder aDecoder: Coder) {
        super.init()
        object = T(coder: aDecoder)
    }
    
    @objc func encode(with coder: Coder) {
        if let object = object {
            object.encode(with: coder)
        }
    }
    
    fileprivate var object: T?
}

extension NSKeyedArchiver {
    public static func archivedCodableData<T: Codable>(withRootObject object: T) -> Data {
        let helper = CoderHelper(object: object)
        return archivedData(withRootObject: helper)
    }
    
    public static func archivedCodableData<T: Codable>(withRootObject objects: [T]) -> Data {
        let helpers = objects.map { CoderHelper(object: $0) }
        return archivedData(withRootObject: helpers)
    }
}

extension NSKeyedUnarchiver {
    public static func unarchiveCodableObject<T: Codable>(with data: Data) -> T? {
        setClass(CoderHelper<T>.self, forClassName: String(describing: T.self))
        let helper = NSKeyedUnarchiver.unarchiveObject(with: data) as? CoderHelper<T>
        return helper?.object
    }
    
    public static func unarchiveCodableObject<T: Codable>(with data: Data) -> [T]? {
        setClass(CoderHelper<T>.self, forClassName: String(describing: T.self))
        guard let helpers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CoderHelper<T>] else {
            return nil
        }
        return helpers.flatMap { $0.object }
    }
}

extension Coder {
    //MARK: Single
    
    public func decodeCodableObject<T: Codable>(forKey key: String) -> T? {
        setType(T.self)
        guard let helper = decodeObject(forKey: key) as? CoderHelper<T> else {
            return nil
        }
        return helper.object
    }
    
    public func encodeCodable<T: Codable>(_ object: T?, forKey key: String) {
        guard let object = object else { return }
        let helper = CoderHelper(object: object)
        encode(helper, forKey: key)
    }
    
    //MARK: Array
    
    public func decodeCodableObject<T: Codable>(forKey key: String) -> [T]? {
        setType(T.self)
        guard let helpers = decodeObject(forKey: key) as? [CoderHelper<T>] else {
            return nil
        }
        return helpers.flatMap { $0.object }
    }
    
    public func encodeCodable<T: Codable>(_ object: [T]?, forKey key: String) {
        guard let object = object else { return }
        encodeCodable(object, forKey: key)
    }
    
    public func encodeCodable<T: Codable>(_ object: [T], forKey key: String) {
        let helpers = object.map { CoderHelper(object: $0) }
        encode(helpers, forKey: key)
    }
    
    //MARK: Set
    
    public func decodeCodableObject<T: Codable>(forKey key: String) -> Set<T>? {
        guard let objects: [T] = decodeCodableObject(forKey: key) else {
            return nil
        }
        return Set(objects)
    }
    
    public func encodeCodable<T: Codable>(_ object: Set<T>?, forKey key: String) {
        guard let object = object else { return }
        encodeCodable(object, forKey: key)
    }
    
    public func encodeCodable<T: Codable>(_ object: Set<T>, forKey key: String) {
        let helpers = object.map { CoderHelper(object: $0) }
        encode(helpers, forKey: key)
    }
    
    //MARK: Dictionary
    
    public func decodeCodableObject<T: Codable>(forKey key: String) -> [String: T]? {
        setType(T.self)
        guard let helpers = decodeObject(forKey: key) as? [String: CoderHelper<T>] else {
            return nil
        }
        return helpers.flatMapValues { $0.object }
    }
    
    public func encodeCodable<T: Codable>(_ object: [String: T]?, forKey key: String) {
        guard let object = object else { return }
        encodeCodable(object, forKey: key)
    }
    
    public func encodeCodable<T: Codable>(_ object: [String: T], forKey key: String) {
        let dict = object.mapValues { CoderHelper(object: $0) }
        encode(dict, forKey: key)
    }
    
    //MARK: Private
    
    private func setType<T: Codable>(_ type: T.Type) {
        (self as? NSKeyedUnarchiver)?.setClass(CoderHelper<T>.self, forClassName: String(describing: T.self))
    }
}
