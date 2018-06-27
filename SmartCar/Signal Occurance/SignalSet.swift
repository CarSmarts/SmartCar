//
//  SignalSet.swift
//  CANHack
//
//  Created by Robert Smith on 6/19/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// Combined statisitics for a Signal, maps a signal to all the times it occured
public class SignalStat<S: Signal>: InstanceList {
    public let signal: S
    public private(set) var signalList: [SignalInstance<S>]
    
    fileprivate init(_ signal: S, signalList: [SignalInstance<S>] = []) {
        self.signal = signal
        self.signalList = signalList
    }
    
    public func add(newInstance: SignalInstance<S>) {
        signalList.append(newInstance)
    }
}

extension SignalStat: CustomStringConvertible {
    public var description: String {
        // 120x [Signal Description]
        return "\(timestamps.count)x \(signal)"
    }
}

/// A set of Signals, collected for the purpose of analysis
public class SignalSet<S: Signal>: InstanceList {
    public var _observers: [(SignalInstance<S>) -> Void] = []
    private var _stats: [S: SignalStat<S>]
    
    /// Sorted of signals in this set
    public private(set) var signals: [S]
    
    /// The original list of signals
    public private(set) var signalList: [SignalInstance<S>]
    
    /// Create a SignalSet from a list of signals
    public init(signalInstances: [SignalInstance<S>]) {
        // TODO: there are some expectations we should check?
        // Do we need to sort the incoming signal list, should be sorted by timestamp
        // Do we need to check if timestamps are unique
        // We get a speedup by skiping both, but we'll start to do strange things if these conditions don't hold true
        // TODO: TEST
        signalList = signalInstances
        
        _stats = [:]
        for instance in signalInstances {
            let signal = instance.signal
            if _stats[signal] == nil {
                _stats[signal] = SignalStat(signal)
            }
            
            _stats[signal]!.add(newInstance: instance)
        }
        
        self.signals = _stats.keys.sorted()
    }
}

/// SignalStat getters
extension SignalSet {
    /// Access a stat for a specific signal
    ///
    /// - traps if `signal` is not part of this classes `signals` array
    public subscript (_ signal: S) -> SignalStat<S> {
        return _stats[signal]!
    }
    
    /// All the stats in a Collection
    public var stats: LazyMapCollection<[S], SignalStat<S>> {
        return signals.lazy.map { self[$0] }
    }
}

/// appending messages
extension SignalSet {
    /// Add an incoming signal to the list
    public func add(_ newInstance: SignalInstance<S>) {
        signalList.append(newInstance)
        
        let signal = newInstance.signal
        
        if _stats[signal] == nil {
            // this is a new signal we haven't seen yet
            _stats[signal] = SignalStat(signal)
            
            signals.append(signal)
            signals.sort()
        }
        
        _stats[signal]!.add(newInstance: newInstance)
    }
}

// FIXME:
//extension SignalSet: CustomStringConvertible {
//    public var description: String {
//        return stats.map { $0.description }.joined(separator: "\n")
//    }
//}
