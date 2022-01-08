public protocol Table {
    var tableName: String { get }
}

@frozen public struct Query {
    @inlinable public init(@Queryable content: () -> Query) {
    }

    /**
     * DMLの種類を決定する役割をもつプロトコル
     */
    enum DMLDeterminer {
        case select(columns: [String]? = nil, from: Table)
        case update(from: Table, set: [String])
        case delete(from: Table)
    }

    struct Where: SQLClause {
        let predicate: String
    }
}

@resultBuilder private struct Queryable {
    static func buildBlock(_ determiner: Query.DMLDeterminer, _ clauses: SQLClause...) -> SQL {
        let queryBuilder = QueryBuilder.build(components: SQLComponents(determiner: determiner, clauses: clauses));
        return queryBuilder.result
    }
}

// MARK: - private クエリビルダー自体は外から見えないように

/**
 * SQL文の構成要素を含むコレクションオブジェクト
 */
struct SQLComponents {
    let determiner: Query.DMLDeterminer
    let clauses: [SQLClause]

    init(determiner: Query.DMLDeterminer, clauses: [SQLClause] = []) {
        self.determiner = determiner
        self.clauses = clauses
    }

    func getClause<T: SQLClause>(kind: T.Type) -> [T]? {
        guard !clauses.isEmpty else {
            return nil
        }

        var result: [T] = []

        for clause in clauses {
            if clause is T {
                if let cast = clause as? T {
                    result.append(cast)
                }
            }
        }

        return result
    }
}

extension Query.DMLDeterminer {
    func toSQLString() -> String {
        switch (self) {
        case let Query.DMLDeterminer.select(columns, from):
            let unwrappedColumns: [String] = columns ?? ["*"]
            return "SELECT \(unwrappedColumns.joined(separator: ", ")) FROM \(from.tableName)"
        case let Query.DMLDeterminer.update(from, set):
            return "UPDATE FROM \(from.tableName) SET \(set.joined(separator: ", "))"
        case let Query.DMLDeterminer.delete(from):
            return "DELETE FROM \(from.tableName)"
        }
    }
}

/**
 SQL文を構成する最小単位
 */
protocol SQLClause {
}

struct SQL {
    let rawValue: String
}

struct QueryBuilder {
    let result: SQL

    private init(result: SQL) {
        self.result = result
    }

    static func build(components: SQLComponents) -> Self {
        var sqlString: String = ""
        sqlString += components.determiner.toSQLString()

        if let unwrappedSqlWhere: [Query.Where] = components.getClause(kind: Query.Where.self) {
            sqlString += " WHERE \(unwrappedSqlWhere.map { $0.predicate }.joined(separator: " AND "))"
        }

        return QueryBuilder(result: SQL(rawValue: sqlString))
    };
}



