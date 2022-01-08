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
        var queryBuilder = QueryBuilder(components: SQLComponents(determiner: determiner, clauses: clauses));
        queryBuilder.build()
        return try! queryBuilder.getSQL()
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

protocol ConcreteBuilder {
    mutating func build()
    func getSQL() throws -> SQL
}

struct QueryBuilder {
    var sql: SQL?

    var components: SQLComponents

    init(components: SQLComponents) {
        self.components = components
    }

    mutating func build() {
        var concreteBuilder = getBuilder()
        concreteBuilder.build()
        sql = try! concreteBuilder.getSQL()
    };

    enum InternalError: Error {
        case noParams
        case noBuild
    }

    func getSQL() throws -> SQL {
        guard let unwrappedSQL = sql else {
            throw InternalError.noBuild
        }

        return unwrappedSQL
    }

    private func getBuilder() -> ConcreteBuilder {
        switch components.determiner {
        case .select:
            return SelectQueryBuilder(components: components)
        case .update:
            return UpdateQueryBuilder(components: components)
        case .delete:
            return DeleteQueryBuilder()
        }
    }

    struct SelectQueryBuilder: ConcreteBuilder {
        let determiner: Query.DMLDeterminer
        var sqlWhere: [Query.Where]? = nil

        var result: SQL?

        init(components: SQLComponents) {
            determiner = components.determiner
            sqlWhere = components.getClause(kind: Query.Where.self)
        }

        mutating func build() {
            var sqlString: String = ""
            sqlString += determiner.toSQLString()

            if let unwrappedSqlWhere: [Query.Where] = sqlWhere {
                sqlString += " WHERE \(unwrappedSqlWhere.map { $0.predicate }.joined(separator: " AND "))"
            }

            result = SQL(rawValue: sqlString)
        }

        func getSQL() throws -> SQL {
            guard let unwrappedSQL = result else {
                throw QueryBuilder.InternalError.noBuild
            }
            return unwrappedSQL
        }
    }

    struct UpdateQueryBuilder: ConcreteBuilder {
        let determiner: Query.DMLDeterminer
        var sqlWhere: [Query.Where]? = nil

        var result: SQL?

        init(components: SQLComponents) {
            determiner = components.determiner
            sqlWhere = components.getClause(kind: Query.Where.self)
        }

        mutating func build() {
            var sqlString: String = ""
            sqlString += determiner.toSQLString()

            if let unwrappedSqlWhere: [Query.Where] = sqlWhere {
                sqlString += " WHERE \(unwrappedSqlWhere.map { $0.predicate }.joined(separator: "AND"))"
            }

            result = SQL(rawValue: sqlString)
        }

        func getSQL() throws -> SQL {
            guard let unwrappedSQL = result else {
                throw QueryBuilder.InternalError.noBuild
            }
            return unwrappedSQL
        }
    }

    struct DeleteQueryBuilder: ConcreteBuilder {
        mutating func build() {
        }

        func getSQL() -> SQL {
            SQL(rawValue: "")
        }
    }
}



