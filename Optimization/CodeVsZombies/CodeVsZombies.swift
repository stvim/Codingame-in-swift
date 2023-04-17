/********************* HEADER ****************/
#if canImport(CodingameCommon)
import CodingameCommon
import Darwin
#else
import Glibc
public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

public let defaultTerminator = "\n",defaultSeparator = " "

//public func print(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) -> Void {
//    let output = args.map{"\($0)"}.joined(separator: separator)
//    Dialog.allOutputs.append(output)
//    Swift.print(output,terminator: terminator)
//    debug("-- all inputs --\n", Dialog.allInputs.joined(separator: "\n"), "\n------------")
//    debug("-- all outputs --\n", Dialog.allOutputs.joined(separator: "\n"), "\n------------")
//}

public func debug(_ args:Any..., separator:String = defaultSeparator, terminator:String = defaultTerminator) {
    let output = args.map{"\($0)"}.joined(separator: separator)
    Swift.print(output, terminator: terminator, to: &errStream)
}

struct Dialog {
    static var allInputs : [String] = []
    static var allOutputs : [String] = []
}
public func readLine() -> String? {
    return readLine("")
}
public func readLine(_ message:String) -> String? {
    let r = Swift.readLine()
    if let r = r { Dialog.allInputs.append(r) }
    return r
}
#endif
import Foundation
/********************* END of HEADER ****************/

struct Coordinates {
    public let x,y:Int
    init(_ x:Int, _ y:Int) {
        self.x = x
        self.y = y
    }
    func distanceTo(_ c:Coordinates) -> Double {
        sqrt(pow(Double(self.x - c.x),2.0)+pow(Double(self.y - c.y),2.0))
    }
}

class Humanoid : Hashable {
    public static func == (lhs: Humanoid, rhs: Humanoid) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id:Int
    public let position:Coordinates

    init(id:Int, position:Coordinates) {
        self.id = id
        self.position = position
    }
}

class Human : Humanoid {
    override init(id:Int, position:Coordinates) {
        super.init(id: id, position: position)
    }
    
    public var zombiesThatCanKillHim = Set<Zombie>()
    public var closestZombies = Set<Zombie>()
//    func simulateNextPosition(target:Coordinates) -> Coordinates {
//        let d = self.position.distanceTo(target)
//        if d <= 1000 {
//            return target
//        }
//        else {
//            let a = (self.position.y-target.y) / (self.position.x-target.x)
//            let b = target.y / (a*target.x)
//
//        }
//    }
}

class Hero : Humanoid {
        public var zombiesHeCanKill = Set<Zombie>()
}

class Zombie : Humanoid {
    let nextPosition:Coordinates
    init(id:Int, position:Coordinates, nextPosition:Coordinates, humans:[Human], hero:Hero) {
        self.nextPosition = nextPosition
        super.init(id: id, position: position)
        var closestHuman : Human?
        var closestHumanDistance : Double?
        for human in humans {
            let distanceTo = human.position.distanceTo(position)
            if distanceTo <= 400 {
                human.zombiesThatCanKillHim.insert(self)
            }
            if closestHuman == nil || closestHumanDistance! > distanceTo {
                closestHuman = human
                closestHumanDistance = distanceTo
            }
        }
        closestHuman!.closestZombies.insert(self)
        
        if hero.position.distanceTo(position) <= 3000 {
            hero.zombiesHeCanKill.insert(self)
        }
    }
    var closestHumanDistance : Double = 0
}


func closestHuman(zombie:Zombie, humans:[Human]) -> Double {
    var closestHuman : Human?
    var closestDistance : Double?
    for human in humans {
        let currentDistance = zombie.position.distanceTo(human.position)
        if closestDistance == nil || currentDistance < closestDistance! {
            closestDistance = currentDistance
            closestHuman = human
        }
    }
    return closestDistance!
}


public func main() {
    // game loop
    while true {
        let inputs = (readLine()!).split(separator: " ").map(String.init)
        let x = Int(inputs[0])!
        let y = Int(inputs[1])!
        let hero = Hero(id:0, position: Coordinates(x,y))
        
        let humanCount = Int(readLine()!)!
        var humans : [Human] = []
        if humanCount > 0 {
            for i in 0...(humanCount-1) {
                let inputs = (readLine()!).split(separator: " ").map(String.init)
                let humanId = Int(inputs[0])!
                let humanX = Int(inputs[1])!
                let humanY = Int(inputs[2])!
//                if (humanX==x && humanY==y)
                humans.append(Human(id: humanId, position: Coordinates(humanX,humanY)))
            }
        }
        let zombieCount = Int(readLine()!)!
        var zombies : [Zombie] = []
        var target : Coordinates?
        var closestDistanceToHuman : Double?
        if zombieCount > 0 {
            for i in 0...(zombieCount-1) {
                let inputs = (readLine()!).split(separator: " ").map(String.init)
                let zombieId = Int(inputs[0])!
                let zombieX = Int(inputs[1])!
                let zombieY = Int(inputs[2])!
                let zombieXNext = Int(inputs[3])!
                let zombieYNext = Int(inputs[4])!
                let zombie = Zombie(id: zombieId, position: Coordinates(zombieX,zombieY), nextPosition: Coordinates(zombieXNext,zombieYNext), humans: humans, hero:hero)
                zombies.append(zombie)
                
                zombie.closestHumanDistance = closestHuman(zombie: zombie, humans:humans)
                
//                if closestDistanceToHuman == nil || d < closestDistanceToHuman! {
//                    closestDistanceToHuman = d
//                    target = zombie.nextPosition
//                }
            }
        }
        let byClosestHumanDistance = { (z1:Zombie,z2:Zombie) -> Bool in z1.closestHumanDistance < z2.closestHumanDistance }
        let byDistanceToHero = { (c1:Coordinates,c2:Coordinates) -> Bool in c1.distanceTo(hero.position) < c2.distanceTo(hero.position) }
        zombies = zombies.sorted(by:byClosestHumanDistance)
        humans = humans.sorted{ $0.closestZombies.count < $1.closestZombies.count }
        var targets : [Coordinates] = []
        for human in humans {
            if human.zombiesThatCanKillHim.subtracting(hero.zombiesHeCanKill).isEmpty == false {
                continue
            }
            if !human.closestZombies.isEmpty {
                if human.zombiesThatCanKillHim.isEmpty {
                    targets.append(human.closestZombies.sorted(by:byClosestHumanDistance).first!.position)
                }
                else {
                    targets.append(human.position)
                }
            }
        }
        if targets.isEmpty {
            zombies.forEach{ targets.append($0.position)}
        }
        
        target = targets.sorted(by: byDistanceToHero).first!
//        for zombie in zombies {
//            target = zombie.position
//
//            if !(hero.position.distanceTo(zombie.position) > 3000 && zombie.closestHumanDistance <= 400) {
//
//                break
//            }
//
//        }
        
        // Write an action using print("message...")
        // To debug: print("Debug messages...", to: &errStream)
        
        print(target!.x, target!.y)     // Your destination coordinates
        
    }
}

//main()
