//
//  Publisher+Task.swift
//  
//
//  Created by h.tsuruta on 2022/10/06.
//

#if compiler(>=5.5)
import Combine

// MARK: - AnyCancellable Extension
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AnyCancellable {
    
    func cancel(completion: @escaping () -> Void) -> AnyCancellable {
        .init { completion() }
    }
}

#endif
