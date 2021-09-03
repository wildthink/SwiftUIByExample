import SwiftUI
//import CoreData

struct Item: Identifiable {
    var id: Int
    var _value: Int
    var value: Int {
        get {
//            print("get_v \(id)")
            return _value
        }
        set { _value = newValue }
    }
}

extension Item: Queryable {
    typealias Filter = ItemFilter

    init(result: ItemFilter.ResultType) {
        id = result.id
        _value = result._value
    }
}

struct ItemFilter: QueryFilter {
    typealias ResultType = Item
    static let all = ItemFilter()
    
    func fetchRequest(_ dataStore: DataStore) -> FetchRequest<ResultType> {
//        let f = NSManagedObject.fetchRequest() as NSFetchRequest<NSManagedObject>
//        f.predicate = NSPredicate(value: true)
//        f.sortDescriptors = [NSSortDescriptor(key: "givenName", ascending: true)]
        return FetchRequest()
    }
}

struct Place: Identifiable {
    var id: Int64
    var name: String
    var city: String
}

extension Place {
    static func sample() -> [Place] {
        (1...500_000).map { Place(id: $0, name: "Name \($0)", city: "New York") }
    }
}
    
struct PlaceView: View {
    
    var place: Place
    @Binding var expandedPlaceId: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(place.name)
            
            if self.$expandedPlaceId.wrappedValue == place.id {
                VStack(alignment: .leading) {
                    Text(place.city)
                }
            }
        }
    }
}

//class Model: ObservableObject {
//    var items: [Item] = (1...500_000).map { Item(id: $0, _value: $0) }
//    
//    func update(_ id: Int) {
//        objectWillChange.send()
//        items[id].value += 5
//        items[items.count - id - 1].value += 5
//    }
//}

struct SampleRow: View {
    let item: Item
    
    var body: some View {
        Text("Row \(item.id) value: \(item.value)")
//            .onTapGesture { self.select(item) }
//            .modifier(ListRowModifier())
//            .animation(.linear(duration: 0.3))

//            .onAppear {
//                print("Display row \(item.id)")
//            }
    }
    
    init(item: Item) {
//        print("Loading row \(item.id)")
        self.item = item
    }
}

// https://github.com/onmyway133/blog/issues/468

struct ContentView: View {
    @Feature(\.isDebugMenuEnabled) var showDebugMenu
    @Query(.all) var items: QueryResults<Item>

//    @ObservedObject var model: Model
    
    var body: some View {
        VStack {
            Button ("Update") {
                $items.mutate(0) {
                    $0.value += 100
                }
            }
            ScrollView {
                LazyVStack {
                    ForEach(items) { item in
                        SampleRow(item: item)
                            .onTapGesture {
                                $items.mutate(item.id - 1) {
                                    $0.value += 100
                                }
                            }
                    }
                }
                .onAppear(perform: {
                    self.reload()
                })
//                .onReceive(model.objectWillChange, perform: { _ in
//                    self.reload()
//                })
        }
        }
//        .frame(height: 300)
    }
    
    private func reload() {
    }

}
