import Foundation

func evalArithmeticExpression(_ input: String) throws -> Double {
    return try Solver.evalArithmeticExpression(input)
}

private struct Solver {
    
    private let operations: [String : Operation] = [
        "𝜋" : .init(precedence: 0, associativity: .none, action: .constant(.pi)),
        "e" : .init(precedence: 0, associativity: .none, action: .constant(M_E)),
        "√" : .init(precedence: 30, associativity: .left, action: .unary(sqrt)),
        "cos" : .init(precedence: 30, associativity: .left, action: .unary(cos)),
        "sin" : .init(precedence: 30, associativity: .left, action: .unary(sin)),
        "±" : .init(precedence: 10, associativity: .right, action: .unary({ -$0 })),
        "×" : .init(precedence: 20, associativity: .left, action: .binary(*)),
        "÷" : .init(precedence: 20, associativity: .left, action: .binary(/)),
        "+" : .init(precedence: 10, associativity: .left, action: .binary(+)),
        "-" : .init(precedence: 10, associativity: .left, action: .binary(-)),
        "^" : .init(precedence: 30, associativity: .left, action: .binary(pow))
    ]

    public static func evalArithmeticExpression(_ input: String) throws -> Double {
        return try Solver().evalArithmeticExpression(input)
    }
    
    private func evalArithmeticExpression(_ input: String) throws -> Double {
        //What if expression was made without whitespaces? So we don't need them
        let input = input.components(separatedBy: .whitespacesAndNewlines).joined()
        guard !input.isEmpty else { throw Error.emptyExpression }
        
        let tokens = try tokenize(input)
        let expression = try generateExpressionConformingRPN(from: tokens)
        
        return try evalExpressionConformingRPN(expression)
    }
    
    private func tokenize(_ input: String) throws -> [Token] {
        var expression = input
        var tokens: [Token] = []

        while !expression.isEmpty {
            let token = try parseToken(from: expression)
            expression.removeFirst(token.value.count)
            tokens.append(token)
        }
        return tokens
    }

    private func parseToken(from input: String) throws -> Token {
        func parseTokenSequence(by offset: Int) -> Token? {
            guard offset <= input.count else { return nil}

            let index = input.index(input.startIndex, offsetBy: offset)
            let possibleToken = String(input.prefix(offset))
            
            //check if operator
            if let _ = operations[possibleToken] {
                return Token(value: possibleToken, type: .operator)
            }
            
            //check if operand
            let next = offset < input.count ? String(input[index]) : "NaN"
            if Double(possibleToken) != nil && UInt8(next) == nil && next != "." {
                return Token(value: possibleToken, type: .operand)
            }
            
            //check if bracket
            if possibleToken == "(" || possibleToken == ")" {
                let type: TokenType = possibleToken == "(" ?
                    .bracket(.opened) : .bracket(.closed)
                return Token(value: possibleToken, type: type)
            }
            
            return parseTokenSequence(by: offset + 1)
        }
        
        if let token = parseTokenSequence(by: 1) {
            return token
        }
        throw Error.unknownToken(input)
    }
    
    private func generateExpressionConformingRPN(from tokens: [Token]) throws -> String {

        var stack = Stack<Token>()
        var reversedTokens = [Token]()
        
        try tokens.forEach {
            
            switch $0.type {
            case .bracket(let type):
                switch type {
                case .opened: stack.push($0)
                case .closed:
                    while !stack.isEmpty, let token = stack.pop(), token.type != .bracket(.opened) {
                        reversedTokens.append(token)
                    }
                }
            case .operand: reversedTokens.append($0)
            case .operator:
                guard let currentOperation = operations[$0.value] else { throw Error.impossible }
                
                for token in stack {
                    guard token.type == .operator else { break }
                    if let operation = operations[token.value], operation.associativity == .left &&
                        currentOperation.precedence <= operation.precedence ||
                        currentOperation.associativity == .right &&
                        currentOperation.precedence < operation.precedence {
                        reversedTokens.append(stack.pop()!)
                    }
                }
                stack.push($0)
            }
        }
        
        while !stack.isEmpty, let token = stack.pop() {
            reversedTokens.append(token)
        }
        return reversedTokens
            .map { $0.value }
            .joined(separator: " ")
    }
    
    private func evalExpressionConformingRPN(_ input: String) throws -> Double {
        guard input.count > 0 else { return 0.0 }
        var stack = Stack<Double>()
        let components = input.components(separatedBy: " ")
        for component in components {
            if let operand = Double(component) {
                stack.push(operand)
                continue
            }
            if let operation = operations[component] {
                switch operation.action {
                case .constant(let operand):
                    stack.push(operand)
                case .unary(let operate):
                    guard let op = stack.pop() else { throw Error.invalidRPNExpression(input) }
                    stack.push(operate(op))
                case .binary(let operate):
                    guard let op1 = stack.pop(), let op2 = stack.pop() else { throw Error.invalidRPNExpression(input) }
                    stack.push(operate(op2, op1))
                }
                continue
            }
            throw Error.unsupportedOperation(component)
        }
        guard let last = stack.pop() else { throw Error.invalidRPNExpression(input) }
        return last
    }
    
    private struct Token {
        var value: String
        let type: TokenType
    }
    
    private enum TokenType: Equatable {
        enum BracketType {
            case opened, closed
        }
        
        case bracket(BracketType)
        case operand
        case `operator`
    }
    
    private enum Error: Swift.Error {
        case impossible
        case emptyExpression
        case unknownToken(String)
        case invalidRPNExpression(String)
        case unsupportedOperation(String)
    }
    
    private struct Stack<T>: Sequence {
        var isEmpty: Bool { elements.isEmpty }
        var elements = [T]()
        
        mutating func push(_ element: T) { elements.append(element) }
        
        @discardableResult
        mutating func pop() -> T? { elements.popLast() }
        
        public func makeIterator() -> AnyIterator<T> {
            var copy = self
            return AnyIterator { return copy.pop() }
        }
    }
    
    private struct Operation {
        enum Associativity {
            case left, right, none
        }
        
        enum Action {
            case constant(Double)
            case unary((Double) -> Double)
            case binary((Double, Double) -> Double)
        }

        let precedence: Int
        let associativity: Associativity
        let action: Action
    }
}
