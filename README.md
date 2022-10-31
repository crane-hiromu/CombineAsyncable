# CombineAsyncable

## Description

It bridges from Combine to Concurrency.

A small set of extensions that allow to combine new swift concurrency with Combine.

[Here](https://qiita.com/hcrane/items/dd7d1cbe5a3d2acfe252) are the details in Japanese.


## Operator

### .asyncMap

```.swift
Just<Int>(10)
    .asyncMap { number in
        await doSomething(number)
    }
    .sink { value in
        // handle value
    }
    .store(in: &cancellable)
```


### .asyncMapWithThrows

```.swift
let subject = PassthroughSubject<(), Never>()

subject
    .asyncMapWithThrows {
        try await APIClient.fetch()
    }
    .sink(receiveCompletion: { result in
        // handle result
    }, receiveValue: { value in
        // handle value
    })
    .store(in: &cancellable)

subject.send(())
```

### .asyncSink

```.swift
Just<Int>(10)
    .sink { number in
        await doSomething(number)
    }
    .store(in: &cancellable)
```

### .asyncSinkWithThrows

```.swift
let subject = PassthroughSubject<(), Never>()

subject
    .setFailureType(to: Error.self)
    .asyncSinkWithThrows(receiveCompletion: { result in
        // handling result
    }, receiveValue: {
        let response = try await APIClient.fetch()
        // handling response
    })
    .store(in: &cancellable)

subject.send(())
```

### Swift Package Manager

Add the following dependency to your Package.swift file:

```
.package(url: "https://github.com/crane-hiromu/CombineAsyncable", "0.2.0"..<"1.0.0")
```

### License

MIT, of course ;-) See the LICENSE file.
