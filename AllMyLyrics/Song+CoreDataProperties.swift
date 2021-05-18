//
//  Song+CoreDataProperties.swift
//  pruebaPeticiones
//
//  Created by RAQUEL CHAMORRO GIGANTO on 19/04/2021.
//
//

import Foundation
import CoreData


extension Song {

    @NSManaged public var lyrics: String?
    @NSManaged public var title: String?
    @NSManaged public var songArtist: Artist?

}
