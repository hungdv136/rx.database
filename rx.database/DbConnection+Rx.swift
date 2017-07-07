//
//  DataConnection+Rx.swift
//  rx.flux
//
//  Created by Hung Dinh Van on 6/26/17.
//  Copyright © 2017 ChuCuoi. All rights reserved.
//

import RxSwift

public struct DbConnectionReactive {
    fileprivate let base: DbConnection
}

extension DbConnection {
    public var rx: DbConnectionReactive {
        return DbConnectionReactive(base: self)
    }
}

extension DbConnectionReactive {
    public func read<T>(_ block: @escaping (ReadTransaction) -> T) -> Observable<T> {
        return Observable.create { observer in
            var result: T!
            self.base.asyncRead({ tx in
                result = block(tx)
            }, completion: {
                observer.onNext(result)
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    public func write(_ block: @escaping (WriteTransaction) -> Void) -> Observable<Void> {
        return Observable.create { observer in
            self.base.asyncWrite(block) {
                observer.onNext()
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
