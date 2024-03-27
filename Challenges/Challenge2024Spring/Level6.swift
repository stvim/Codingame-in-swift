//
//  Level6.swift
//  Challenge2024Spring
//
//  Created by Steven Morin on 27/03/2024.
//

import Foundation

func getCableLength(nRows: Int, nCols: Int, image: [String]) -> Int? {
    return getCableVerticalLength(image:image) + getCableVerticalLength(image: getRotated(image))
}

func getCableVerticalLength(image: [String]) -> Int {
    // Write your code here
    
    var cellsByRowDistance = [Character:[Int]]()
    var totalDistance : Int = 0
    image.enumerated().forEach{
        (rowIndex,row) in
        // new row : Shifting previous cells distances by 1 in lists
        cellsByRowDistance.keys.forEach{
            cellsByRowDistance[$0]!.insert(0, at: 0)
        }
        let thisRowColors = Set<Character>(row)
        // looking for new colors
        thisRowColors
            .subtracting(cellsByRowDistance.keys)
            .forEach{
                cellsByRowDistance[$0] = [0]
            }
        // computing distance for every color
        thisRowColors.forEach{
            currentColor in
            let cellsOfCurrentColorInRow = row.filter({ $0 == currentColor}).count
            // updating dictionary with this row
            cellsByRowDistance[currentColor]![0] = cellsOfCurrentColorInRow
            let verticalDistanceToEveryPreviousCells = cellsByRowDistance[currentColor]!
                .enumerated()
                .map{ (index,value) in index * value }
                .reduce(0, { $0 + $1 })
            let newCablesToWireLength = cellsOfCurrentColorInRow * verticalDistanceToEveryPreviousCells
            
            totalDistance += 2*(newCablesToWireLength)
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


