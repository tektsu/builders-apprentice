/**
Types that adopt RowConvertible can be initialized from a database Row.

    let row = Row.fetchOne(db, "SELECT ...")!
    let person = Person(row: row)

The protocol comes with built-in methods that allow to fetch lazy sequences,
arrays, or single instances:

    Person.fetch(db, "SELECT ...", arguments:...)    // AnySequence<Person>
    Person.fetchAll(db, "SELECT ...", arguments:...) // [Person]
    Person.fetchOne(db, "SELECT ...", arguments:...) // Person?
    
    let statement = db.selectStatement("SELECT ...")
    Person.fetch(statement, arguments:...)           // AnySequence<Person>
    Person.fetchAll(statement, arguments:...)        // [Person]
    Person.fetchOne(statement, arguments:...)        // Person?

RowConvertible is adopted by Record.
*/
public protocol RowConvertible {
    /// Create an instance initialized with `row`.
    init(row: Row)
    
    /// Do not call this method directly.
    ///
    /// Types that adopt RowConvertible have an opportunity to complete their
    /// initialization.
    func awakeFromFetch(row: Row)
}

extension RowConvertible {
    
    /// Default implementation, which does nothing.
    public func awakeFromFetch(row: Row) { }

    
    // MARK: - Fetching From SelectStatement
    
    /**
    Fetches a lazy sequence.
    
        let statement = db.selectStatement("SELECT * FROM persons")
        let persons = Person.fetch(statement) // AnySequence<Person>
    
    The returned sequence can be consumed several times, but it may yield
    different results, should database changes have occurred between two
    generations:
    
        let persons = Person.fetch(statement)
        Array(persons).count // 3
        db.execute("DELETE ...")
        Array(persons).count // 2
    
    If the database is modified while the sequence is iterating, the remaining
    elements of the sequence are undefined.
    
    - parameter statement: The statement to run.
    - parameter arguments: Optional statement arguments.
    - returns: A lazy sequence.
    */
    public static func fetch(statement: SelectStatement, arguments: StatementArguments? = nil) -> AnySequence<Self> {
        return statement.fetch(arguments: arguments) { statement in
            let row = Row(statement: statement)
            let value = Self.init(row: row)
            value.awakeFromFetch(row)
            return value
        }
    }
    
    /**
    Fetches an array.
    
        let statement = db.selectStatement("SELECT * FROM persons")
        let persons = Person.fetchAll(statement) // [Person]
    
    - parameter statement: The statement to run.
    - parameter arguments: Optional statement arguments.
    - returns: An array.
    */
    public static func fetchAll(statement: SelectStatement, arguments: StatementArguments? = nil) -> [Self] {
        return Array(fetch(statement, arguments: arguments))
    }
    
    /**
    Fetches a single value.
    
        let statement = db.selectStatement("SELECT * FROM persons")
        let persons = Person.fetchOne(statement) // Person?
    
    - parameter statement: The statement to run.
    - parameter arguments: Optional statement arguments.
    - returns: An optional value.
    */
    public static func fetchOne(statement: SelectStatement, arguments: StatementArguments? = nil) -> Self? {
        guard let first = fetch(statement, arguments: arguments).generate().next() else {
            return nil
        }
        return first
    }
    
    
    // MARK: - Fetching From Database
    
    /**
    Fetches a lazy sequence.
    
        let persons = Person.fetch(db, "SELECT * FROM persons") // AnySequence<Person>
    
    The returned sequence can be consumed several times, but it may yield
    different results, should database changes have occurred between two
    generations:
    
        let persons = Person.fetch(db, "SELECT * FROM persons")
        Array(persons).count // 3
        db.execute("DELETE ...")
        Array(persons).count // 2
    
    If the database is modified while the sequence is iterating, the remaining
    elements of the sequence are undefined.
    
    - parameter db: A Database.
    - parameter sql: An SQL query.
    - parameter arguments: Optional statement arguments.
    - returns: A lazy sequence.
    */
    public static func fetch(db: Database, _ sql: String, arguments: StatementArguments? = nil) -> AnySequence<Self> {
        return fetch(db.selectStatement(sql), arguments: arguments)
    }
    
    /**
    Fetches an array.
    
        let persons = Person.fetchAll(db, "SELECT * FROM persons") // [Person]
    
    - parameter db: A Database.
    - parameter sql: An SQL query.
    - parameter arguments: Optional statement arguments.
    - returns: An array.
    */
    public static func fetchAll(db: Database, _ sql: String, arguments: StatementArguments? = nil) -> [Self] {
        return Array(fetch(db, sql, arguments: arguments))
    }
    
    /**
    Fetches a single value.
    
        let person = Person.fetchOne(db, "SELECT * FROM persons") // Person?
    
    - parameter db: A Database.
    - parameter sql: An SQL query.
    - parameter arguments: Optional statement arguments.
    - returns: An optional value.
    */
    public static func fetchOne(db: Database, _ sql: String, arguments: StatementArguments? = nil) -> Self? {
        if let first = fetch(db, sql, arguments: arguments).generate().next() {
            // one row containing an optional value
            return first
        } else {
            // no row
            return nil
        }
    }
}
