
//import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

let gameTurnsTotal = 200

public class Cell : Hashable {
    let x, y, idx : Int
    static var mapWidth : Int = 0
    var subidx : Int = -1

    init(_ x:Int,_ y:Int) {
        self.x = x
        self.y = y
        assert(x<Cell.mapWidth && x>=0 && y>=0, "Incorrect Position")
        self.idx = y * Cell.mapWidth + x
    }

    //var idx : Int { y * Cell.mapWidth + x }
    
    func outputXY () -> String {
        return ("\(x) \(y)")
    }

    // Hashable implementation
    public static func == (lhs:Cell,rhs:Cell) -> Bool {
        return lhs.idx == rhs.idx // lhs.x == rhs.x && lhs.y == rhs.y
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(idx)
        //hasher.combine(y)
    }
}



class ComputedCell : Hashable {
    let mapCell : MapCell
    let cell : Cell
    let idx : Int
    var subidx : Int { cell.subidx }
    
    var neighborCells : [Cell] = []
    var neighborIdx : [Int] = []
    var neighborSubidx : [Int] = []
    //var neighborCellsForRecycler : [Cell] = []

    var linkedCellsByDistance : [Set<Cell>] = []
    var linkedCellsUnvisited = Set<Cell>()
    var moveScore : Double = 0.0
    var recyclerScore : Int = 0

    init(mapCell:MapCell){
        self.mapCell = mapCell
        self.cell = mapCell.cell
        self.idx = cell.idx
    }

    //var calcMovesVisitedComputedCells = [computedCell]()
    // Hashable implementation
    public static func == (lhs:ComputedCell,rhs:ComputedCell) -> Bool {
        return lhs.idx == rhs.idx
    }
    public func hash(into hasher: inout Hasher) {
        self.cell.hash(into:&hasher)
    }
}


class MapCell {
    static var gameTurn = 0

    let cell : Cell //x, y : Int

    // the number of times this tile can be recycled before becoming Grass.
    let scrap : Int
    
    // 1 if you control this mapCell.    0 if your opponent controls this mapCell.    -1 otherwise.
    let owner : Int
    
    // the number of units on this mapCell. These units belong to the owner of the mapCell.
    let units : Int
    
    // True if there is a recycler on this mapCell. This recycler belongs to the owner of the mapCell.
    let recycler : Bool
    
    // True if you are allowed to BUILD a recycler on this tile this turn
    let canBuild  : Bool
    
    // True if you are allowed to SPAWN units on this tile this turn
    let canSpawn  : Bool
    
    // True if this tile's scrapAmount will be decreased at the end of the turn by a nearby recycler
    let inRangeOfRecycler  : Bool

    var scrapToRecycle : Int {
        let gameTurnsLeft = gameTurnsTotal - MapCell.gameTurn
        //return Double(scrap > gameTurnsLeft ? gameTurnsLeft : scrap) / Double(gameTurnsLeft)
        return (scrap > gameTurnsLeft ? gameTurnsLeft : scrap)
    }
 
    init(   x:                  Int
            ,y:                 Int
            ,scrap:             Int
            ,owner:             Int
            ,units:             Int
            ,recycler:          Bool
            ,canBuild:          Bool
            ,canSpawn:          Bool
            ,inRangeOfRecycler: Bool) {
        self.cell = Cell(x,y)
        self.scrap = scrap
        self.owner = owner
        self.units = units
        self.recycler = recycler
        self.canBuild = canBuild
        self.canSpawn = canSpawn
        self.inRangeOfRecycler = inRangeOfRecycler

    }
}

class Submap {
    var cells = Array<Cell>()
    var computedCells = Array<ComputedCell>()
    var myRobots = Array<Cell>()
    var enemyRobots = Array<Cell>()
    var myRecyclers = Array<Cell>()
    var enemyRecyclers = Array<Cell>()

    // only for Floyd Warshall version :
    var pathMatrix = [[Int?]]()
    var cellsInPathMatrix = [Cell:Int]()
    
    var recyclerScoreBestValue = 0
    var recyclerScoreBestCell : Cell?
    var spawnScoreBestValue = 0.0
    var spawnScoreBestCell : Cell?
    var enemyCellsCount = 0
    var myCellsCount = 0
}

