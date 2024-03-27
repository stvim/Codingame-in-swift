//
//  Level6.swift
//  Challenge2024Spring
//
//  Created by Steven Morin on 27/03/2024.
//

import Foundation

func getCableLength(nRows: Int, nCols: Int, image: [String]) -> Int? {
    let distance = getCableVerticalLength(image:image) + getCableVerticalLength(image: getRotated(image))
    return distance % 1000000007
}

func getCableVerticalLength(image: [String]) -> Int {
    // Write your code here
    
    var cellsRowDistance = [Character:(cells:Int,distance:Int)]()
    var totalDistance : Int = 0
    image.enumerated().forEach{
        (rowIndex,row) in


        let thisRowColors = Set<Character>(row)

        // Adding in dictionary the new colors if necessary
        thisRowColors
            .subtracting(cellsRowDistance.keys)
            .forEach{
                cellsRowDistance[$0] = (cells:0, distance:0)
            }
        
        // computing distance for every color with the dictionary
        cellsRowDistance.keys.forEach{
            currentColor in
            
            let cellsOfCurrentColorInRow = row.filter({ $0 == currentColor}).count
            if cellsOfCurrentColorInRow > 0 {
                let verticalDistanceToEveryPreviousCells = cellsRowDistance[currentColor]!.distance
                let newCablesToWireLength = cellsOfCurrentColorInRow * verticalDistanceToEveryPreviousCells
                
                totalDistance += 2*(newCablesToWireLength)
            }
            
            // now preparing dictionary of distances for next row : adding 1 to distance for every known cell
            let previousCells = cellsRowDistance[currentColor]!.cells
            let previousDistance = cellsRowDistance[currentColor]!.distance
            let newCells = previousCells + cellsOfCurrentColorInRow
            let newDistance = previousDistance + newCells
            
            cellsRowDistance[currentColor] = (cells: newCells
                                              , distance: newDistance)
        }
            
        totalDistance = totalDistance % 1000000007
    }
    
    return totalDistance
}

func getRotated(_ input: [String]) -> [String] {

    var canvas : [[String]] = input.map {
        line in
        line.map{ String($0) }
    }
    
    return canvas.first!.indices.map{
        columnIndex in
        
        return canvas.map{
            line in
            line[columnIndex]
        }.joined(separator: "")
    }
}


