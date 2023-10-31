import NIOCore

// MARK: - Numeric

extension EventLoopFuture where Value: Numeric {
    /// Adds two futures and produces their sum
    public static func + (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 + $1 } }

    /// Adds two futures and stores the result in the left-hand-side variable
    public static func += (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs + rhs }

    /// Subtracts one future from another and produces their difference
    public static func - (_ lhs: EventLoopFuture, _ rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 - $1 } }

    /// Subtracts the second future from the first and stores the difference in the left-hand-side variable
    public static func -= (_ lhs: inout EventLoopFuture, _ rhs: EventLoopFuture) { lhs = lhs - rhs }

    /// Multiplies two futures and produces their product
    public static func * (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 * $1 } }

    /// Multiplies two futures and stores the result in the left-hand-side variable
    public static func *= (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs * rhs }
}

// MARK: - Array<Equatable>

extension EventLoopFuture {
    /// Adds two futures and produces their sum
    public static func + <T>(lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture where Value == Array<T>, T: Equatable { lhs.and(rhs).map { $0 + $1 } }

    /// Adds two futures and stores the result in the left-hand-side variable
    public static func += <T>(lhs: inout EventLoopFuture, rhs: EventLoopFuture) where Value == Array<T>, T: Equatable { lhs = lhs + rhs }

    /// Subtracts one future from another and produces their difference
    public static func - <T>(lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture where Value == Array<T>, T: Equatable {
        lhs.and(rhs).map { l, r in l.filter { !r.contains($0) } }
    }

    /// Subtracts the second future from the first and stores the difference in the left-hand-side variable
    public static func -= <T>(lhs: inout EventLoopFuture, rhs: EventLoopFuture) where Value == Array<T>, T: Equatable { lhs = lhs - rhs }
}

// MARK: - BinaryInteger (division)

extension EventLoopFuture where Value: BinaryInteger {
    /// Returns the quotient of dividing the first future by the second
    public static func / (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 / $1 } }

    /// Divides the first future by the second and stores the quotient in the left-hand-side variable
    public static func /= (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs / rhs }

    /// Returns the remainder of dividing the first future by the second
    public static func % (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 % $1 } }

    /// Divides the first future by the second and stores the remainder in the left-hand-side variable
    public static func %= (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs % rhs }
}

// MARK: - BinaryInteger (comparison)

extension EventLoopFuture where Value: BinaryInteger {
    /// Returns a Boolean value indicating whether the value of the first argument is less than that of the second argument
    public static func < (lhs: EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) -> EventLoopFuture<Bool> { lhs.and(rhs).map { $0 < $1 } }

    /// Returns a Boolean value indicating whether the value of the first argument is less than or equal to that of the second argument
    public static func <= (lhs: EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) -> EventLoopFuture<Bool> { lhs.and(rhs).map { $0 <= $1 } }

    /// Returns a Boolean value indicating whether the value of the first argument is greater than or equal to that of the second argument
    public static func >= (lhs: EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) -> EventLoopFuture<Bool> { lhs.and(rhs).map { $0 >= $1 } }

    /// Returns a Boolean value indicating whether the value of the first argument is greater than that of the second argument
    public static func > (lhs: EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) -> EventLoopFuture<Bool> { lhs.and(rhs).map { $0 > $1 } }
}

// MARK: - BinaryInteger (bitwise)

extension EventLoopFuture where Value: BinaryInteger {
    /// Returns the result of shifting a future’s binary representation the specified number of digits to the left
    public static func << (lhs: EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) -> EventLoopFuture { lhs.and(rhs).map { $0 << $1 } }

    /// Stores the result of shifting a future’s binary representation the specified number of digits to the left in the left-hand-side variable
    public static func <<= (lhs: inout EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) { lhs = lhs << rhs }

    /// Returns the result of shifting a future’s binary representation the specified number of digits to the right
    public static func >> (lhs: EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) -> EventLoopFuture { lhs.and(rhs).map { $0 >> $1 } }

    /// Stores the result of shifting a future’s binary representation the specified number of digits to the right in the left-hand-side variable
    public static func >>= (lhs: inout EventLoopFuture, rhs: EventLoopFuture<some BinaryInteger>) { lhs = lhs >> rhs }

    /// Returns the result of performing a bitwise AND operation on the two given futures
    public static func & (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 & $1 } }

    /// Stores the result of performing a bitwise AND operation on the two given futures in the left-hand-side variable
    public static func &= (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs & rhs }

    /// Returns the result of performing a bitwise OR operation on the two given futures
    public static func | (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 | $1 } }

    /// Stores the result of performing a bitwise OR operation on the two given futures in the left-hand-side variable
    public static func |= (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs | rhs }

    /// Returns the result of performing a bitwise XOR operation on the two given futures
    public static func ^ (lhs: EventLoopFuture, rhs: EventLoopFuture) -> EventLoopFuture { lhs.and(rhs).map { $0 ^ $1 } }

    /// Stores the result of performing a bitwise XOR operation on the two given futures in the left-hand-side variable
    public static func ^= (lhs: inout EventLoopFuture, rhs: EventLoopFuture) { lhs = lhs ^ rhs }

    /// Returns the result of performing a bitwise NOT operation on the given future
    public static prefix func ~ (x: EventLoopFuture) -> EventLoopFuture { x.map { ~$0 } }
}
