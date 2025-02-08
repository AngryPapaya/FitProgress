//
//  Routine+CoreDataClass.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//
//

import Foundation
import CoreData

@objc(Routine)
public class Routine: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID() // Ensure unique ID is always set
    }
}
