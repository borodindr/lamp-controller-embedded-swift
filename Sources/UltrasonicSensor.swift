struct UltrasonicSensor {
    let trigPin: UInt32
    let echoPin: UInt32

    init(trigPin: UInt32, echoPin: UInt32) {
        self.trigPin = trigPin
        self.echoPin = echoPin

        // Initialize HC-SR04 pins
        // TRIG pin
        gpio_init(trigPin)
        gpio_set_dir(trigPin, true)

        // ECHO pin
        gpio_init(echoPin)
        gpio_set_dir(echoPin, false)
    }

    func getDistanceCM() -> Int {
        sendPulse()

        // Wait for echo to go HIGH (timeout safety)
        let timeout = make_timeout_time_us(30000)
        while gpio_get(echoPin) == false {
            if absolute_time_diff_us(get_absolute_time(), timeout) <= 0 {
                return 0
            }
        }

        // Measure HIGH pulse duration
        let start = Time.now()
        while gpio_get(echoPin) == true {
            if Time.diffInMicroseconds(from: start, to: Time.now()) > 30000 {
                break
            }
        }

        let end = Time.now()
        let pulseInMicroseconds = Time.diffInMicroseconds(from: start, to: end)

        // Convert to cm
        return pulseInMicroseconds / 58
    }

    private func sendPulse() {
        // Ensure TRIG is low
        gpio_put(trigPin, false)
        // sleep_us(2)
        Time.sleep(for: .microseconds(2))

        // Send 10us pulse
        gpio_put(trigPin, true)
        Time.sleep(for: .microseconds(10))
        gpio_put(trigPin, false)
    }
}