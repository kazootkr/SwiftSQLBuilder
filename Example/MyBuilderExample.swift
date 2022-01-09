import SwiftSQLBuilder

@main
struct MyBuilderExample {
    static func main() {
        Query {
            Query.DMLType.select(from: Photo.self)
            Query.Where(predicate: "id = 1")
            Query.OrderBy(columnName: "id", direction: Query.OrderBy.Direction.desc)
        }.printDebug()
    }
}

struct Photo: Table {
    static func tableName() -> String {
        "photos"
    }
}