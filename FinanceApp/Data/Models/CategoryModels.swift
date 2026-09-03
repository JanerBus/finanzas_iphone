import Foundation
import SwiftData

@Model
public final class Category {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var icon: String
    public var isDefault: Bool
    public var isActive: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Subcategory.category)
    public var subcategories: [Subcategory] = []
    
    public init(id: UUID = UUID(), name: String, icon: String, isDefault: Bool = false, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
        self.isActive = isActive
    }
}

@Model
public final class Subcategory {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var isActive: Bool
    
    public var category: Category?
    
    public init(id: UUID = UUID(), name: String, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.isActive = isActive
    }
}
