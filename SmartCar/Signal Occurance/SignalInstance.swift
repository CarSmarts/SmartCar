//
//  SignalInstance.swift
//  SmartCar
//
//  Created by Robert Smith on 11/14/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// Super vague, but a `Signal` is anything that could be associated with "happening" at a certain time
public protocol Signal: Hashable, CustomStringConvertible, Comparable, Codable { }

/// When a `Signal` "happened"
public typealias Timestamp = Int

/// Ties a Signal to a specific Timestamp
public struct SignalInstance<S: Signal>: Hashable, Codable {
    var signal: S
    var timestamp: Timestamp
}

extension SignalInstance: CustomStringConvertible {
    public var description: String {
        return "\(timestamp) \(signal)"
    }
}

/// List of SignalInstance sorted by timestamp
public class SignalList<S: Signal>: SortedArray<SignalInstance<S>> {
    public init(_ array: [Element] = []) {
        super.init(sorting: array) { $0.timestamp < $1.timestamp }
    }
}

/// Anything that has a list of signalInstances...
public protocol InstanceList {
    associatedtype S: Signal
    
    var signalList: SignalList<S> { get }
}

/// ...should also have a list of Timestamps
extension InstanceList {
    /// The first timestamp in this dataset
    public var firstTimestamp: Timestamp {
        return timestamps.first ?? 0
    }
    
    /// The last timestamp in this dataset
    public var lastTimestamp: Timestamp {
        return timestamps.last ?? 0
    }
    
    public var timestamps: [Timestamp] {
        return signalList.lazy.map { $0.timestamp }
    }
}

// TODO: Move this?
/// Allow Any InstanceList to be graphed
extension InstanceList {
    public var scale: OccuranceGraphScale {
        return OccuranceGraphScale(min: firstTimestamp, max: lastTimestamp)
    }
}

