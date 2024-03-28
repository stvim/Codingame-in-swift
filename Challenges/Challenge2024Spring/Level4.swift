//
//  Level4.swift
//  Challenge2024Spring
//
//  Created by Steven Morin on 27/03/2024.
//

import Foundation

struct Size2D : Equatable {
    var rows, columns : Int
    
    func contains(_ location:Location2D) -> Bool {
        return location.row >= 0 && location.column >= 0 && location.row <= rows && location.column <= columns
    }
}

struct Rect2D : Equatable {
    var upLeftCorner, bottomRightCorner : Location2D

    
    func getLocations() -> Set<Location2D> {
        var result = Set<Location2D>()
        for row in upLeftCorner.row...bottomRightCorner.row {
            for column in upLeftCorner.column...bottomRightCorner.column {
                result.insert(Location2D(row: row, column: column))
            }
        }
        return result
    }
}

struct Location2D : Equatable, Hashable {
    let row:Int
    let column:Int
}

typealias Color = UInt8
typealias Canvas = [[Color]]

func findLargestCircle(nRows: Int, nCols: Int, image: [String]) -> [Int]? {
    
    var canvas : [[Color]] = image.map {
        line in
        line.map{ $0.asciiValue! }
    }
    let canvasSize = Size2D(rows: nRows, columns: nCols)
    
    
    var lookForCircleRadius = (min(nRows,nCols)-1) / 2
    var circleFound : (center:Location2D, radius:Int)? = nil
    
    while circleFound == nil {
        let possibleCenters = getPossibleCenters(ofCircleOfSize: lookForCircleRadius, in: canvasSize)
        var relativeLocationsToExplore = relativeLocationsToExploreForCircle(radius: lookForCircleRadius)
        
        for center in possibleCenters {
            if findCircle(in: canvas
                          , exploreRelativeLocations: &relativeLocationsToExplore
                          , center: center
                          , radius: lookForCircleRadius)
            {
                circleFound = (center:center, radius:lookForCircleRadius)
                break
            }
        }
        
        lookForCircleRadius -= 1
    }
    
    if let result = circleFound {
        return [result.center.row, result.center.column, result.radius]
    } else {
        return nil
    }
}

func getPossibleCenters(ofCircleOfSize circleSize:Int, in canvasSize:Size2D) -> Set<Location2D> {
    let minLocation = Location2D(row: circleSize, column: circleSize)
    let maxLocation = Location2D(row: canvasSize.rows - 1 - circleSize
                                 , column: canvasSize.columns - 1 - circleSize)
    
    return Rect2D(upLeftCorner: minLocation, bottomRightCorner: maxLocation).getLocations()
}

func euclidianDistanceBetween(_ l1:Location2D, _ l2:Location2D) -> Int {
    return Int(sqrt(pow(Double(l1.row-l2.row),2) + pow(Double(l1.column-l2.column),2)))
}


func relativeLocationsToExploreForCircle(radius:Int) -> Set<Location2D> {
    
    let minLocation = Location2D(row: -radius, column: -radius)
    let maxLocation = Location2D(row: +radius, column: +radius)
    // Looking for coordinates inside the big rectangle to exclude because the circle cannot be into
    // Calculating the minimum offset from center satifying sqrt(x**x + x**x) = radius
    let offsetToExcludedInnerRect = Int(sqrt(pow(Double(radius),2) / 2))
    
    let excludedInnerRectUpLeftCorner = Location2D(row: -offsetToExcludedInnerRect
                                                   , column: -offsetToExcludedInnerRect)
    let ExcludedInnerRectBottomRightCorner = Location2D(row: +offsetToExcludedInnerRect
                                                        , column: +offsetToExcludedInnerRect)
    
    let locationsToExplore = {
        Rect2D(upLeftCorner: minLocation, bottomRightCorner: maxLocation)
            .getLocations()
            .subtracting(Rect2D(upLeftCorner: excludedInnerRectUpLeftCorner
                                , bottomRightCorner: ExcludedInnerRectBottomRightCorner).getLocations())
    }()
    
    return locationsToExplore
}

func findCircle(in canvas:Canvas
                , exploreRelativeLocations relativeLocations:inout Set<Location2D>
                , center:Location2D
                , radius:Int
) -> Bool
{
    
    
    var colorOfCircle : Color? = nil
    
    for relativeLocation in relativeLocations {
        let location = Location2D(row: center.row + relativeLocation.row
                                  , column: center.column + relativeLocation.column)
        if euclidianDistanceBetween(location, center) != radius {
            relativeLocations.remove(relativeLocation)
        } else {
            if let colorOfCircle = colorOfCircle {
                if canvas[location.row][location.column] != colorOfCircle {
                    return false
                }
            } else {
                colorOfCircle = canvas[location.row][location.column]
            }
        }
    }
    return true
}
