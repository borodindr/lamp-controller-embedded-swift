struct Time {
    static func now() -> UInt {
        UInt(get_absolute_time())
    }

    static func sleep(for duraction: Duration) {
        let milliseconds = duraction.inMilliseconds
        sleep_ms(UInt32(milliseconds))
    }

    static func diffInMicroseconds(from start: UInt, to end: UInt) -> Int {
        Int(absolute_time_diff_us(UInt64(start), UInt64(end)))
    }
}