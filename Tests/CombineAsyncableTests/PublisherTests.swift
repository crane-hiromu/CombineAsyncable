#if canImport(Combine)

import XCTest
import Combine
@testable import CombineAsyncable

// MARK: - XCTestCase
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class PublisherTests: XCTestCase {
 
    // MARK: Test
    
    func testAsyncSink() async {
        let exp = expectation(description: "wait for asyncSink")
        let subject = PassthroughSubject<Void, Never>()
        var cancellables = Set<AnyCancellable>()
        
        subject.asyncSink(priority: .background) {
            // check status when starting
            XCTAssertFalse(Task.isCancelled)
            // wait `cancel()` method
            try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            // check status after canceling
            XCTAssertTrue(Task.isCancelled)
            // end task
            exp.fulfill()
        }.store(in: &cancellables)
        
        // exec
        subject.send(())
        // wait 1 seconds to cancel
        sleep(1)
        cancellables.cancel()
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func testAsyncSinkWithObject() async {
        // test: cancel
        do {
            let exp = expectation(description: "wait for asyncSink")
            
            let mock = ObjectMock { exp.fulfill() }
            mock.subject.send(())
            mock.cancellables.forEach { $0.cancel() }
            sleep(1)
            XCTAssertTrue(mock.methodCalled)
            
            wait(for: [exp], timeout: 2)
        }
        // test: object is nil
        do {
            let exp = expectation(description: "wait for asyncSink")
            exp.isInverted = true
            
            var mock: ObjectMock? = .init { exp.fulfill() }
            mock?.subject.send(())
            mock = nil
            sleep(1)
            XCTAssertNil(mock?.methodCalled)
            
            wait(for: [exp], timeout: 2)
        }
    }
}

// MARK: - Mock
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
private final class ObjectMock {
    
    // MARK: Test flag
    
    private(set) var methodCalled = false
    func callAsync(completion: @escaping () -> Void) async {
        methodCalled = true
        completion()
    }
    
    // MARK: Implementation
    
    let subject = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()

    init(completion: @escaping () -> Void) {
        subject.asyncSink(priority: .background) { [weak self] in
            guard let self = self else { return }
            await self.callAsync(completion: completion)
        }.store(in: &cancellables)
    }
}

#endif
