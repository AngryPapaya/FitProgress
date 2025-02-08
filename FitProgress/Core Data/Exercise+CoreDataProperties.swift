//
//  Exercise+CoreDataProperties.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//
//

import Foundation
import CoreData

extension Exercise: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var weight: Double
    @NSManaged public var repetitions: Int16
    @NSManaged public var date: Date?
    @NSManaged public var routine: Routine?
    @NSManaged public var sets: NSSet? // Añadir relación con WorkoutSet
}

// MARK: - Generated accessors for sets
extension Exercise {
    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: WorkoutSet)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: WorkoutSet)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)
}
