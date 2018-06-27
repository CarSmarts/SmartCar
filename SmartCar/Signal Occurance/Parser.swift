//
//  Parser.swift
//  SmartCar
//
//  Created by Robert Smith on 6/17/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import Foundation

protocol Parser {
    associatedtype S: Signal
    
    /// Main important function
    func parse(line: String) -> SignalInstance<S>?
    
    /// Has default implementation
    func parse(from file: URL) -> SignalSet<S>
}

extension Parser {
    func parse(from file: URL) -> SignalSet<S> {
        
        guard let data = try? String(contentsOf: file) else {
            Logger.error("Trying to decode chosen file")
            return SignalSet<S>(signalInstances: [])
        }

        let lines = data.components(separatedBy: .newlines)

        // map every line into a parsed message
        let parsed = lines.compactMap { line -> SignalInstance<S>? in
            return parse(line: line)
        }
        
        return SignalSet<S>(signalInstances: parsed)
    }

}