class Map {
    let allMoveableCellsDic : [Cell:ComputedCell]
    let allRecyclersCellsDic : [Cell:ComputedCell]
    let myMatter: Int
    let enemyMatter: Int
    //var visitedCells : [Set<Cell>] = []
    var nonVisitedCells = Set<Cell>()
    var count = 0
    var myRecyclersCount = 0
    var enemyRecyclersCount = 0
    var myRecyclersGain = 0
    var enemyRecyclersGain = 0

    var submaps = [Submap]()

    init(allMoveableCellsDic:[Cell:ComputedCell],allRecyclersCellsDic:[Cell:ComputedCell], myMatter:Int, enemyMatter:Int) {
        self.allMoveableCellsDic = allMoveableCellsDic
        self.allRecyclersCellsDic = allRecyclersCellsDic
        self.myMatter = myMatter
        self.enemyMatter = enemyMatter
        nonVisitedCells = Set(allMoveableCellsDic.keys)
    }
}


func calculateShorterPathsByFloydWarshall(map:Map,submap:Submap) {
    let n = submap.cells.count
    submap.cellsInPathMatrix = [Cell:Int]()
    for i in 0..<n {
        submap.cellsInPathMatrix[submap.cells[i]] = i
    }

    var mat = [[Int?]](repeating : [Int?](repeating: nil, count: n), count: n)
    for ix in 0..<n {
        for iy in 0..<n {
            if iy == ix {
                mat[iy][ix] = 0
            }
        }
    }

    for cell in submap.cells {
            let computedCell = map.allMoveableCellsDic[cell]!
            let i1 = submap.cellsInPathMatrix[cell]!
            for neighborPos in computedCell.neighborCells {
                let i2 = submap.cellsInPathMatrix[neighborPos]!
                mat[i1][i2] = 1
                mat[i2][i1] = 1
            }
    }
    var matMin = mat
    for ix in 0..<n {
        if matMin[iy][ix] == nil {
            matMin[iy][ix] = abs(submap.cells[ix].x-submap.cells[iy].x)
                            + abs(submap.cells[ix].y-submap.cells[iy].y)
        }
        for iy in ix+1..<n {
        }
        if matMin[iy][ix] == nil {
            matMin[iy][ix] = abs(submap.cells[ix].x-submap.cells[iy].x)
                            + abs(submap.cells[ix].y-submap.cells[iy].y)
        }
    }

    var turns = 0
    //var turnsNextPrint = 10000
    for k in 0..<n-1 {
        let prevMat = mat
        for ix in 0..<n {
            for iy in ix+1..<n {
                if (mat[iy][ix] ?? n) > matMin[iy][ix]! {
                    turns += 1
                    let v1 = prevMat[iy][ix] ?? n+1
                    let v2 = (prevMat[iy][k+1] ?? n+1) &+ (prevMat[k+1][ix] ?? n+1)
                    let min_v = min(v1,v2)
                    mat[iy][ix] = (min_v > n ? nil : min_v)
                    mat[ix][iy] = mat[iy][ix]
                }
            }
            /*
            if turns > turnsNextPrint {
                turnsNextPrint += 10000
                print("turns:\(turns)", to:&errStream)
            }
            */
            if turns > 100000 {
                break
            }
        }
        if turns > 100000 {
            break
        }
    }
    

    //var scoreBestValue = 0
    for iy in 0..<n {
        let iyCell = submap.cells[iy]
        var score = 0.0
        for ix in iy..<n {
            let ixCell = submap.cells[ix]
            if map.allMoveableCellsDic[ixCell]!.mapCell.owner != 1 {
                if let v = mat[iy][ix] {
                    score += (1/((Double(v)+1)*(Double(v)+1)))
                }
            }
        }
        //print(score, to:&errStream)
        var computedCell = map.allMoveableCellsDic[iyCell]!
        computedCell.moveScore = score
        
        let spawnScore = computedCell.mapCell.canSpawn ? score : 0
        if submap.spawnScoreBestValue < spawnScore {
            submap.spawnScoreBestValue = spawnScore
            submap.spawnScoreBestCell = iyCell
        }
    }
    submap.pathMatrix = mat
}

