import XCTest
@testable import SwiftSQLBuilder

final class SelectQueryBuilderTest: XCTestCase {
    func testBuild_最低限のSELECT文が生成できる() throws {
        var builder1 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(from: makeFriend())))
        builder1.build()
        XCTAssertEqual("SELECT * FROM friends", try! builder1.getSQL().rawValue)

        var builder2 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(from: makeBook())))
        builder2.build()
        XCTAssertEqual("SELECT * FROM books", try! builder2.getSQL().rawValue)
    }

    func testBuild_カラム指定のSELECT文を生成() throws {
        var builder1 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(columns: ["id", "name"], from: makeFriend())))
        builder1.build()
        XCTAssertEqual("SELECT id, name FROM friends", try! builder1.getSQL().rawValue)


        var builder2 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(columns: ["id", "title", "publisher"], from: makeBook())))
        builder2.build()
        XCTAssertEqual("SELECT id, title, publisher FROM books", try! builder2.getSQL().rawValue)
    }

    func testBuild_カラム指定のSELECT文を生成_カラム名の指定が誤っている_例外() throws {
        throw XCTSkip("未実装")
        var builder1 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(columns: ["id", "no_column_name"], from: makeFriend())))

        XCTAssertThrowsError(builder1.build())
        XCTAssertEqual("SELECT id, name FROM friends", try! builder1.getSQL().rawValue)


        var builder2 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(columns: ["id", "title", "publisher"], from: makeBook())))
        builder2.build()
        XCTAssertEqual("SELECT id, title, publisher FROM books", try! builder2.getSQL().rawValue)
    }

    func testBuild_条件付きのSELECT文が生成できる() throws {
        var builder1 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(from: makeFriend()), clauses: [Query.Where(predicate: "id = 1")]))
        builder1.build()
        XCTAssertEqual("SELECT * FROM friends WHERE id = 1", try! builder1.getSQL().rawValue)

        var builder2 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(columns: ["id", "title"], from: makeBook()), clauses: [Query.Where(predicate: "title like 'swift book'")]))
        builder2.build()
        XCTAssertEqual("SELECT id, title FROM books WHERE title like 'swift book'", try! builder2.getSQL().rawValue)

        var builder3 = QueryBuilder(components: SQLComponents(determiner: Query.DMLDeterminer.select(columns: ["id", "title"], from: makeBook()), clauses: [Query.Where(predicate: "id = 1"), Query.Where(predicate: "title like 'swift book'")]))
        builder3.build()
        XCTAssertEqual("SELECT id, title FROM books WHERE id = 1 AND title like 'swift book'", try! builder3.getSQL().rawValue)
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
    var tableName: String = "friends"

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
    var tableName: String = "books"

    var id: Int
    var title: String
    var publisher: String

    init(id: Int, title: String, publisher: String) {
        self.id = id
        self.title = title
        self.publisher = publisher
    }
}