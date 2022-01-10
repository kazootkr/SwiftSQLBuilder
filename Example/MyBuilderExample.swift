import SwiftSQLBuilder

@main
struct MyBuilderExample {
    static func main() {
        // SELECT * FROM photos;
        SQL {
            Select(from: Photo.self)
        }.printDebug()

        // SELECT title FROM photos WHERE id = 1 ORDER BY id DESC LIMIT 5;
        SQL {
            Select(columns: ["title"], from: Photo.self)
            Where(predicate: "id = 1")
            OrderBy(columnName: "id", direction: OrderBy.Direction.desc)
            Limit(rowCount: 5)
        }.printDebug()

        // UPDATE FROM photos SET is_deleted = 1 WHERE id = 1;
        SQL {
            Update(from: Photo.self, set: ["is_deleted = 1"])
            Where(predicate: "id = 1")
        }.printDebug()

        // DELETE FROM photos WHERE id = 1;
        SQL {
            Delete(from: Photo.self)
            Where(predicate: "id = 1")
        }.printDebug()
    }
}

struct Photo: Table {
    static func tableName() -> String {
        "photos"
    }
}