func calculateShorterPathsByFillingByCell(map:Map,submap:Submap) {
    let n = submap.cells.count
    for cell in submap.cells {
        var computedCell = map.allMoveableCellsDic[cell]!
        computedCell.linkedCellsUnvisited = Set(submap.cells)
        computedCell.linkedCellsUnvisited.remove(cell)
        computedCell.linkedCellsByDistance = [Set<Cell>]()
        computedCell.linkedCellsByDistance.append(Set<Cell>())
        computedCell.linkedCellsByDistance[0].insert(cell) // neighbor at depth zero is the cell itself
        computedCell.moveScore = 0
    }

    var cellsToVisit = (submap.cells.count-1) * submap.cells.count
    //func deepCalc(map:Map,submap:Submap, computedCell:ComputedCell, depth:Int) {
    var depth = 0
    var debug1 = 0
    var debug1LastPrint = 500
    while depth < n && cellsToVisit > 0 {
        var cellNum = 0
        for cell in submap.cells {
            cellNum += 1
            var computedCell = map.allMoveableCellsDic[cell]!
            
            var nextDepthNeighborsCandidates = Set<Cell>()
            
            var debug2 = 0
            var debug3 = 0
            for currentDepthLinkedCell in computedCell.linkedCellsByDistance[depth] {
                let currentDepthLinkedComputedCell = map.allMoveableCellsDic[currentDepthLinkedCell]!
                debug2 += 1
                if currentDepthLinkedComputedCell.mapCell.owner != 1 {
                    debug3 += 1
                    computedCell.moveScore += (1/((Double(depth)+1)*(Double(depth)+1)))
                }
                //print("currentDepthLinkedComputedCell.neighborCells: \(currentDepthLinkedComputedCell.neighborCells)", to: &errStream)

                //for nextDepthNeighbor in currentDepthLinkedComputedCell.neighborCells {
                  //  var currentDepthNeighborsComputedCell = map.allMoveableCellsDic[cell]!
                nextDepthNeighborsCandidates = nextDepthNeighborsCandidates.union(currentDepthLinkedComputedCell.neighborCells) // non ce sont les voisins à récupérer
                
                //}
            }
            debug1 += 1
            if debug1 > debug1LastPrint {
                debug1LastPrint += 500
                print("Debug1:",debug1," - depth:",depth," - cellsToGo:",cellsToVisit, to: &errStream)
                print("Debug2,3 : \(debug2), \(debug3)", to: &errStream)
            }

            let nextDepthNeighbors = nextDepthNeighborsCandidates.intersection(computedCell.linkedCellsUnvisited)
            if cellNum == 0 {
                print("nextDepthNeighborsCandidates: \(nextDepthNeighborsCandidates.count)", to: &errStream)
                print("nextDepthNeighbors (after intesection): \(nextDepthNeighbors.count)", to: &errStream)
            }
            computedCell.linkedCellsByDistance.append(nextDepthNeighbors)
            if nextDepthNeighbors.count > 0 {
                cellsToVisit -= nextDepthNeighbors.count
                if cellNum == 0 {
                    print("linkedCellsUnvisited: \(computedCell.linkedCellsUnvisited.count)", to: &errStream)
                }
                computedCell.linkedCellsUnvisited = computedCell.linkedCellsUnvisited.subtracting(nextDepthNeighbors)
                if cellNum == 0 {
                    //print("linkedCellsUnvisited (after substract): \(computedCell.linkedCellsUnvisited.count)", to: &errStream)
                }
            }
            if debug1 > 1000 {
                break
            }
        }
        if debug1 > debug1LastPrint {
            debug1LastPrint += 10000
            print("Debug1:",debug1," - depth:",depth," - cellsToGo:",cellsToVisit, to: &errStream)
        }
        if debug1 > 1000 {
            break
        }
        depth += 1
    }

    for cell in submap.cells {
        let computedCell = map.allMoveableCellsDic[cell]!
        let spawnScore = computedCell.mapCell.canSpawn ? computedCell.moveScore : 0
        if submap.spawnScoreBestValue < spawnScore {
            submap.spawnScoreBestValue = spawnScore
            submap.spawnScoreBestCell = cell
        }
    }
   
}

