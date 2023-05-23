//import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

enum Intersection {
  case noneAsc, noneDesc, yes, yesInside, yesContains
}
struct Calc {
  let calc: [Int]
  var dayStart: Int {
    return calc[0]
  }
  var length: Int {
    return calc[1]
  }
  var dayOver: Int {
    return calc[0]+calc[1]-1
  }
  
  func isIntersect(_ calc: Calc) -> Intersection {
    if self.dayStart < calc.dayStart {
      if self.dayOver >= calc.dayStart {
        return self.dayOver >= calc.dayOver ? .yesContains : .yes
      } else {
        return .noneAsc
      }
    } else if self.dayStart > calc.dayStart {
      if self.dayStart <= calc.dayOver {
        return self.dayOver <= calc.dayOver ? .yesInside : .yes
      } else {
        return .noneDesc
      }
    } else {
      return self.dayOver <= calc.dayOver ? .yesInside : .yesContains
    }
  }
}

let N = Int(readLine()!)!
var calcs = [Calc]()
if N > 0 {
  for i in 0...(N-1) {
    let inputs = (readLine()!).characters.split{$0 == " "}.map(String.init).map{Int($0)!}
    calcs.append(Calc(calc: inputs))
  }
}
calcs = calcs.sorted { $0.dayStart < $1.dayStart }
var acceptedCalcs = [Calc]()
calcs.forEach { calc in
  guard let lastCalc = acceptedCalcs.last else {
    acceptedCalcs.append(calc)
    return
  }
  switch calc.isIntersect(lastCalc) {
  case .yes:
    break
  case .yesInside:
    acceptedCalcs.removeLast()
    acceptedCalcs.append(calc)
  case .yesContains:
    break
  case .noneAsc, .noneDesc:
    acceptedCalcs.append(calc)
  }
}
// print(acceptedCalcs.map { "\($0.dayStart)-\($0.dayOver)" })
print(acceptedCalcs.count)

