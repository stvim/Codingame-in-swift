//
//  Level5.swift
//  Challenge2024Spring
//
//  Created by Steven Morin on 27/03/2024.
//
import CodingameCommon

import Foundation

typealias Canvas = [[Bool]]
typealias MaskCanvas = Canvas
typealias RowIndex = Int
typealias ColumnIndex = Int
typealias Line = [Bool]
enum Command : CustomStringConvertible {
    var description: String {
        switch(self) {
        case .FillColumn(let index):
            return "C \(index)"
        case .DeleteRow(let index):
            return "R \(index)"
        }
    }
    
    case FillColumn(index:ColumnIndex)
    case DeleteRow(index:RowIndex)
    
}

func solve(n: Int, targetImage: [String]) -> [String]? {
    // Write your code here

    var mask : MaskCanvas = [[Bool]](repeating: [Bool](repeating: false, count: n)
                                   , count: n)
    
    
    var canvas : [[Bool]] = targetImage.map {
        line in
        line.map{ $0 == "#" }
    }
    
    var commands = [Command]()
    var keepSearching = true
    
    while(keepSearching) {
        let emptyRows = findEmptyRows(in: canvas, with: mask)
        if !emptyRows.isEmpty {
            keepSearching = true
            emptyRows.forEach{
                commands.insert(.DeleteRow(index: $0), at: 0)
                mask = fill(mask, with: true, atRowIndex: $0)
            }
        } else {
            let fullColumns = findFullColumns(in: canvas, with: mask)
            if !fullColumns.isEmpty {
                keepSearching = true
                fullColumns.forEach{
                    commands.insert(.FillColumn(index: $0), at: 0)
                    mask = fill(mask, with: true, atColumnIndex: $0)
                }
            } else {
                keepSearching = false
            }
        }
    }
    
    debug(commands.map{ String(describing:$0) })
    return commands.map{ String(describing:$0) }
}

// mask contains true where cells are masked so not read
func findEmptyRows(in canvas:Canvas, with mask:MaskCanvas) -> [RowIndex] {
    var result = [RowIndex]()
    canvas.enumerated().forEach {
        (rowIndex,row) in
        // if this row is not entirely masked
        if mask[rowIndex].filter({ $0 == false }).count > 0 {
            if zip(row, mask[rowIndex])
                .filter({$0 == false || $1 == true}).count == row.count
            {
                result.append(rowIndex)
            }
        }
    }
    return result
}
func findFullColumns(in canvas:Canvas, with mask:MaskCanvas) -> [ColumnIndex] {
    var result = [ColumnIndex]()
    canvas.first!.indices.forEach {
        columnIndex in
        let column = canvas.map{ $0[columnIndex] }
        let maskColumn = mask.map{ $0[columnIndex] }

        // if this column is not entirely masked
        if maskColumn.filter({ $0 == false }).count > 0 {
            if zip(column, maskColumn).filter({ $0 == true || $1 == true }).count == column.count {
                result.append(columnIndex)
            }
        }
    }
    return result
}

func fill(_ canvas:Canvas,with value:Bool,atRowIndex:RowIndex) -> Canvas {
    return canvas.enumerated().map{
        (rowIndex,row) in
        if rowIndex == atRowIndex {
            return [Bool](repeating: value, count: row.count)
        } else {
            return row
        }
    }
}


func fill(_ canvas:Canvas,with value:Bool,atColumnIndex:RowIndex) -> Canvas {
    return canvas.map{
        row in
        row.enumerated().map {
            (columnIndex, cell) in
            if columnIndex == atColumnIndex {
                return value
            } else {
                return cell
            }
        }
    }
}

