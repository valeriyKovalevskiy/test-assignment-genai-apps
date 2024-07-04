import Combine
import Foundation

typealias RetryPredicate = (Error) -> Bool

/**
 Provides the retry behavior that will be used - the number of retries and the delay between two subsequent retries.
 - `.immediate`: It will immediatelly retry for the specified retry count
 - `.delayed`: It will retry for the specified retry count, adding a fixed delay between each retry
 - `.exponentialDelayed`: It will retry for the specified retry count.
 The delay will be incremented by the provided multiplier after each iteration
 (`multiplier = 0.5` corresponds to 50% increase in time between each retry)
 - `.custom`: It will retry for the specified retry count. The delay will be calculated by the provided custom closure.
 The closure's argument is the current retry
 */
enum RetryBehavior<S> where S: Scheduler {
    case immediate(retries: UInt)
    case delayed(retries: UInt, time: TimeInterval)
    case exponentialDelayed(retries: UInt, initial: TimeInterval, multiplier: Double)
    case custom(retries: UInt, delayCalculator: (UInt) -> TimeInterval)
}

private extension RetryBehavior {
    
    func calculateConditions(
        _ currentRetry: UInt
    ) -> (maxRetries: UInt, delay: S.SchedulerTimeType.Stride) {
        
        switch self {
        case let .immediate(retries):
            // If immediate, returns 0.0 for delay
            return (maxRetries: retries, delay: .zero)
            
        case let .delayed(retries, time):
            // Returns the fixed delay specified by the user
            return (maxRetries: retries, delay: .seconds(time))
            
        case let .exponentialDelayed(retries, initial, multiplier):
            // If it is the first retry the initial delay is used, otherwise it is calculated
            let delay = currentRetry == 1 ? initial : initial * pow(1 + multiplier, Double(currentRetry - 1))
            return (maxRetries: retries, delay: .seconds(delay))
            
        case let .custom(retries, delayCalculator):
            // Calculates the delay with the custom calculator
            return (maxRetries: retries, delay: .seconds(delayCalculator(currentRetry)))
        }
        
    }
}

extension Publisher {
    /// Insets or removes event when receiveSubscription and receiveOutput events triggered.
    /// Holds weak reference to the model
    func handleLoading<T: Hashable, Model: AnyObject>(
        in model: Model,
        keyPath: WritableKeyPath<Model, Set<T>>,
        event: T
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { [weak model] _ in model?[keyPath: keyPath].insert(event) },
            receiveOutput: { [weak model] _ in model?[keyPath: keyPath].remove(event) },
            receiveCompletion: { [weak model] _ in model?[keyPath: keyPath].remove(event) },
            receiveCancel: { [weak model] in model?[keyPath: keyPath].remove(event) }
        )
    }
    
    func sinkValue(
        onReceive: @escaping ((Self.Output) -> Void)
    ) -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: onReceive)
    }
    
    /// A single value sink function that coalesces either one `Output` or one `Failure` as a `Result`-type.
    func sinkResult(
        result: @escaping (Result<Self.Output, Self.Failure>) -> Void
    ) -> AnyCancellable {
        sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                result(.failure(error))
            case .finished:
                break
            }
        }, receiveValue: { output in
            result(.success(output))
        })
    }
    
    /**
     Retries the failed upstream publisher using the given retry behavior.
     - parameter behavior: The retry behavior that will be used in case of an error.
     - parameter shouldRetry: An optional custom closure which uses the downstream error to determine
     if the publisher should retry.
     - parameter tolerance: The allowed tolerance in firing delayed events.
     - parameter scheduler: The scheduler that will be used for delaying the retry.
     - parameter options: Options relevant to the scheduler’s behavior.
     - returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
     */
    func retry<S>(
        behavior: RetryBehavior<S>,
        shouldRetry: RetryPredicate? = nil,
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> AnyPublisher<Output, Failure> where S: Scheduler {
        return retry(
            1,
            behavior: behavior,
            shouldRetry: shouldRetry,
            tolerance: tolerance,
            scheduler: scheduler,
            options: options
        )
    }
    
    private func retry<S>(
        _ currentAttempt: UInt,
        behavior: RetryBehavior<S>,
        shouldRetry: RetryPredicate? = nil,
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> AnyPublisher<Output, Failure> where S: Scheduler {
        
        // This shouldn't happen, in case it does we finish immediately
        guard currentAttempt > 0 else { return Empty<Output, Failure>().eraseToAnyPublisher() }
        
        // Calculate the retry conditions
        let conditions = behavior.calculateConditions(currentAttempt)
        
        return self.catch { error -> AnyPublisher<Output, Failure> in
            
            // If we exceed the maximum retries we return the error
            guard currentAttempt <= conditions.maxRetries else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            
            if let shouldRetry = shouldRetry, shouldRetry(error) == false {
                // If the shouldRetry predicate returns false we also return the error
                return Fail(error: error).eraseToAnyPublisher()
            }
            
            guard conditions.delay != .zero else {
                // If there is no delay, we retry immediately
                return self.retry(
                    currentAttempt + 1,
                    behavior: behavior,
                    shouldRetry: shouldRetry,
                    tolerance: tolerance,
                    scheduler: scheduler,
                    options: options
                )
                .eraseToAnyPublisher()
            }
            
            // We retry after the specified delay
            return Just(()).delay(for: conditions.delay, tolerance: tolerance, scheduler: scheduler, options: options).flatMap {
                self.retry(
                    currentAttempt + 1,
                    behavior: behavior,
                    shouldRetry: shouldRetry,
                    tolerance: tolerance,
                    scheduler: scheduler,
                    options: options
                )
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
}
