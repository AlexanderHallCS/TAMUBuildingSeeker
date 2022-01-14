//
//  MLModelManager.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 1/14/22.
//

import Foundation

class MLModelManager {
      static  func renameResult(result: String) -> String {
        switch result {
        case "ANNEX_LIBR":
            return "Evans Library Annex"
        case "Biological Sciences Building East (BSBE) - Department of Biology":
            return "Biological Sciences Building East"
        case "BSBW":
            return "Biological Sciences Building West"
        case "BTLR":
            return "Butler Hall"
        case "EABAA":
            return "Engineering Activity Building"
        case "EABAB":
            return "Engineering Activity Building"
        case "EABAC":
            return "Engineering Activity Building"
        case "HELD":
            return "Heldenfelds Hall"
        case "LAAH":
            return "Liberal Arts & Humanities Building"
        case "Military Sciences Building(Trigon)":
            return "Trigon"
        case "PAV":
            return "Pavilion"
        case "PETR":
            return "Peterson Building"
        case "RDER":
            return "Rudder Tower"
        case "SBISA":
            return "SBISA Dining Hall"
        case "SCC":
            return "Student Computing Center"
        case "Texas A_M Prospective Student Center - Aggieland":
            return "Koldus Building"
        default:
            return result
        }
    }
}
