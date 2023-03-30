import NIOCore

// MARK: - +

/// Adds two futures and produces their sum
public func +<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: Numeric {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal + rhsVal
    }
}

/// Adds two futures and stores the result in the left-hand-side variable
public func +=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: Numeric {
    lhs = lhs.and(rhs).map({ (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal + rhsVal
    })
}

/// Adds two futures and produces their sum
public func +<T>(_ lhs: EventLoopFuture<[T]>, _ rhs: EventLoopFuture<[T]>) -> EventLoopFuture<[T]> {
    return lhs.and(rhs).map { (arg) -> ([T]) in
        let (lhsVal, rhsVal) = arg
        return lhsVal + rhsVal
    }
}

/// Adds two futures and stores the result in the left-hand-side variable
public func +=<T>(_ lhs: inout EventLoopFuture<[T]>, _ rhs: EventLoopFuture<[T]>) {
    lhs = lhs.and(rhs).map({ (arg) -> ([T]) in
        let (lhsVal, rhsVal) = arg
        return lhsVal + rhsVal
    })
}


// MARK: - -

/// Subtracts one future from another and produces their difference
public func -<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: Numeric {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal - rhsVal
    }
}

/// Subtracts the second future from the first and stores the difference in the left-hand-side variable
public func -=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: Numeric {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal - rhsVal
    }
}

/// Subtracts one future from another and produces their difference
public func -<T>(_ lhs: EventLoopFuture<[T]>, _ rhs: EventLoopFuture<[T]>) -> EventLoopFuture<[T]> where T: Equatable {
    return lhs.and(rhs).map { (arg) -> ([T]) in
        let (lhsVal, rhsVal) = arg
        return lhsVal.filter({ val -> Bool in
            return !rhsVal.contains(val)
        })
    }
}

/// Subtracts the second future from the first and stores the difference in the left-hand-side variable
public func -=<T>(_ lhs: inout EventLoopFuture<[T]>, _ rhs: EventLoopFuture<[T]>) where T: Equatable {
    lhs = lhs.and(rhs).map { (arg) -> ([T]) in
        let (lhsVal, rhsVal) = arg
        return lhsVal.filter({ val -> Bool in
            return !rhsVal.contains(val)
        })
    }
}

// MARK: - *

/// Multiplies two futures and produces their product
public func *<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: Numeric {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal * rhsVal
    }
}

/// Multiplies two futures and stores the result in the left-hand-side variable
public func *=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: Numeric {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal * rhsVal
    }
}

// MARK: - %

/// Returns the remainder of dividing the first future by the second
public func %<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal % rhsVal
    }
}

/// Divides the first future by the second and stores the remainder in the left-hand-side variable
public func %=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal % rhsVal
    }
}

// MARK: - &

/// Returns the result of performing a bitwise AND operation on the two given futures
public func &<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal & rhsVal
    }
}

/// Stores the result of performing a bitwise AND operation on the two given futures in the left-hand-side variable
public func &=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal & rhsVal
    }
}

// MARK: - /

/// Returns the quotient of dividing the first future by the second
public func /<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal / rhsVal
    }
}

/// Divides the first future by the second and stores the quotient in the left-hand-side variable
public func /=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal / rhsVal
    }
}

// MARK: - Comparison

/// Returns a Boolean value indicating whether the value of the first argument is less than that of the second argument
public func < <T, Other>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<Other>) -> EventLoopFuture<Bool> where T: BinaryInteger, Other: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = (arg)
        return lhsVal < rhsVal
    }
}

/// Returns a Boolean value indicating whether the value of the first argument is less than or equal to that of the second argument
public func <=<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<Bool> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = arg
        return lhsVal <= rhsVal
    }
}

/// Returns a Boolean value indicating whether the value of the first argument is less than or equal to that of the second argument
public func <=<T, Other>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<Other>) -> EventLoopFuture<Bool> where T: BinaryInteger, Other: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = arg
        return lhsVal <= rhsVal
    }
}

/// Returns a Boolean value indicating whether the value of the first argument is greater than or equal to that of the second argument
public func >=<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<Bool> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = arg
        return lhsVal >= rhsVal
    }
}

/// Returns a Boolean value indicating whether the value of the first argument is greater than or equal to that of the second argument
public func >=<T, Other>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<Other>) -> EventLoopFuture<Bool> where T: BinaryInteger, Other: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = arg
        return lhsVal >= rhsVal
    }
}

/// Returns a Boolean value indicating whether the value of the first argument is greater than that of the second argument
public func ><T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<Bool> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = arg
        return lhsVal > rhsVal
    }
}

/// Returns a Boolean value indicating whether the value of the first argument is greater than that of the second argument
public func ><T, Other>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<Other>) -> EventLoopFuture<Bool> where T: BinaryInteger, Other: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> Bool in
        let (lhsVal, rhsVal) = arg
        return lhsVal > rhsVal
    }
}

// MARK: - Bitshifts

/// Returns the result of shifting a future’s binary representation the specified number of digits to the left
public func << <T, RHS>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<RHS>) -> EventLoopFuture<T> where T: BinaryInteger, RHS: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> T in
        let (lhsVal, rhsVal) = arg
        return lhsVal << rhsVal
    }
}

/// Stores the result of shifting a future’s binary representation the specified number of digits to the left in the left-hand-side variable
public func <<= <T, RHS>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<RHS>) where T: BinaryInteger, RHS: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> T in
        let (lhsVal, rhsVal) = arg
        return lhsVal << rhsVal
    }
}

/// Returns the result of shifting a future’s binary representation the specified number of digits to the right
public func >> <T, RHS>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<RHS>) -> EventLoopFuture<T> where T: BinaryInteger, RHS: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> T in
        let (lhsVal, rhsVal) = arg
        return lhsVal >> rhsVal
    }
}

/// Stores the result of shifting a future’s binary representation the specified number of digits to the right in the left-hand-side variable
public func >>= <T, RHS>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<RHS>) where T: BinaryInteger, RHS: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> T in
        let (lhsVal, rhsVal) = arg
        return lhsVal >> rhsVal
    }
}

// MARK: - ^

/// Returns the result of performing a bitwise XOR operation on the two given futures
public func ^<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal ^ rhsVal
    }
}

/// Stores the result of performing a bitwise XOR operation on the two given futures in the left-hand-side variable
public func ^=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal ^ rhsVal
    }
}

// MARK: - |

/// Returns the result of performing a bitwise OR operation on the two given futures
public func |<T>(_ lhs: EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) -> EventLoopFuture<T> where T: BinaryInteger {
    return lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal | rhsVal
    }
}

/// Stores the result of performing a bitwise OR operation on the two given futures in the left-hand-side variable
public func |=<T>(_ lhs: inout EventLoopFuture<T>, _ rhs: EventLoopFuture<T>) where T: BinaryInteger {
    lhs = lhs.and(rhs).map { (arg) -> (T) in
        let (lhsVal, rhsVal) = arg
        return lhsVal | rhsVal
    }
}

// MARK: - ~

/// Returns the result of performing a bitwise NOT operation on the given future
prefix func ~<T>(_ x: EventLoopFuture<T>) -> EventLoopFuture<T> where T: BinaryInteger {
    return x.map { xVal -> T in
        return ~xVal
    }
}
