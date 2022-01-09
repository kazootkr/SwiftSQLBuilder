public protocol Table {
    static func tableName() -> String
}

/**
 SQL文を構成する最小単位
 */
public protocol SQLClause {
}

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
        case select(columns: [String]? = nil, from: Table.Type)
        case update(from: Table.Type, set: [String])
        case delete(from: Table.Type)
    }

    public struct Where: SQLClause {
        let predicate: String

        public init(predicate: String) {
            self.predicate = predicate
        }
    }

    public struct OrderBy: SQLClause {
        let columnName: String
        let direction: Direction

        public init(columnName: String, direction: Direction = .asc) {
            self.columnName = columnName
            self.direction = direction
        }

        public enum Direction: String {
            case asc = "ASC"
            case desc = "DESC"
        }
    }

    public struct SQL: Equatable {
        let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    @resultBuilder public struct Queryable {
        public static func buildBlock(_ dmlType: DMLType, _ clauses: SQLClause...) -> SQL {
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

        guard !result.isEmpty else {
            return nil
        }

        return result
    }
}

extension Query.DMLType {
    func toSQLString() -> String {
        switch (self) {
        case let Query.DMLType.select(columns, from):
            let unwrappedColumns: [String] = columns ?? ["*"]
            return "SELECT \(unwrappedColumns.joined(separator: ", ")) FROM \(from.tableName())"
        case let Query.DMLType.update(from, set):
            return "UPDATE FROM \(from.tableName()) SET \(set.joined(separator: ", "))"
        case let Query.DMLType.delete(from):
            return "DELETE FROM \(from.tableName())"
        }
    }
}

extension Query.Where {
    func toSQLString() -> String {
        predicate
    }
}

extension Query.OrderBy {
    func toSQLString() -> String {
        if .desc == direction {
            return "\(columnName) DESC"
        }

        return columnName
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
            sqlString += " WHERE \(unwrappedSqlWhere.map { $0.toSQLString() }.joined(separator: " AND "))"
        }

        if let unwrappedSqlOrderBy: [Query.OrderBy] = components.getClause(kind: Query.OrderBy.self) {
            sqlString += " ORDER BY \(unwrappedSqlOrderBy.map { $0.toSQLString() }.joined(separator: ", "))"
        }

        return QueryBuilder(result: Query.SQL(rawValue: sqlString))
    };
}



