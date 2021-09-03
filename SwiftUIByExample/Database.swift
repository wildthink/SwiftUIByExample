//
//  Database.swift
//  Database
//
//  Created by Jason Jobe on 9/3/21.
//
import Foundation

public protocol Queryable {
    associatedtype Filter: QueryFilter
    init(result: Filter.ResultType)
}

public protocol QueryFilter: Equatable {
    associatedtype ResultType: Any
    func fetchRequest(_ dataStore: DataStore) -> FetchRequest<ResultType>
}

public struct FetchRequest<ResultType> {
    
    var entity: String = "<entity>"
    var resultType: ResultType.Type { ResultType.self }
    
    var predicate: NSPredicate?
    var sorts: NSSortDescriptor?
    
    var fetchLimit: Int = 0
    var batchSize: Int = 0
    var fetchOffset: Int = 0
}

public struct QueryResults<T: Queryable>: RandomAccessCollection {
    private let results: NSArray
    
    internal init(results: NSArray = NSArray()) {
        self.results = results
    }
    
    public var count: Int { results.count }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public subscript(position: Int) -> T {
        let object = results.object(at: position) as! T.Filter.ResultType
        return (object as? T) ?? T(result: object)
    }
}

public struct Filter {
    
}


public class DataStore: ObservableObject {
    var name: String = "Dave's Store"
    var datasets: [String: [Any]] = [:]
    
    func fetch<Q: QueryFilter>(filter: Q) -> [Q.ResultType] {
        let key = "\(type(of: Q.ResultType.self))"
        return (datasets[key] as? [Q.ResultType]) ?? []
    }

    @discardableResult
    func insert<A: Any>(_ elementType: A.Type = A.self, data: [A]) -> Self {
        let key = "\(type(of: elementType))"
        datasets[key] = data
        return self
    }
}

extension Query {
    private class Core: ObservableObject {
//        private(set) var results: QueryResults<T> = QueryResults()
        var results = QueryResults<T>()
        var dataStore: DataStore?
        var filter: T.Filter?

        func executeQuery(dataStore: DataStore, filter: T.Filter) {
//            print (#function, dataStore.name)
            fetchIfNecessary()
//            let fetchRequest = filter.fetchRequest(dataStore)
//            let context = dataStore.viewContext
            
            // you MUST leave this as an NSArray
//            let results: NSArray = (try? context.fetch(fetchRequest)) ?? NSArray()
//            let results = NSArray()
//            self.results = QueryResults(results: results)
        }
        
        func fetchIfNecessary() {
            guard let ds = dataStore else {
                fatalError("Attempting to execute a @Query but the DataStore is not in the environment")
            }
            guard let f = filter else {
                fatalError("Attempting to execute a @Query without a filter")
            }
            
//            print (#function, ds.name)

            let shouldFetch = true
            
//            let request = f.fetchRequest(ds)
            // if the fetchRequest is empty or has changed then shouldFetch = true

            if shouldFetch {
                let resultsArray = ds.fetch(filter: f)
                results = QueryResults(results: resultsArray as NSArray)
            }
        }

    }
}

#if canImport(SwiftUI)
import SwiftUI

@propertyWrapper
public struct Query<T: Queryable>: DynamicProperty {
//    @Environment(\.dataStore) private var dataStore: DataStore
    @EnvironmentObject private var dataStore: DataStore
    @StateObject private var core = Core()
    private let baseFilter: T.Filter
    
    public var wrappedValue: QueryResults<T> { core.results }
    
    public init(_ filter: T.Filter) {
        self.baseFilter = filter
    }
    
    // Does this need to be `mutating`
    public func update() {
        if core.dataStore == nil { core.dataStore = dataStore }
        if core.filter == nil { core.filter = baseFilter }
        core.fetchIfNecessary()
//        core.executeQuery(dataStore: dataStore, filter: baseFilter)
    }
    
    public var projectedValue: Self {
        self
    }

    public func mutate(_ ndx: Int, fn: (inout T) -> Void) {
        core.objectWillChange.send()
        var nob = core.results[ndx]
        fn(&nob)
//        print (nob)
        let key = "\(type(of: nob)).Type"
        dataStore.datasets[key]?[ndx] = nob
    }
}
#endif

