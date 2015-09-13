// MARK: - DatabaseIntRepresentable

/**
Have your Int enum adopt DatabaseIntRepresentable and it automatically gains
DatabaseValueConvertible adoption.
    
    // An Int enum:
    enum Color : Int {
        case Red
        case White
        case Rose
    }
    
    // Declare DatabaseIntRepresentable adoption:
    extension Color : DatabaseIntRepresentable { }
    
    // Gain full GRDB.swift support:
    db.execute("INSERT INTO colors (color) VALUES (?)", [Color.Red])
    let color: Color? = Color.fetchOne(db, "SELECT ...")
*/
public protocol DatabaseIntRepresentable : DatabaseValueConvertible {
    var rawValue: Int { get }
    init?(rawValue: Int)
}

extension DatabaseIntRepresentable {
    
    /// Returns a value that can be stored in the database.
    public var databaseValue: DatabaseValue {
        return .Integer(Int64(rawValue))
    }
    
    /**
    Returns an instance initialized from *databaseValue*, if possible.
    
    - parameter databaseValue: A DatabaseValue.
    - returns: An optional Self.
    */
    public static func fromDatabaseValue(databaseValue: DatabaseValue) -> Self? {
        if let int = Int.fromDatabaseValue(databaseValue) {
            return self.init(rawValue: int)
        } else {
            return nil
        }
    }
}


// MARK: - DatabaseStringRepresentable

/**
Have your String enum adopt DatabaseStringRepresentable and it automatically gains
DatabaseValueConvertible adoption.
    
    // A String enum:
    enum Color : String {
        case Red
        case White
        case Rose
    }
    
    // Declare DatabaseIntRepresentable adoption:
    extension Color : DatabaseStringRepresentable { }
    
    // Gain full GRDB.swift support:
    db.execute("INSERT StringO colors (color) VALUES (?)", [Color.Red])
    let color: Color? = Color.fetchOne(db, "SELECT ...")
*/
public protocol DatabaseStringRepresentable : DatabaseValueConvertible {
    var rawValue: String { get }
    init?(rawValue: String)
}

extension DatabaseStringRepresentable {
    
    /// Returns a value that can be stored in the database.
    public var databaseValue: DatabaseValue {
        return .Text(rawValue)
    }
    
    /**
    Returns an instance initialized from *databaseValue*, if possible.
    
    - parameter databaseValue: A DatabaseValue.
    - returns: An optional Self.
    */
    public static func fromDatabaseValue(databaseValue: DatabaseValue) -> Self? {
        if let string = String.fromDatabaseValue(databaseValue) {
            return self.init(rawValue: string)
        } else {
            return nil
        }
    }
}
