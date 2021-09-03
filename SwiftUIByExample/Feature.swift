//
//  Feature.swift
//  Feature
//
//  Created by Jason Jobe on 9/3/21.
//

//import Foundation
import SwiftUI

// https://davedelong.com/blog/2021/04/02/custom-property-wrappers-for-swiftui/

public class Features: ObservableObject {
    public static let shared = Features()
    private init() { }
    
    @Published public var isDebugMenuEnabled = false
}

@propertyWrapper
public struct Feature<T>: DynamicProperty {
    @ObservedObject private var features: Features
    
    private let keyPath: KeyPath<Features, T>
    
    public init(_ keyPath: KeyPath<Features, T>, features: Features = .shared) {
        self.keyPath = keyPath
        self.features = features
    }
    
    public var wrappedValue: T {
        return features[keyPath: keyPath]
    }
}

