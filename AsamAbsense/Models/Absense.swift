//
//  Absense.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

enum AbsenseType: CaseIterable {
    case vacation
    case workFromHome
    case sickLeave
    case personalDay
}

struct Absense {
    let id: String
    var type: AbsenseType
    var intervals: [DateInterval]
    var comment: String?
    var atachments: Set<URL>
}
