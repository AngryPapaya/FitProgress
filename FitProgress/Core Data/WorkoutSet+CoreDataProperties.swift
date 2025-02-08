//
//  Set+CoreDataProperties.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 08/02/2025.
//

import Foundation
import CoreData

extension WorkoutSet: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSet> {
        return NSFetchRequest<WorkoutSet>(entityName: "WorkoutSet")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var weight: Double
    @NSManaged public var repetitions: Int16
    @NSManaged public var exercise: Exercise? // Relación inversa con Exercise
}
