//
//  Set+CoreDataProperties.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 08/02/2025.
//

import Foundation
import CoreData

extension ExerciseSet: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseSet> {
        return NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var repetitions: Int16
    @NSManaged public var exercise: Exercise?
}
