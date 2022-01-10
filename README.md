# SwiftSQLBuilder

Write SQL with Swift DSL.

## Usage

### Preparation

```swift
import SwiftSQLBuilder
```

### How to build query

```swift
// SELECT * FROM photos;
Query {
    Query.Select(from: Photo.self)
}

// SELECT title FROM photos WHERE id = 1 ORDER BY id DESC LIMIT 5;
Query {
    Query.Select(columns: ["title"], from: Photo.self)
    Query.Where(predicate: "id = 1")
    Query.OrderBy(columnName: "id", direction: Query.OrderBy.Direction.desc)
    Query.Limit(rowCount: 5)
}

// UPDATE FROM photos SET is_deleted = 1 WHERE id = 1;
Query {
    Query.Update(from: Photo.self, set: ["is_deleted = 1"])
    Query.Where(predicate: "id = 1")
}

// DELETE FROM photos WHERE id = 1;
Query {
    Query.Delete(from: Photo.self)
    Query.Where(predicate: "id = 1")
}
```

## TODO

- [X] SELECT文の生成
- [X] UPDATE文の生成
- [X] DELETE文の生成
- [X] ORDER BY句の指定
- [X] DSLで記述できるように
- [X] DSLによるSQLの記述例
