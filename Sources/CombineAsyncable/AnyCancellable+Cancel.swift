//
//  Publisher+Task.swift
//  
//
//  Created by h.tsuruta on 2022/10/06.
//

#if compiler(>=5.5)
import Combine

// MARK: - AnyCancellable Extension
extension AnyCancellable {
    
    func cancel(completion: @escaping () -> Void) -> AnyCancellable {
        .init { completion() }
    }
}

#endif