func calculateShorterPathsByCellV2(map:Map,submap:Submap) {
    let n = submap.cells.count
    for cell in submap.cells {
        var computedCell = map.allMoveableCellsDic[cell]!
        computedCell.linkedCellsUnvisited = Set(submap.cells)
        computedCell.linkedCellsUnvisited.remove(cell)
        computedCell.linkedCellsByDistance = [Set<Cell>]()
        computedCell.linkedCellsByDistance.append(Set<Cell>())
        computedCell.linkedCellsByDistance[0].insert(cell) // neighbor at depth zero is the cell itself
        computedCell.moveScore = 0
    }
    
    //func deepCalc(map:Map,submap:Submap, computedCell:ComputedCell, depth:Int) {
    var cellsToVisitByPriority = [Array<Cell>](repeating:Array<Cell>(), count:2)
    var cellsCandidates1 = Set<Cell>()
    for cellOfRobot in submap.myRobots {
        for cell in map.allMoveableCellsDic[cellOfRobot]!.neighborCells {
            cellsCandidates1.insert(cell)
        }
    }
    cellsToVisitByPriority[0].append(contentsOf: cellsCandidates1)
    
    for cell in submap.cells {
        if map.allMoveableCellsDic[cell]!.mapCell.owner == 1 {
            cellsToVisitByPriority[1].append(cell)
        }
    }
    cellsToVisitByPriority[0].append(contentsOf: cellsCandidates1)
    
    var debug1 = 0
    let debug1PrintPeriod = 100
    var debug1LastPrint = debug1PrintPeriod
    let debug1limit = 500
    
    for cellsToVisit in cellsToVisitByPriority {
        var cellsToVisitCounter = (cellsToVisit.count-1) * cellsToVisit.count
        var depth = 0
        
        while depth < n && cellsToVisitCounter > 0 {
            var cellNum = 0
            for cell in cellsToVisit {
                cellNum += 1
                var computedCell = map.allMoveableCellsDic[cell]!
                
                var nextDepthNeighborsCandidates = Set<Cell>()
                
                //var debug2 = 0
                //var debug3 = 0
                for currentDepthLinkedCell in computedCell.linkedCellsByDistance[depth] {
                    let currentDepthLinkedComputedCell = map.allMoveableCellsDic[currentDepthLinkedCell]!
                    //debug2 += 1
                    if currentDepthLinkedComputedCell.mapCell.owner != 1 {
                        //debug3 += 1
                        computedCell.moveScore += (1/((Double(depth)+1)*(Double(depth)+1)))
                    }
                    //print("currentDepthLinkedComputedCell.neighborCells: \(currentDepthLinkedComputedCell.neighborCells)", to: &errStream)
                    
                    //for nextDepthNeighbor in currentDepthLinkedComputedCell.neighborCells {
                    //  var currentDepthNeighborsComputedCell = map.allMoveableCellsDic[cell]!
                    nextDepthNeighborsCandidates = nextDepthNeighborsCandidates.union(currentDepthLinkedComputedCell.neighborCells) // non ce sont les voisins à récupérer
                    
                    //}
                }
                let nextDepthNeighbors = nextDepthNeighborsCandidates.intersection(computedCell.linkedCellsUnvisited)
                if cellNum == 0 {
                    print("nextDepthNeighborsCandidates: \(nextDepthNeighborsCandidates.count)", to: &errStream)
                    print("nextDepthNeighbors (after intesection): \(nextDepthNeighbors.count)", to: &errStream)
                }
                computedCell.linkedCellsByDistance.append(nextDepthNeighbors)
                if nextDepthNeighbors.count > 0 {
                    cellsToVisitCounter -= nextDepthNeighbors.count
                    if cellNum == 0 {
                        print("linkedCellsUnvisited: \(computedCell.linkedCellsUnvisited.count)", to: &errStream)
                    }
                    computedCell.linkedCellsUnvisited = computedCell.linkedCellsUnvisited.subtracting(nextDepthNeighbors)

                }
                
                debug1 += 1
                if debug1 > debug1LastPrint {
                    debug1LastPrint += debug1PrintPeriod
                    print("Debug1:",debug1," - depth:",depth," - cellsToGo:",cellsToVisit, to: &errStream)
                    //print("Debug2,3 : \(debug2), \(debug3)", to: &errStream)
                }
                
                if debug1 > debug1limit {
                    break
                }
            }
            /*
            if debug1 > debug1LastPrint {
                debug1LastPrint += 10000
                print("Debug1:",debug1," - depth:",depth," - cellsToGo:",cellsToVisit, to: &errStream)
            }
            */
            if debug1 > debug1limit {
                break
            }
            depth += 1
        }
        if debug1 > debug1limit {
            break
        }
    }


    for cell in submap.cells {
        let computedCell = map.allMoveableCellsDic[cell]!
        let spawnScore = computedCell.mapCell.canSpawn ? computedCell.moveScore : 0
        if submap.spawnScoreBestValue < spawnScore {
            submap.spawnScoreBestValue = spawnScore
            submap.spawnScoreBestCell = cell
        }
    }
   
}

