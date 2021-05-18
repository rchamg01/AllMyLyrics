//
//  Artist+CoreDataProperties.swift
//  pruebaPeticiones
//
//  Created by RAQUEL CHAMORRO GIGANTO on 19/04/2021.
//
//

import Foundation
import CoreData


extension Artist {

    @NSManaged public var name: String?
    @NSManaged public var artistSong: NSSet?

}
