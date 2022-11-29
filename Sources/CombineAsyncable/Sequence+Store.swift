//
//  Sequence+Store.swift
//  
//
//  Created by h.tsuruta on 2022/11/15.
//

#if compiler(>=5.5)
import Combine

// MARK: - Sequence Extension
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Sequence where Element == AnyCancellable {
    
    /// Stores this type-erasing cancellable collection in the specified collection.
    ///
    /// - Parameter collection: The collection in which to store this ``AnyCancellable`` sequence.
    func store<C>(
        in collection: inout C
    ) where C: RangeReplaceableCollection, C.Element == Element {
        forEach { $0.store(in: &collection) }
    }

    /// Stores this type-erasing cancellable collection in the specified set.
    ///
    /// - Parameter set: The set in which to store this ``AnyCancellable`` sequence.
    func store(in set: inout Set<Element>) {
        forEach { $0.store(in: &set) }
    }
    
    /// Cancel all AnyCancellable
    func cancel() {
        forEach { $0.cancel() }
    }
}

#endif
