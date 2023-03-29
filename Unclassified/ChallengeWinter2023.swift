import Foundation

// Ignore and do not change the code below
let encoder = JSONEncoder()
/**
 * Try a solution
 * - parameter message: the decrypted message, created by alternating the letters of s1 and s2
 */
func trySolution(message: String) {
    print("" + String(String(data: try! encoder.encode([message]), encoding: .utf8)!.dropLast().dropFirst()))
}
// Ignore and do not change the code above

/**
 * - parameter s1: the first line of the page, composed of uppercase letters only
 * - parameter s2: the second line, composed of uppercase letters and of the same length as s1
 * - returns: the decrypted message, created by alternating the letters of s1 and s2
 */
func decrypt(s1: String, s2: String) -> String? {
    // Write your code here
    var answer = ""
    for i in 0...s1.count-1 {
        answer += s1[s1.index(s1.startIndex, offsetBy: i)] + s2[s2.index(s2.startIndex, offsetBy: i)]
    }
    return answer
}


// Ignore and do not change the code below
let decoder = JSONDecoder()
trySolution(message: decrypt(
    s1: try! decoder.decode([String].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0],
    s2: try! decoder.decode([String].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0]
)!)

// Ignore and do not change the code above












import Foundation

// Ignore and do not change the code below
let encoder = JSONEncoder()
/**
 * Try a solution
 */
func trySolution(recipe: [String]) {
    print("" + String(String(data: try! encoder.encode([recipe]), encoding: .utf8)!.dropLast().dropFirst()))
}
// Ignore and do not change the code above

/**
 * - parameter protonsStart: The initial number of protons
 * - parameter neutronsStart: The initial number of neutrons
 * - parameter protonsTarget: The desired number of protons
 * - parameter neutronsTarget: The desired number of neutrons
 */
func solve(protonsStart: Int, neutronsStart: Int, protonsTarget: Int, neutronsTarget: Int) -> [String]? {
    // Write your code here
    var answer : [String] = []
    var p = protonsStart
    var n = neutronsStart
    var first = true
    while p > protonsTarget || n > neutronsTarget {
        answer.append("ALPHA")
        p -= 2
        n -= 2
    }
    
    while n < neutronsTarget {
        answer.append("NEUTRON")
        n += 1
    }
    while p < protonsTarget {
        answer.append("PROTON")
        p += 1
    }
    
    return answer
}


// Ignore and do not change the code below
let decoder = JSONDecoder()
trySolution(recipe: solve(
    protonsStart: try! decoder.decode([Int].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0],
    neutronsStart: try! decoder.decode([Int].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0],
    protonsTarget: try! decoder.decode([Int].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0],
    neutronsTarget: try! decoder.decode([Int].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0]
)!)

// Ignore and do not change the code above















import Foundation

// Ignore and do not change the code below
let encoder = JSONEncoder()
/**
 * Try a solution
 */
func trySolution(newGrid: [[Int]]) {
    print("" + String(String(data: try! encoder.encode([newGrid]), encoding: .utf8)!.dropLast().dropFirst()))
}
// Ignore and do not change the code above

/**
 * - parameter grid: The initial grid of elements
 * - parameter rules: Transition rules between elements
 */
func solve(grid: [[Int]], rules: [Unknown]) -> [[Int]]? {
    // Write your code here
    let nGrid = grid.count
    let nResult = nGrid - 1
    var result = [[Int]](repeating: [Int](repeating: 0, count: nResult), count:nResult)
    
    for i in 0...nResult-1 {
        for j in 0...nResult-1 {
            let l1 = i
            let l2 = i+1
            let k1 = j
            let k2 = j+1
            
            var extract:[Int] = [grid[k1][l1],grid[k2][l1],grid[k1][l2],grid[k2][l2]]
            extract = extract.sorted()
            
            for rule in rules {
                if rule.orderedPattern == extract {
                    result[j][i] = rule.result!
                    break
                }
            }
        }
    }
    return result
}

struct Unknown: Codable {
    enum CodingKeys: String, CodingKey {
        case pattern = "pattern"
        case result = "result"
    }
    var pattern: [Int]?
    
    var orderedPattern: [Int] {
        get {
            return pattern!.sorted()
        }
    }
    var result: Int?
}

// Ignore and do not change the code below
let decoder = JSONDecoder()
trySolution(newGrid: solve(
    grid: try! decoder.decode([[[Int]]].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0],
    rules: try! decoder.decode([[Unknown]].self, from: ("[" + readLine()! + "]").data(using: .utf8)!)[0]
)!)

// Ignore and do not change the code above