func showScoresMap(allMapCellsList:[MapCell], map:Map) {
    var idx = 0
    while idx < allMapCellsList.count {
        //for xi in 0..<Cell.mapWidth {
            if let computedCell = map.allMoveableCellsDic[allMapCellsList[idx].cell] {
                let p = Int(computedCell.moveScore)
                print(p > 9 ? "+" : p, terminator:" ", to: &errStream)
            }
            else {
                print(" ", terminator:" ", to: &errStream)
            }
            idx += 1
        //}
        if idx % Cell.mapWidth == 0 {
            print("", to: &errStream)
        }
    }
}

enum CommandType {
    case move, build, spawn, message
}

struct Command {
    let type : CommandType
    let commandMove : CommandMove?
    let commandBuild : CommandBuild?
    let commandSpawn : CommandSpawn?
    let commandMessage : CommandMessage?

    struct CommandMove {
        let from : Cell
        let to : Cell
        let numberOfRobots : Int
    }
    struct CommandBuild {
        let at : Cell
    }
    struct CommandSpawn {
        let at : Cell
        let numberOfRobots : Int
    }
    struct CommandMessage {
        let message : String
    }

    init(moveFrom:Cell,moveTo:Cell,numberOfRobots:Int = 1) {
        type = .move
        commandMove = CommandMove(from: moveFrom, to: moveTo, numberOfRobots: numberOfRobots)
        commandBuild = nil
        commandSpawn = nil
        commandMessage = nil
    }
    init(buildAt:Cell) {
        type = .build
        commandBuild = CommandBuild(at: buildAt)
        commandMove = nil
        commandSpawn = nil
        commandMessage = nil
    }
    init(spawnAt:Cell,numberOfRobots:Int=1) {
        type = .spawn
        commandSpawn = CommandSpawn(at: spawnAt, numberOfRobots: numberOfRobots)
        commandBuild = nil
        commandMove = nil
        commandMessage = nil
    }
    init(message:String) {
        type = .message
        commandMessage = CommandMessage(message:message)
        commandBuild = nil
        commandMove = nil
        commandSpawn = nil
    }

    func output () -> String {
        switch(type) {
            case .move:
                //if let cmd = commandMove {
                return "MOVE \(commandMove!.numberOfRobots) \(commandMove!.from.outputXY()) \(commandMove!.to.outputXY())"
                //}
            case .build:
                return "BUILD \(commandBuild!.at.outputXY())"
            case .spawn:
                return "SPAWN \(commandSpawn!.numberOfRobots) \(commandSpawn!.at.outputXY())"
            default:
                return "MESSAGE \(commandMessage!.message)"
        }
    }
}






