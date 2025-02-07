//
//  Routine+CoreDataProperties.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//
//

import Foundation
import CoreData

extension Routine: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Routine> {
        return NSFetchRequest<Routine>(entityName: "Routine")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var date: Date? // Asegúrate de que esta línea esté presente
    @NSManaged public var exercises: NSSet?
}

// MARK: - Generated accessors for exercises
extension Routine {
    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)
}
