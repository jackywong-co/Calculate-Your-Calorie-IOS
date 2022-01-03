//
//  Item+CoreDataProperties.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 3/1/2022.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    @NSManaged public var calories: Double
    @NSManaged public var category: String?
    @NSManaged public var date: String?
    @NSManaged public var foodname: String?
    @NSManaged public var id: UUID?
    @NSManaged public var period: String?
    @NSManaged public var image: Data?

}

extension Food : Identifiable {

}
