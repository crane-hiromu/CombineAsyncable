//
//  Publisher+Task.swift
//  
//
//  Created by h.tsuruta on 2022/10/06.
//

#if compiler(>=5.5) && canImport(_Concurrency)
import Combine

// MARK: - Publisher Extension (Never)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Self.Failure == Never {
    
    /// Example
    ///
    /// Just<Int>(99)
    ///   .sink { number in
    ///     // do some task
    ///   }
    ///   .store(in: &cancellable)
    ///
    func sink(
        receiveValue: @escaping ((Self.Output) async -> Void)
    ) -> AnyCancellable {
        self.sink { value in
            Task {
                await receiveValue(value)
            }
        }
    }
}

// MARK: - Publisher Extension (Error)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Self.Failure == Error {
    
    /// Example
    ///
    /// Just<Int>(99)
    ///   .setFailureType(to: Error.self)
    ///   .sinkWithThrows(receiveCompletion: { result in
    ///     // do some resut handling task
    ///   }, receiveValue: { value in
    ///     // do some value handling task
    ///   })
    ///   .store(in: &cancellable)
    ///
    func sinkWithThrows(
        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) async throws -> Void),
        receiveValue: @escaping ((Self.Output) async throws -> Void)
    ) -> AnyCancellable {
        self.sink(
            receiveCompletion: { result in
                Task {
                    try await receiveCompletion(result)
                }
            },
            receiveValue: { value in
                Task {
                    try await receiveValue(value)
                }
            }
        )
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher {
    
    /// Example
    ///
    /// Just<Int>(99)
    ///   .asyncMap { number in
    ///     // do some task
    ///   }
    ///   .sink { number in
    ///     // do some handling
    ///   }
    ///   .store(in: &cancellable)
    ///
    func asyncMap<V>(
        _ asyncFunction: @escaping (Output) async -> V
    ) -> Publishers.FlatMap<Future<V, Never>, Self> {
        
        flatMap { value in
            Future { promise in
                Task {
                    promise(.success(await asyncFunction(value)))
                }
            }
        }
    }
    
    /// Example
    /// 
    /// URL(string: "https....")
    ///   .publisher
    ///   .compactMap { $0 }
    ///   .asyncMapWithThrows {
    ///     try await URLSession.shared.data(from: $0)
    ///   }
    ///   .sink(receiveCompletion: { result in
    ///     // do some result handling task
    ///   }, receiveValue: { value in
    ///     // do some value handling task
    ///   })
    /// .store(in: &cancellable)
    ///
    func asyncMapWithThrows<V>(
        _ transform: @escaping (Output) async throws -> V
    ) -> Publishers.FlatMap<Future<V, Error>, Publishers.SetFailureType<Self, Error>> {
        
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

#endif
