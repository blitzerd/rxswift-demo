//: [Previous](@previous)

import Foundation
import RxSwift
import RxRelay

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    subject.on(.next("1"))
    /// shortcut syntax
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    subject.onNext("3")
    
    subscriptionOne.dispose()
    
    subject.onNext("4")
    
    /// Add a completed event onto the subject, using the convenience method for on(.completed). This terminates the subject’s observable sequence.
    subject.onCompleted()
    
    /// Add another element onto the subject. This won’t be emitted and printed, though, because the subject has already terminated.
    subject.onNext("5")
    
    /// Dispose of the subscription
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    /// Subscribe to the subject, this time adding its disposable to a dispose bag
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
}

/// define an error type to use in upcoming examples
enum MyError: Error {
    case anError
}

/// expanding upon the use of ternary operator in previous example, you create a helper function
/// to print the element if there is one, an error if there is one, or else the event itself.
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

/// start a new example - BehaviorSubject prints the latest element when the subscription is made
example(of: "BehaviorSubject") {
    /// create a new BehaviorSubject instance. It's initializer takes an initial value
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    subject.onNext("X")
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    /// add an error event on the subject
    subject.onError(MyError.anError)
    
    /// create a new subscription to the subject
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "ReplaySubject") {
    /// create a new replay subject with a buffer size of 2, ReplaySubjects are initialized using the type method .create(bufferSize:)
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    /// Add three elements onto the subject
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    /// create two subscriptions to the subject
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    subject.onError(MyError.anError)
//    subject.dispose()
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    relay.accept("Knock knock, anyone home?")
    
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1")
}

example(of: "BehaviorRelay") {
    // 1
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    // 2
    relay.accept("New initial value")
    
    // 3
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    relay.accept("1")
    
    // 2
    relay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 3
    relay.accept("2")
    
    print(relay.value)
}

//: [Next](@next)
