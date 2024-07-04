import Combine
import Foundation

extension Publishers {
    private class CancelableSubscription<S: Subscriber, T, F>: Subscription where S.Input == T, S.Failure == F {
        private var subscriber: S?
        private let publisher: AnyPublisher<T, F>
        private let cancelPublisher: AnyPublisher<Void, Never>
        private var notificationCancelable: AnyCancellable?
        private var requestCancelable: AnyCancellable?
        
        init(
            publisher: AnyPublisher<T, F>,
            cancelPublisher: AnyPublisher<Void, Never>,
            subscriber: S
        ) {
            self.publisher = publisher
            self.cancelPublisher = cancelPublisher
            self.subscriber = subscriber
            cancelWhenResignActive()
            load()
        }
        
        /// Optionaly Adjust The Demand
        func request(
            _ demand: Subscribers.Demand
        ) { }
        
        func cancel() {
            subscriber?.receive(completion: .finished)
            subscriber = nil
            requestCancelable = nil
        }
        
        private func cancelWhenResignActive() {
            notificationCancelable = cancelPublisher
                .sink { [weak self] _ in
                    self?.cancel()
                }
        }
        
        private func load() {
            requestCancelable = publisher
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.subscriber?.receive(completion: completion)
                    },
                    receiveValue: { [weak self] value in
                        _ = self?.subscriber?.receive(value)
                    }
                )
        }
    }
    
    struct CancelableRequest<T, F: Error>: Publisher {
        
        typealias Output = T
        typealias Failure = F
        
        let publisher: AnyPublisher<T, F>
        let cancelPublisher: AnyPublisher<Void, Never>
        
        init(
            _ publisher: AnyPublisher<T, F>,
            cancelPublisher: AnyPublisher<Void, Never>
        ) {
            self.publisher = publisher
            self.cancelPublisher = cancelPublisher
        }
        
        func receive<S>(
            subscriber: S
        ) where S: Subscriber, Failure == S.Failure, T == S.Input {
            let subscription = CancelableSubscription(
                publisher: publisher,
                cancelPublisher: cancelPublisher,
                subscriber: subscriber
            )
            subscriber.receive(subscription: subscription)
        }
    }
}
