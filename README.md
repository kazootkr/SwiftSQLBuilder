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
SQL {
    Select(from: Photo.self)
}

// SELECT title FROM photos WHERE id = 1 ORDER BY id DESC LIMIT 5;
SQL {
    Select(columns: ["title"], from: Photo.self)
    Where(predicate: "id = 1")
    OrderBy(columnName: "id", direction: OrderBy.Direction.desc)
    Limit(rowCount: 5)
}

// UPDATE FROM photos SET is_deleted = 1 WHERE id = 1;
SQL {
    Update(from: Photo.self, set: ["is_deleted = 1"])
    Where(predicate: "id = 1")
}

// DELETE FROM photos WHERE id = 1;
SQL {
    Delete(from: Photo.self)
    Where(predicate: "id = 1")
}
```

## TODO

- [X] SELECT文の生成
- [X] UPDATE文の生成
- [X] DELETE文の生成
- [X] ORDER BY句の指定
- [X] DSLで記述できるように
- [X] DSLによるSQLの記述例
