import SwiftSQLBuilder

@main
struct MyBuilderExample {
    static func main() {
        // SELECT * FROM photos;
        Query {
            Query.Select(from: Photo.self)
        }.printDebug()

        // SELECT title FROM photos WHERE id = 1 ORDER BY id DESC LIMIT 5;
        Query {
            Query.Select(columns: ["title"], from: Photo.self)
            Query.Where(predicate: "id = 1")
            Query.OrderBy(columnName: "id", direction: Query.OrderBy.Direction.desc)
            Query.Limit(rowCount: 5)
        }.printDebug()

        // UPDATE FROM photos SET is_deleted = 1 WHERE id = 1;
        Query {
            Query.Update(from: Photo.self, set: ["is_deleted = 1"])
            Query.Where(predicate: "id = 1")
        }.printDebug()

        // DELETE FROM photos WHERE id = 1;
        Query {
            Query.Delete(from: Photo.self)
            Query.Where(predicate: "id = 1")
        }.printDebug()
    }
}

struct Photo: Table {
    static func tableName() -> String {
        "photos"
    }
}
