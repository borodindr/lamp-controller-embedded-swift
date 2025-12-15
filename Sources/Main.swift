// LED pin
// Blue LED on Pico W is GPIO 16
let LED_PIN: UInt32 = 16

// HC-SR04 pins
// Output to TRIG
let TRIG_PIN: UInt32 = 6
// Input from ECHO
let ECHO_PIN: UInt32 = 7

let refreshIntervalMS: UInt = 1000 * 2 // 2 seconds. Increase after testing









@main
struct Application {
    static func main() {
        // Initialize stdio
        stdio_init_all()
        cyw43_arch_init()

        // Initialize LED pin
        let blueLED = LED.blue()

        // Initialize HC-SR04 pins
        let ultrasonicSensor = UltrasonicSensor(trigPin: TRIG_PIN, echoPin: ECHO_PIN)

        var currentIsOn = false
        var absenceDetectedTime: UInt?

        while true {
            let distance = ultrasonicSensor.getDistanceCM()
            // blink(distance: distance)
            let isPresent = distance < 100 && distance > 0
            let newIsOn = isPresent // Add light sensor logic later

            switch (currentIsOn, newIsOn) {
            case (_, true):
                // Just detected presence
                absenceDetectedTime = nil
                blueLED.set(on: true)

            case (true, false):
                // No longer present
                absenceDetectedTime = Time.now() // + (1000 * 60) // 1 minute from now
                // Blink twice to indicate absence detected
                blueLED.blink(times: 2)

            case (false, false):
                // No presence detected
                // Check if LED is on and absence period ended
                guard blueLED.isOn, let absenceTime = absenceDetectedTime else { break }

                let sincenceAbsence = Time.diffInMicroseconds(from: absenceTime, to: Time.now())
                let shouldTurnOff = sincenceAbsence > (1000 * 1000 * 60) // 1 minute from microseconds

                if shouldTurnOff {
                    // Absence period ended, turn off LED
                    blueLED.set(on: false)
                    absenceDetectedTime = nil
                } else {
                    // Blink once to indicate still absent
                    blueLED.blink()
                }
            }

            currentIsOn = newIsOn

            Time.sleep(for: .milliseconds(refreshIntervalMS))
        }
    }
}


func serviceBlink() {
    let led = UInt32(CYW43_WL_GPIO_LED_PIN)
    cyw43_arch_gpio_put(led, true)
    sleep_ms(100)
    cyw43_arch_gpio_put(led, false)
}