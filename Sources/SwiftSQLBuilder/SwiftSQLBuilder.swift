public protocol Table {
    static func tableName() -> String
}

public struct Select: HeadClause {
    let columns: [String]?
    let from: Table.Type

    public init(columns: [String]? = nil, from: Table.Type) {
        self.columns = columns
        self.from = from
    }
}

public struct Update: HeadClause {
    let from: Table.Type
    let set: [String]

    public init(from: Table.Type, set: [String]) {
        self.from = from
        self.set = set
    }
}

public struct Delete: HeadClause {
    let from: Table.Type

    public init(from: Table.Type) {
        self.from = from
    }
}

public struct Where: AvailableClauseInSelectStatement, AvailableClauseInUpdateStatement, AvailableClauseInDeleteStatement {
    let predicate: String

    public init(predicate: String) {
        self.predicate = predicate
    }
}

public struct OrderBy: AvailableClauseInSelectStatement {
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

public struct Limit: AvailableClauseInSelectStatement {
    let rowCount: Int

    public init(rowCount: Int) {
        assert(rowCount > 0)
        self.rowCount = rowCount
    }
}

/**
 SQL文を構成する最小単位
 */
public protocol SQLClause {}

public protocol AvailableClauseInSelectStatement: SQLClause {}

public protocol AvailableClauseInUpdateStatement: SQLClause {}

public protocol AvailableClauseInDeleteStatement: SQLClause {}

@frozen public struct SQL {
    public let sql: Statement

    public init(@Queryable content: () -> Statement) {
        sql = content()
    }

    @resultBuilder public struct Queryable {
        public static func buildBlock(_ headClause: Select, _ clauses: AvailableClauseInSelectStatement...) -> Statement {
            let queryBuilder = QueryBuilder.build(components: SQLComponents(headClause: headClause, clauses: clauses));
            return queryBuilder.result
        }

        public static func buildBlock(_ headClause: Update, _ clauses: AvailableClauseInUpdateStatement...) -> Statement {
            let queryBuilder = QueryBuilder.build(components: SQLComponents(headClause: headClause, clauses: clauses));
            return queryBuilder.result
        }

        public static func buildBlock(_ headClause: Delete, _ clauses: AvailableClauseInDeleteStatement...) -> Statement {
            let queryBuilder = QueryBuilder.build(components: SQLComponents(headClause: headClause, clauses: clauses));
            return queryBuilder.result
        }
    }

    public func printDebug() {
        print("SQLString: \(sql.rawValue)")
    }

    public struct Statement: Equatable {
        let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func ==(lhs: Statement, rhs: Statement) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
    }
}

// MARK: - internal クエリビルダーなどはライブラリの外から見えないように

/**
 * SQL文の構成要素を含むコレクションオブジェクト
 */
struct SQLComponents {
    let headClause: HeadClause
    let clauses: [SQLClause]

    init(headClause: HeadClause, clauses: [SQLClause] = []) {
        self.headClause = headClause
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

/**
 * DMLの種類
 */
protocol HeadClause {
    func toSQLString() -> String
}

extension Select {
    func toSQLString() -> String {
        let unwrappedColumns: [String] = columns ?? ["*"]
        return "SELECT \(unwrappedColumns.joined(separator: ", ")) FROM \(from.tableName())"
    }
}

extension Update {
    func toSQLString() -> String {
        "UPDATE FROM \(from.tableName()) SET \(set.joined(separator: ", "))"
    }
}

extension Delete {
    func toSQLString() -> String {
        "DELETE FROM \(from.tableName())"
    }
}

extension Where {
    func toSQLString() -> String {
        predicate
    }
}

extension OrderBy {
    func toSQLString() -> String {
        if .desc == direction {
            return "\(columnName) DESC"
        }

        return columnName
    }
}

extension Limit {
    func toSQLString() -> String {
        "\(rowCount)"
    }
}

struct QueryBuilder {
    let result: SQL.Statement

    private init(result: SQL.Statement) {
        self.result = result
    }

    static func build(components: SQLComponents) -> Self {
        var sqlString: String = ""
        sqlString += components.headClause.toSQLString()

        if let unwrappedSqlWhere: [Where] = components.getClause(kind: Where.self) {
            sqlString += " WHERE \(unwrappedSqlWhere.map { $0.toSQLString() }.joined(separator: " AND "))"
        }

        if let unwrappedSqlOrderBy: [OrderBy] = components.getClause(kind: OrderBy.self) {
            sqlString += " ORDER BY \(unwrappedSqlOrderBy.map { $0.toSQLString() }.joined(separator: ", "))"
        }

        if let unwrappedSqlLimit: [Limit] = components.getClause(kind: Limit.self) {
            sqlString += " LIMIT \(unwrappedSqlLimit.map { $0.toSQLString() }.joined(separator: ", "))"
        }

        sqlString += ";"

        return QueryBuilder(result: SQL.Statement(rawValue: sqlString))
    }
}
