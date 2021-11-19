import Foundation
import RxSwift
import RxRelay

// replaced all instances of .error with .failure to conform to standard Result type (I hope?)

example(of: "just, of, from") {
    // 1
    let one = 1
    let two = 2
    let three = 3
    
    /// creates a sequence of a single element
    let observable = Observable<Int>.just(one)
    /// creates a sequence of Observable Int's - variadic parameter  `of` allows Type inference
    let observable2 = Observable.of(one, two, three)
    /// creatges a sequence of Observable Array of Int's [Int] :: The `just` operator can also take an array as a single element
    let observable3 = Observable.of([one, two, three])
    /// creates an observable sequence from an array of typed elements :: `from` only takes an array!-
    let observable4 = Observable.from([one, two, three])
}

/// Subscribing to an Observable - Observables will not send events, or perform any work until it has a subscriber.
example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe(onNext: { element in
        print(element)
    })
}

/// Creating an Observable of zero elements :: `empty` operator will only emit a completed event
example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        /// Handle Next Events
        onNext: { element in
            print(element)
        },
        /// Print a Messagbe because .completed event does not include an element
        onCompleted: {
            print("Completed")
        }
    )
}

/// as aposed to `empty` operator, the `never` operator creates an observable that doesn't emit anything and never terminates.
example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "range") {
    /// Create an Observable sequence using the range operator, which takes a start integer value and a count of sequential integers to generate.
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable
        .subscribe(onNext: { i in
            /// Calculate and print the nth Fibonacci number for each emitted element.
            let n = Double(i)
            
            let fibonacci = Int(
                ((pow(1.61803, n) - pow(0.61803, n)) /
                 2.23606).rounded()
            )
            
            print(fibonacci)
        })
}

example(of: "dispose") {
    /// Create an observable of Strings
    let observable = Observable.of("A", "B", "C")
    
    ///  Subscribe to the observable, this time saving the returned Disposable as a local constant called subscription.
    let subscription = observable.subscribe { event in
        /// Print each emitted event in handler
        print(event)
    }
    
    /// explicitly cancles a subscription or `dispose` of it
    subscription.dispose()
}

/// This is the most frequently used pattern...
/// Creating & Subscribing to an observable, and
/// immediately adding the subscription to a dispose bag
example(of: "DisposeBag") {
    /// create a dispose bag
    let disposeBag = DisposeBag()
    
    /// create an Observable
    Observable.of("A", "B", "C")
    /// subscribe to the observable and print out the emitted events using the default argument name $0.
        .subscribe {
            print($0)
        }
        /// Add the returned Doisposable from subscribe to the dispose bag
        .disposed(by: disposeBag)
}

example(of: "create") {
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        /// Add a next event onto the observer. onNext(_:) is a convenience method for on(.next(_:)).
        observer.onNext("1")
        
        //    observer.onError(MyError.anError)
        
        /// Add a completed event onto the observer. Similarly, onCompleted is a convenience method for on(.completed).
        //    observer.onCompleted()
        
        /// Add another next event onto the observer.
        observer.onNext("?")
        
        /// Return a disposable, defining what happens when your observable is terminated or disposed of; in this case, no cleanup is needed so you return an empty disposable.
        return Disposables.create()
    }
    .subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
    )
    .disposed(by: disposeBag)
}

/// observable factories
example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    /// Creat a Bool flag to flip which observable to return
    var flip = false
    
    /// Creat an observable of INt factory using the deferred operator
    let factory: Observable<Int> = Observable.deferred {
        
        /// Toggle flip, which happens each time factory is subscribed to
        flip.toggle()
        
        /// Return different observables based on whether flip is true or false
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
            .disposed(by: disposeBag)
        
        print()
    }
}

/// Loading text from a text file named Copyright.txt
example(of: "Single") {
    /// Create a dispose bag to use later
    let disposeBag = DisposeBag()
    /// Define an Error enum to model some possible errors that can occur in reading data from a file on a disk
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    /// Implement a function to load text from a file on disk that returns a Single
    func loadText(from name: String) -> Single<String> {
        /// Create and return a Single
        return Single.create { single in
            /// create a disposable, because the subscribe closure of create expects it as its return type.
            let disposable = Disposables.create()
            
            /// get the path for the filename, or else add a file not found error onto the Single and return the disposable you created
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.failure(FileReadError.fileNotFound))
                return disposable
            }
            
            /// get the data from the file at that path, or add an unreadable error onto the Single and return the disposable
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.failure(FileReadError.unreadable))
                return disposable
            }
            
            /// Convert the data to a string: otherwise, add an encoding failed error onto the Single and return disposable
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.failure(FileReadError.encodingFailed))
                return disposable
            }
            
            /// Add the contents onto the Single as a Success, and return the disposable.
            single(.success(contents))
            return disposable
        }
    }
    
    /// Call loadText(from:) and pass the root name of the text file
    loadText(from: "Copyright")
    /// Subscribe to the single it returns
        .subscribe {
            /// Switch on the event and print the string if it was successful, or print the error if failure
            switch $0 {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
}

example(of: "Challenge") {
    let observable = Observable<Any>.never()
    let disposeBag = DisposeBag()
    
    observable
        .debug("Observable")
        .do(onSubscribe: {
            print("Subscribed")
        })
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            }
        )
        .disposed(by: disposeBag)
}


