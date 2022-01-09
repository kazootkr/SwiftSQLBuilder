import XCTest
@testable import SwiftSQLBuilder

final class SelectQueryBuilderTest: XCTestCase {
    func testBuild_最低限のSELECT文が生成できる() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(from: Friend.self)))
        XCTAssertEqual("SELECT * FROM friends", builder1.result.rawValue)

        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(from: Book.self)))
        XCTAssertEqual("SELECT * FROM books", builder2.result.rawValue)
    }

    func testBuild_カラム指定のSELECT文を生成() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "name"], from: Friend.self)))
        XCTAssertEqual("SELECT id, name FROM friends", builder1.result.rawValue)


        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "title", "publisher"], from: Book.self)))
        XCTAssertEqual("SELECT id, title, publisher FROM books", builder2.result.rawValue)
    }

    func testBuild_カラム指定のSELECT文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        XCTAssertThrowsError(try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "no_column_name"], from: Friend.self))))
        XCTAssertThrowsError(try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["no_column_name"], from: Book.self))))
    }

    func testBuild_条件付きのSELECT文が生成できる() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(from: Friend.self), clauses: [Query.Where(predicate: "id = 1")]))
        XCTAssertEqual("SELECT * FROM friends WHERE id = 1", builder1.result.rawValue)

        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "title like 'swift book'")]))
        XCTAssertEqual("SELECT id, title FROM books WHERE title like 'swift book'", builder2.result.rawValue)

        let builder3 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "id = 1"), Query.Where(predicate: "title like 'swift book'")]))
        XCTAssertEqual("SELECT id, title FROM books WHERE id = 1 AND title like 'swift book'", builder3.result.rawValue)
    }

    func testBuild_並び替え付きのSELECT文が生成できる() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(from: Friend.self), clauses: [Query.OrderBy(columnName: "id")]))
        XCTAssertEqual("SELECT * FROM friends ORDER BY id", builder1.result.rawValue)

        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "title like 'swift book'"), Query.OrderBy(columnName: "id")]))
        XCTAssertEqual("SELECT id, title FROM books WHERE title like 'swift book' ORDER BY id", builder2.result.rawValue)

        let builder3 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "id = 1"), Query.OrderBy(columnName: "id"), Query.OrderBy(columnName: "name", direction: .desc)]))
        XCTAssertEqual("SELECT id, title FROM books WHERE id = 1 ORDER BY id, name DESC", builder3.result.rawValue)
    }

    func testBuild_LIMIT付きのSELECT文が生成できる() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(from: Friend.self), clauses: [Query.Limit(rowCount: 10)]))
        XCTAssertEqual("SELECT * FROM friends LIMIT 10", builder1.result.rawValue)

        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "title"], from: Book.self), clauses: [Query.Where(predicate: "title like 'swift book'"), Query.OrderBy(columnName: "id"), Query.Limit(rowCount: 1)]))
        XCTAssertEqual("SELECT id, title FROM books WHERE title like 'swift book' ORDER BY id LIMIT 1", builder2.result.rawValue)
    }
}

final class UpdateQueryBuilderTest: XCTestCase {
    func testBuild_最低限のUPDATE文が生成できる() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Friend.self, set: ["age = 21"])))
        XCTAssertEqual("UPDATE FROM friends SET age = 21", builder1.result.rawValue)

        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Book.self, set: ["title = 'swift book part2'"])))
        XCTAssertEqual("UPDATE FROM books SET title = 'swift book part2'", builder2.result.rawValue)

        let builder3 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Book.self, set: ["age = 21", "title = 'swift book part2'"])))
        XCTAssertEqual("UPDATE FROM books SET age = 21, title = 'swift book part2'", builder3.result.rawValue)
    }

    func testBuild_UPDATE文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        XCTAssertThrowsError(try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "no_column_name"], from: Friend.self))))
        XCTAssertThrowsError(try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["no_column_name"], from: Book.self))))
    }

    func testBuild_条件付きのUPDATE文が生成できる() throws {
        let builder1 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Friend.self, set: ["age = 21"]), clauses: [Query.Where(predicate: "id = 1")]))
        XCTAssertEqual("UPDATE FROM friends SET age = 21 WHERE id = 1", builder1.result.rawValue)

        let builder2 = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Book.self, set: ["title = 'swift book part2'"]), clauses: [Query.Where(predicate: "title like 'swift book'")]))
        XCTAssertEqual("UPDATE FROM books SET title = 'swift book part2' WHERE title like 'swift book'", builder2.result.rawValue)
    }

    func testBuild_UPDATE文はORDER_BY句を付与できないこと() throws {
        XCTAssertThrowsError(try QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Friend.self, set: ["age = 22"]), clauses: [Query.OrderBy(columnName: "id")])));
    }

    func testBuild_UPDATE文はLIMIT句を付与できないこと() throws {
        XCTAssertThrowsError(try QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.update(from: Friend.self, set: ["age = 22"]), clauses: [Query.Limit(rowCount: 10)])));
    }
}

final class DeleteQueryBuilderTest: XCTestCase {
    func testBuild_DELETE文が生成できる() throws {
        let builder = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.delete(from: Friend.self)))
        XCTAssertEqual("DELETE FROM friends", builder.result.rawValue)
    }

    func testBuild_UPDATE文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        XCTAssertThrowsError(try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["id", "no_column_name"], from: Friend.self))))
        XCTAssertThrowsError(try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.select(columns: ["no_column_name"], from: Book.self))))
    }

    func testBuild_条件付きのDELETE文が生成できる() throws {
        let builder = try! QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.delete(from: Book.self), clauses: [Query.Where(predicate: "id = 1")]))
        XCTAssertEqual("DELETE FROM books WHERE id = 1", builder.result.rawValue)
    }

    func testBuild_DELETE文はORDER_BY句を付与できないこと() throws {
        XCTAssertThrowsError(try QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.delete(from: Friend.self), clauses: [Query.OrderBy(columnName: "id")])));
    }

    func testBuild_DELETE文はLIMIT句を付与できないこと() throws {
        XCTAssertThrowsError(try QueryBuilder.build(components: SQLComponents(dmlType: Query.DMLType.delete(from: Friend.self), clauses: [Query.Limit(rowCount: 10)])));
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