func calculateMapData(_ map:Map) {

    func recursiveExploreSubmap(map:Map, submap:Submap, cell:Cell, counter:Int) {
        if map.nonVisitedCells.contains(cell) {
            let computedCell = map.allMoveableCellsDic[cell]!
            map.nonVisitedCells.remove(cell)
            submap.cells.append(cell)
            submap.computedCells.append(computedCell)
            cell.subidx = counter

            // calculate presence of recyclers and gain provided
            switch (computedCell.mapCell.owner) {
                case 1 :
                    submap.myCellsCount += 1
                case 0 :
                    submap.enemyCellsCount += 1
                default :
                    let _ = 0
            }

            // calculate robots values of submap
            if computedCell.mapCell.units > 0 {
                var robotCells = Array<Cell>(repeating: cell, count: computedCell.mapCell.units)
                if computedCell.mapCell.owner == 1 {
                    submap.myRobots += robotCells
                }
                else {
                    submap.enemyRobots += robotCells
                }
                
            }
            
            // Calculate scores about building recyclers
            var recyclerScore = 0
            var ComputedCellScrapToRecycle = 0
            if computedCell.mapCell.canBuild && computedCell.mapCell.owner == 1 && computedCell.mapCell.inRangeOfRecycler == false {
                ComputedCellScrapToRecycle = computedCell.mapCell.scrapToRecycle
                recyclerScore = ComputedCellScrapToRecycle * ComputedCellScrapToRecycle
            }
            for neighborPos in computedCell.neighborCells {
                let neighbor = map.allMoveableCellsDic[neighborPos]!
                let neighborScrapToRecycle = neighbor.mapCell.scrapToRecycle > ComputedCellScrapToRecycle ? ComputedCellScrapToRecycle : neighbor.mapCell.scrapToRecycle
                recyclerScore = recyclerScore * (neighborScrapToRecycle * neighborScrapToRecycle)
                
                recursiveExploreSubmap(map:map, submap:submap, cell:neighborPos, counter:counter+1)
            }
            computedCell.recyclerScore = recyclerScore

            if submap.recyclerScoreBestValue < recyclerScore {
                submap.recyclerScoreBestValue = recyclerScore
                submap.recyclerScoreBestCell = cell
            }
        }
    }

    func calculateNeighorsSubidx(map:Map, submap:Submap) {
        for subidx in 0..<submap.cells.count {
            for neighbor in submap.computedCells[subidx].neighborCells {
                submap.computedCells[subidx].neighborSubidx.append(neighbor.subidx)
            }
        }
    }

    func calculateRecyclersGain(map:Map) {
        for cell in map.allRecyclersCellsDic.keys {
            let computedCell = map.allRecyclersCellsDic[cell]!
                    // calculate presence of recyclers and gain provided
            var recyclerGain = 0
            for neighbor in computedCell.neighborCells {
                if map.allMoveableCellsDic[neighbor] != nil {
                    recyclerGain += 1
                }
                if map.allRecyclersCellsDic[neighbor] != nil {
                    recyclerGain += 1
                }
            }
            switch (computedCell.mapCell.owner) {
                case 1 :
                    map.myRecyclersCount += 1
                    map.myRecyclersGain += recyclerGain
                case 0 :
                    map.enemyRecyclersCount += 1
                    map.enemyRecyclersGain += recyclerGain
                default :
                    let _ = 0
            }
        }
    }

    while let cellToVisit = map.nonVisitedCells.first {
        var submap = Submap()
        map.submaps.append(submap)
        recursiveExploreSubmap(map:map, submap:submap, cell:cellToVisit, counter:0)
        calculateNeighorsSubidx(map:map, submap:submap)

        print("Submap n°\(map.submaps.count) : ComputedCells:\(submap.cells.count), myRobots:\(submap.myRobots.count), enemyRobots:\(submap.enemyRobots.count)", to: &errStream)
        //calculateShorterPathsByFloydWarshall(map: map, submap: submap)
        calculateShorterPathsByFilling(map: map, submap: submap)
    }
    calculateRecyclersGain(map:map)
}


