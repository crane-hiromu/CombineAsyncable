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
    /// let subject = PassthroughSubject<Void, Never>()
    ///
    /// var cancellable = subject.asyncSink { in
    ///   await callAsyncFunction()
    /// }
    ///
    /// subject.send(())
    ///
    func asyncSink(
        priority: TaskPriority? = nil,
        receiveValue: @escaping ((Self.Output) async -> Void)
    ) -> Set<AnyCancellable> {
        var set = Set<AnyCancellable>()
        var task: Task<Void, Never>?
        
        let cancellable = self.sink { value in
            task = Task(priority: priority) {
                try? Task.checkCancellation()
                await receiveValue(value)
            }
        }
        
        // store cancellable to prevent from canceling stream
        cancellable
            .store(in: &set)
        
        // generate task cancellable
        cancellable
            .cancel { task?.cancel() }
            .store(in: &set)
        
        return set
    }
}

// MARK: - Publisher Extension (Error)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Self.Failure == Error {
    
    /// Example
    ///
    /// Just<Int>(99)
    ///   .setFailureType(to: Error.self)
    ///   .asyncSinkWithThrows(receiveCompletion: { result in
    ///     try await callAsyncThrowsFunction()
    ///   }, receiveValue: { value in
    ///     try await callAsyncThrowsFunction()
    ///   })
    ///   .store(in: &cancellable)
    ///
    func asyncSinkWithThrows(
        receiveCompletionPriority: TaskPriority? = nil,
        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) async throws -> Void),
        receiveValuePriority: TaskPriority? = nil,
        receiveValue: @escaping ((Self.Output) async throws -> Void)
    ) -> AnyCancellable {
        var tasks = [Task<Void, Error>]()
        let cancellable: AnyCancellable = self.sink(
            receiveCompletion: { result in
                tasks.append(Task(priority: receiveCompletionPriority) {
                    try Task.checkCancellation()
                    try await receiveCompletion(result)
                })
            },
            receiveValue: { value in
                tasks.append(Task(priority: receiveValuePriority) {
                    try Task.checkCancellation()
                    try await receiveValue(value)
                })
            }
        )
        return cancellable.cancel {
            tasks.forEach { $0.cancel() }
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher {
    
    /// Example
    ///
    /// Just<Int>(99)
    ///   .asyncMap { number in
    ///     await callAsyncFunction(number)
    ///   }
    ///   .sink { number in
    ///     // do some handling
    ///   }
    ///   .store(in: &cancellable)
    ///
    func asyncMap<V>(
        priority: TaskPriority? = nil,
        _ asyncFunction: @escaping (Output) async -> V
    ) -> Publishers.FlatMap<Future<V, Never>, Self> {
        
        flatMap { value in
            Future(priority: priority) {
                await asyncFunction(value)
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
        priority: TaskPriority? = nil,
        _ asyncFunction: @escaping (Output) async throws -> V
    ) -> Publishers.FlatMap<Future<V, Error>, Publishers.SetFailureType<Self, Error>> {
        
        flatMap { value in
            Future(priority: priority) {
                try await asyncFunction(value)
            }
        }
    }
}

#endif
