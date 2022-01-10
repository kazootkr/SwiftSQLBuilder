import SwiftSQLBuilder

@main
struct MyBuilderExample {
    static func main() {
        // SELECT文の生成(その1): SELECT * FROM photos
        Query {
            Query.Select(from: Photo.self)
        }.printDebug()

        // SELECT文の生成(その2): SELECT * FROM photos WHERE id = 1 ORDER BY id DESC LIMIT 5
        Query {
            Query.Select(from: Photo.self)
            Query.Where(predicate: "id = 1")
            Query.OrderBy(columnName: "id", direction: Query.OrderBy.Direction.desc)
            Query.Limit(rowCount: 5)
        }.printDebug()

        // UPDATE文の生成: UPDATE FROM photos SET is_deleted = 1 WHERE id = 1
        Query {
            Query.Update(from: Photo.self, set: ["is_deleted = 1"])
            Query.Where(predicate: "id = 1")
        }.printDebug()

        // DELETE文の生成: DELETE FROM photos WHERE id = 1
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