func getMoveCommands(map:Map) -> Array<Command> {
    var answer = Array<Command>()
    
    for submap in map.submaps {
        for robotPos in submap.myRobots {
            var bestNeighborScore = 0.0
            var bestNeighbor : Cell?
            for neighborPos in map.allMoveableCellsDic[robotPos]!.neighborCells {
                let neighborComputedCell = map.allMoveableCellsDic[neighborPos]!
                if neighborComputedCell.moveScore > bestNeighborScore {
                    bestNeighborScore = neighborComputedCell.moveScore
                    bestNeighbor = neighborPos
                }
            }
            if bestNeighbor == nil {
                bestNeighbor = map.allMoveableCellsDic[robotPos]!.neighborCells.randomElement()
            }

            if let bestNeighbor = bestNeighbor {
                answer.append(Command(moveFrom: robotPos, moveTo: bestNeighbor))
                map.allMoveableCellsDic[bestNeighbor]!.moveScore -= 1.0
            }
        }
    }
    
    return answer
}

func getBuildCommands(map:Map) -> Array<Command> {
    var answer = Array<Command>()
    
    var enemyRobotsTotal = 0
    var myRobotsTotal = 0
    var submapToBuild : Submap?
    var submapDominationRatioWorst : Double = 1
    var submapDominationRatio : Double = 1

    var myAttackValue = 0
    var enemyAttackValue = 0
    for submap in map.submaps {

        enemyRobotsTotal += submap.enemyRobots.count
        myRobotsTotal += submap.myRobots.count

        submapDominationRatio = Double(submap.cells.count - submap.enemyCellsCount) / Double(submap.cells.count)
        //print("submap.cells.count - submap.enemyCellsCount : ",submap.cells.count, submap.enemyCellsCount, to: &errStream)        //let myValue = (submap.myRobots.count*10)+map.myMatter
        //print("submapDominationRatio : ",submapDominationRatio, to: &errStream)        //let myValue = (submap.myRobots.count*10)+map.myMatter

        if submap.myCellsCount > 0 && submapDominationRatioWorst > submapDominationRatio {
            submapDominationRatioWorst = submapDominationRatio
            submapToBuild = submap
        }

        if submap.myCellsCount > 0 && submap.enemyCellsCount > 0 {
            myAttackValue += submap.myRobots.count * 10
            enemyAttackValue += submap.enemyRobots.count * 10
        }
    }
    if let submapToBuild = submapToBuild {
        if let CellToBuild = submapToBuild.recyclerScoreBestCell {
            answer.append(Command(buildAt: CellToBuild))
        }
    }

    let myValue = myAttackValue + map.myMatter + (map.myRecyclersGain)
    let enemyValue = enemyAttackValue + map.enemyMatter + (map.enemyRecyclersGain)

    print("Values : ",myValue," - ",enemyValue, to: &errStream)
    print("DetailValues : ",myRobotsTotal," ",map.myMatter," ", map.myRecyclersGain," - ",enemyRobotsTotal," ",map.enemyMatter," ",map.enemyRecyclersGain, to: &errStream)
    if Double(myValue) >= (1 * Double(enemyValue)) {
        return Array<Command>()
    }
    else {
        return answer
    }
}

func getSpawnCommands(map:Map) -> Array<Command> {
    var answer = Array<Command>()
    
    //var spawnScoreBestSubmapValue = 0.0
    var spawnScoreBestSubmapCell : Cell?
    
    var numberRobotsDifference = 0
    var numberRobotsDifferenceMaxValue = 0
    for submap in map.submaps {
        numberRobotsDifference = submap.enemyRobots.count - submap.myRobots.count
        if numberRobotsDifference > numberRobotsDifferenceMaxValue {
            numberRobotsDifferenceMaxValue = numberRobotsDifference
            spawnScoreBestSubmapCell = submap.spawnScoreBestCell
        }
    }
    /*
    for submap in map.submaps {
        if spawnScoreBestSubmapValue < submap.spawnScoreBestValue {
            spawnScoreBestSubmapCell = submap.spawnScoreBestCell
            spawnScoreBestSubmapValue = submap.spawnScoreBestValue
        }
    }
    */
    let spawnNumber = (map.myMatter-10)/10
    if spawnNumber > 0 {
        if let cellToSpawn = spawnScoreBestSubmapCell {
            answer.append(Command(spawnAt: cellToSpawn, numberOfRobots: spawnNumber))
        }
    }

    return answer
}


