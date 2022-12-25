//
//  Future+Task.swift
//  
//
//  Created by h.tsuruta on 2022/10/06.
//

#if compiler(>=5.5) && canImport(_Concurrency)
import Combine

// MARK: - Future Extension (Never)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Future where Failure == Never {

    /// Example
    ///
    /// func exec() -> Future<(), Never> {
    ///   Future {
    ///     await callAsyncFunction()
    ///   }
    /// }
    ///
    convenience init(
        priority: TaskPriority? = nil,
        operation: @escaping () async -> Output
    ) {
        self.init { promise in
            Task(priority: priority) {
                try? Task.checkCancellation()
                let result = await operation()
                promise(.success(result))
            }
        }
    }
}

// MARK: - Future Extension (Error)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Future where Failure == Error {

    /// Example
    ///
    /// func exec() -> Future<(), Error> {
    ///   Future {
    ///     try await callAsyncThrowsFunction()
    ///   }
    /// }
    /// 
    convenience init(
        priority: TaskPriority? = nil,
        operation: @escaping () async throws -> Output
    ) {
        self.init { promise in
            Task(priority: priority) {
                try Task.checkCancellation()
                do {
                    let result = try await operation()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

#endif
