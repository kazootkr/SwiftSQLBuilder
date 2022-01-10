import XCTest
@testable import SwiftSQLBuilder

final class SelectQueryBuilderTest: XCTestCase {
    func testBuild_最低限のSELECT文が生成できる() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(from: Friend.self)))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT * FROM friends;"), builder1.result)

        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(from: Book.self)))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT * FROM books;"), builder2.result)
    }

    func testBuild_カラム指定のSELECT文を生成() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "name"], from: Friend.self)))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, name FROM friends;"), builder1.result)


        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "title", "publisher"], from: Book.self)))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, title, publisher FROM books;"), builder2.result)
    }

    func testBuild_カラム指定のSELECT文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        XCTAssertThrowsError(QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "no_column_name"], from: Friend.self))))
        XCTAssertThrowsError(QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["no_column_name"], from: Book.self))))
    }

    func testBuild_条件付きのSELECT文が生成できる() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(from: Friend.self), clauses: [Query.Where(predicate: "id = 1")]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT * FROM friends WHERE id = 1;"), builder1.result)

        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "title like 'swift book'")]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, title FROM books WHERE title like 'swift book';"), builder2.result)

        let builder3 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "id = 1"), Query.Where(predicate: "title like 'swift book'")]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, title FROM books WHERE id = 1 AND title like 'swift book';"), builder3.result)
    }

    func testBuild_並び替え付きのSELECT文が生成できる() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(from: Friend.self), clauses: [Query.OrderBy(columnName: "id")]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT * FROM friends ORDER BY id;"), builder1.result)

        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "title like 'swift book'"), Query.OrderBy(columnName: "id")]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, title FROM books WHERE title like 'swift book' ORDER BY id;"), builder2.result)

        let builder3 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "id = 1"), Query.OrderBy(columnName: "id"), Query.OrderBy(columnName: "name", direction: .desc)]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, title FROM books WHERE id = 1 ORDER BY id, name DESC;"), builder3.result)
    }

    func testBuild_LIMIT付きのSELECT文が生成できる() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(from: Friend.self), clauses: [Query.Limit(rowCount: 10)]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT * FROM friends LIMIT 10;"), builder1.result)

        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "title like 'swift book'"), Query.OrderBy(columnName: "id"), Query.Limit(rowCount: 1)]))
        XCTAssertEqual(Query.SQL(rawValue: "SELECT id, title FROM books WHERE title like 'swift book' ORDER BY id LIMIT 1;"), builder2.result)
    }
}

final class UpdateQueryBuilderTest: XCTestCase {
    func testBuild_最低限のUPDATE文が生成できる() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Update(from: Friend.self, set: ["age = 21"])))
        XCTAssertEqual(Query.SQL(rawValue: "UPDATE FROM friends SET age = 21;"), builder1.result)

        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Update(from: Book.self, set: ["title = 'swift book part2'"])))
        XCTAssertEqual(Query.SQL(rawValue: "UPDATE FROM books SET title = 'swift book part2';"), builder2.result)

        let builder3 = QueryBuilder.build(components: SQLComponents(headClause: Query.Update(from: Book.self, set: ["age = 21", "title = 'swift book part2'"])))
        XCTAssertEqual(Query.SQL(rawValue: "UPDATE FROM books SET age = 21, title = 'swift book part2';"), builder3.result)
    }

    func testBuild_UPDATE文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        XCTAssertThrowsError(QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "no_column_name"], from: Friend.self))))
        XCTAssertThrowsError(QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["no_column_name"], from: Book.self))))
    }

    func testBuild_条件付きのUPDATE文が生成できる() throws {
        let builder1 = QueryBuilder.build(components: SQLComponents(headClause: Query.Update(from: Friend.self, set: ["age = 21"]), clauses: [Query.Where(predicate: "id = 1")]))
        XCTAssertEqual(Query.SQL(rawValue: "UPDATE FROM friends SET age = 21 WHERE id = 1;"), builder1.result)

        let builder2 = QueryBuilder.build(components: SQLComponents(headClause: Query.Update(from: Book.self, set: ["title = 'swift book part2'"]), clauses: [Query.Where(predicate: "title like 'swift book'")]))
        XCTAssertEqual(Query.SQL(rawValue: "UPDATE FROM books SET title = 'swift book part2' WHERE title like 'swift book';"), builder2.result)
    }
}

final class DeleteQueryBuilderTest: XCTestCase {
    func testBuild_DELETE文が生成できる() throws {
        let builder = QueryBuilder.build(components: SQLComponents(headClause: Query.Delete(from: Friend.self)))
        XCTAssertEqual(Query.SQL(rawValue: "DELETE FROM friends;"), builder.result)
    }

    func testBuild_UPDATE文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        XCTAssertThrowsError(QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["id", "no_column_name"], from: Friend.self))))
        XCTAssertThrowsError(QueryBuilder.build(components: SQLComponents(headClause: Query.Select(columns: ["no_column_name"], from: Book.self))))
    }

    func testBuild_条件付きのDELETE文が生成できる() throws {
        let builder = QueryBuilder.build(components: SQLComponents(headClause: Query.Delete(from: Book.self), clauses: [Query.Where(predicate: "id = 1")]))
        XCTAssertEqual(Query.SQL(rawValue: "DELETE FROM books WHERE id = 1;"), builder.result)
    }
}

func makeFriend() -> Friend
{
    Friend(id: 1, name: "taro", age: 20)
}

func makeBook() -> Book
{
    Book(id: 10, title: "swift book", publisher: "book maker")
}

class Friend: Table {
    static func tableName() -> String {
        "friends"
    }

    var id: Int
    var name: String
    var age: Int

    init(id: Int, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
}

class Book: Table {
    static func tableName() -> String {
        "books"
    }

    var id: Int
    var title: String
    var publisher: String

    init(id: Int, title: String, publisher: String) {
        self.id = id
        self.title = title
        self.publisher = publisher
    }
}