func calculateAllCommands(map:Map) -> String {
    var answer = ""
    var commands = [Command]()
    commands += getMoveCommands(map: map)
    commands += getBuildCommands(map: map)
    commands += getSpawnCommands(map: map)
    //let moveCommands = [Command]()
    
    for command in commands {
        answer += command.output() + ";"
    }
    
    if answer == "" {
        answer = "WAIT"
    }

    return answer
}

/**
 * START
 **/

let inputs = (readLine()!).split(separator: " ").map(String.init)
let width = Int(inputs[0])!
let height = Int(inputs[1])!

Cell.mapWidth = width

var allMapCellsList = [MapCell]()
var allScrapCellsDic = [Cell:ComputedCell]()
var allRecyclersCellsDic = [Cell:ComputedCell]()
var allMoveableCellsDic = [Cell:ComputedCell]()

var gameTurn = 0

// game loop
while true {
    MapCell.gameTurn = gameTurn
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    let myMatter = Int(inputs[0])!
    let oppMatter = Int(inputs[1])!
    allMapCellsList.removeAll()  //mapCalcMoves.removeAll()
    allRecyclersCellsDic.removeAll()
    allScrapCellsDic.removeAll()
    allMoveableCellsDic.removeAll()
    if height > 0 {
        for iy in 0...(height-1) {
            if width > 0 {
                for ix in 0...(width-1) {
                    let inputs = (readLine()!).split(separator: " ").map(String.init)
                    let mapCell = MapCell (
                        x:                  ix
                        ,y:                 iy
                        ,scrap:             Int(inputs[0])!
                        ,owner:             Int(inputs[1])!
                        ,units:             Int(inputs[2])!
                        ,recycler:          (inputs[3] != "0")
                        ,canBuild:          (inputs[4] != "0")
                        ,canSpawn:          (inputs[5] != "0")
                        ,inRangeOfRecycler: (inputs[6] != "0")
                        )

                    allMapCellsList.append(mapCell)

                    if mapCell.scrap > 0 {
                        var computedCell = ComputedCell(mapCell:mapCell)
                        if ix > 0, var prevComputedCell = allScrapCellsDic[Cell(ix-1,iy)] {
                            if mapCell.recycler == false || (mapCell.recycler && prevComputedCell.mapCell.recycler) {
                                prevComputedCell.neighborCells.append(computedCell.cell)
                                prevComputedCell.neighborIdx.append(computedCell.idx)
                            }
                            if prevComputedCell.mapCell.recycler == false || (mapCell.recycler && prevComputedCell.mapCell.recycler) {
                                computedCell.neighborCells.append(prevComputedCell.cell)
                                computedCell.neighborIdx.append(prevComputedCell.idx)
                            }
                        }
                        if iy > 0, var prevComputedCell = allScrapCellsDic[Cell(ix,iy-1)] {
                            if mapCell.recycler == false || (mapCell.recycler && prevComputedCell.mapCell.recycler) {
                                prevComputedCell.neighborCells.append(computedCell.cell)
                                prevComputedCell.neighborIdx.append(computedCell.idx)
                            }
                            if prevComputedCell.mapCell.recycler == false || (mapCell.recycler &&
                        if mapCell.recycler {
                            allRecyclersCellsDic[computedCell.cell] = computedCell
                        }
                    }
                }
            }
        }
    }
    allMoveableCellsDic = allScrapCellsDic
    for recyclerCell in allRecyclersCellsDic.keys {
        allMoveableCellsDic.removeValue(forKey: recyclerCell)
    }
    print("allMoveableCellsDic:",allMoveableCellsDic.count," - allScrapCellsDic:",allScrapCellsDic.count, to: &errStream)
    var map = Map(allMoveableCellsDic: allMoveableCellsDic, allRecyclersCellsDic:allRecyclersCellsDic, myMatter: myMatter, enemyMatter: oppMatter)
    calculateMapData(map)
    showScoresMap(allMapCellsList: allMapCellsList, map: map)

    // To debug: print("Debug messages...", to: &errStream)
    print(calculateAllCommands(map: map))

    gameTurn += 1
}
