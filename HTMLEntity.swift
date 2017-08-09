import Foundation

public struct HTMLEntity {
    let entityName: String
    let entityValue: Int
    public let character: String
    public var name: String {
        return "&\(entityName);"
    }
    public var decimal: String {
        return "&#\(entityValue);"
    }
    public var hex: String {
        return "&#x\(String(entityValue, radix: 16, uppercase: true));"
    }
}

extension HTMLEntity {
    private init?(line: String) {
        let components = line.components(separatedBy: ",")
        guard components.count == 4, components[1].hasSuffix(";") else { return nil }
        self.character = components[0]
        self.entityName = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "&;"))
        guard let decimal = Int(String(components[3].dropLast().dropFirst(2))) else { return nil }
        self.entityValue = decimal
    }
}

extension HTMLEntity: Equatable, Hashable {
    static public func == (lhs: HTMLEntity, rhs: HTMLEntity) -> Bool {
        return lhs.entityName == rhs.entityName && lhs.entityValue == rhs.entityValue
    }
    public var hashValue: Int {
        return entityValue.hashValue
    }
}

extension HTMLEntity {

    internal static var entities: Set<HTMLEntity> = {
        let entities = HTMLEntitiesData
            .components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("//") }
            .flatMap(HTMLEntity.init)
        return Set(entities)
    }()

    public static func forName(_ name: String) -> HTMLEntity? {
        let results = entities.filter({ $0.entityName == name })
        guard results.count == 1, let result = results.first else { return nil }
        return result
    }

    public static func forValue(_ decimal: Int) -> HTMLEntity? {
        let results = entities.filter({ $0.entityValue == decimal })
        guard results.count == 1, let result = results.first else { return nil }
        return result
    }

    public static func forDecimal(_ decimal: String) -> HTMLEntity? {
        guard let value = Int(decimal.trimmingCharacters(in: CharacterSet(charactersIn: "&#;"))) else { return nil }
        return HTMLEntity.forValue(value)
    }

    public static func forHex(_ hex: String) -> HTMLEntity? {
        let chars = CharacterSet(charactersIn: "&#x;")
        guard let value = Int(hex.trimmingCharacters(in: chars), radix: 16) else { return nil }
        return HTMLEntity.forValue(value)
    }
}
