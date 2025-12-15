enum Duration {
    case seconds(UInt)
    case milliseconds(UInt)
    case microseconds(UInt)

    var inMicroseconds: UInt {
        switch self {
        case .seconds(let sec):
            return sec * 1_000_000
        case .milliseconds(let ms):
            return ms * 1_000
        case .microseconds(let us):
            return us
        }
    }

    var inMilliseconds: UInt {
        switch self {
        case .seconds(let sec):
            return sec * 1_000
        case .milliseconds(let ms):
            return ms
        case .microseconds(let us):
            return us / 1_000
        }
    }
}