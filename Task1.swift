import Foundation

func isValid(input: String) -> Bool {
    var input = input
    var output = ""

    var trimCount = 0
    
    while !input.isEmpty, let char = input.last {
        if char == "." {
            trimCount += 1
        } else if trimCount == 0 {
            output.append(char)
        } else if char == " " {
            trimCount = 0
            output.append(char)
        } else if trimCount > 0{
            trimCount -= 1
        }
        input.removeLast()
    }
    
    let components = output.components(separatedBy: " ")
    guard components.count == 2 else { return false }
    
    return components.first == components.last
}

//func isValid(input: String) -> Bool {
//
//    let count = input.count
//    var trimCount = 0
//    var output = ""
//
//    for index in 1 ... count {
//        let char = input[input.index(input.endIndex, offsetBy: -index)]
//        if char == "." {
//            trimCount += 1
//        } else if trimCount == 0 {
//            output.append(char)
//        } else if char == " " {
//            trimCount = 0
//            output.append(char)
//        } else if trimCount > 0{
//            trimCount -= 1
//        }
//    }
//
//    let components = output.split(separator: " ")
//    guard components.count == 2 else { return false }
//
//    return components.first == components.last
//}

//func isValid(input: String) -> Bool {
//    guard !input.isEmpty, input.count % 2 == 1 else { return false }
//    let components = input.split(separator: " ")
//
//    guard components.count == 2,
//          components[0].count == components[1].count else { return false }
//
//    for (index, character) in components[0].enumerated() {
//        let sequence = components[1]
//        let another = sequence[sequence.index(sequence.startIndex, offsetBy: index)]
//        if another != character {
//            return false
//        }
//    }
//    return true
//}

