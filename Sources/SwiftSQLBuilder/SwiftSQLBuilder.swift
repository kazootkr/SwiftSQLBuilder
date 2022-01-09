public protocol Table {
    var tableName: String { get }
}

/**
 SQL文を構成する最小単位
 */
public protocol SQLClause {}

@frozen public struct Query {
    public let sql: SQL
    public init(@Queryable content: () -> SQL) {
        sql = content()
    }

    public func printDebug() {
        print("sql string: \(sql.rawValue)")
    }

    /**
     * DMLの種類
     */
    public enum DMLType {
        case select(columns: [String]? = nil, from: Table)
        case update(from: Table, set: [String])
        case delete(from: Table)
    }

    public struct Where: SQLClause {
        let predicate: String

        public init(predicate: String) {
            self.predicate = predicate
        }
    }

    public struct SQL: Equatable {
        let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    @resultBuilder public struct Queryable {
        public static func buildBlock(_ dmlType: Query.DMLType, _ clauses: SQLClause...) -> SQL {
            let queryBuilder = QueryBuilder.build(components: SQLComponents(dmlType: dmlType, clauses: clauses));
            return queryBuilder.result
        }
    }
}

// MARK: - private クエリビルダー自体は外から見えないように

/**
 * SQL文の構成要素を含むコレクションオブジェクト
 */
struct SQLComponents {
    let dmlType: Query.DMLType
    let clauses: [SQLClause]

    init(dmlType: Query.DMLType, clauses: [SQLClause] = []) {
        self.dmlType = dmlType
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

extension Query.DMLType {
    func toSQLString() -> String {
        switch (self) {
        case let Query.DMLType.select(columns, from):
            let unwrappedColumns: [String] = columns ?? ["*"]
            return "SELECT \(unwrappedColumns.joined(separator: ", ")) FROM \(from.tableName)"
        case let Query.DMLType.update(from, set):
            return "UPDATE FROM \(from.tableName) SET \(set.joined(separator: ", "))"
        case let Query.DMLType.delete(from):
            return "DELETE FROM \(from.tableName)"
        }
    }
}

struct QueryBuilder {
    let result: Query.SQL

    private init(result: Query.SQL) {
        self.result = result
    }

    static func build(components: SQLComponents) -> Self {
        var sqlString: String = ""
        sqlString += components.dmlType.toSQLString()

        if let unwrappedSqlWhere: [Query.Where] = components.getClause(kind: Query.Where.self) {
            sqlString += " WHERE \(unwrappedSqlWhere.map { $0.predicate }.joined(separator: " AND "))"
        }

        return QueryBuilder(result: Query.SQL(rawValue: sqlString))
    };
}



