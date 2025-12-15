// LED pin
// Blue LED on Pico W is GPIO 16
let LED_PIN: UInt32 = 16

// HC-SR04 pins
// Output to TRIG
let TRIG_PIN: UInt32 = 6
// Input from ECHO
let ECHO_PIN: UInt32 = 7

let refreshIntervalMS: UInt32 = 1000 * 2 // 2 seconds. Increase after testing

func switchLED(on: Bool) {
    gpio_put(LED_PIN, on)
}

func getDistanceCM() -> UInt32 {
    // Ensure TRIG is low
    gpio_put(TRIG_PIN, false)
    sleep_us(2)

    // Send 10us pulse
    gpio_put(TRIG_PIN, true)
    sleep_us(10)
    gpio_put(TRIG_PIN, false)

    // Wait for echo to go HIGH (timeout safety)
    let timeout = make_timeout_time_us(30000)
    while gpio_get(ECHO_PIN) == false {
        if absolute_time_diff_us(get_absolute_time(), timeout) <= 0 {
            return 0
        }
    }

    // Measure HIGH pulse duration
    let start = get_absolute_time()
    while gpio_get(ECHO_PIN) == true {
        if absolute_time_diff_us(start, get_absolute_time()) > 30000 {
            break
        }
    }
    let end = get_absolute_time()

    let pulse_us = absolute_time_diff_us(start, end)

    // Convert to cm
    return UInt32(pulse_us / 58)
}

// Initialize stdio
stdio_init_all()

// Initialize LED pin
gpio_init(LED_PIN)
gpio_set_dir(LED_PIN, true)

// Initialize HC-SR04 pins
// TRIG pin
gpio_init(TRIG_PIN)
gpio_set_dir(TRIG_PIN, true)

// ECHO pin
gpio_init(ECHO_PIN)
gpio_set_dir(ECHO_PIN, false)

var currentIsOn = false
var absenceDetectedTime: UInt64?

while true {
    let distance = getDistanceCM()
    // blink(distance: distance)
    let isPresent = distance < 100 && distance > 0
    let newIsOn = isPresent // Add light sensor logic later

    switch (currentIsOn, newIsOn) {
    case (_, true):
        // Just detected presence
        absenceDetectedTime = nil
        switchLED(on: true)

    case (true, false):
        // No longer present
        absenceDetectedTime = get_absolute_time() // + (1000 * 60) // 1 minute from now
        // Blink twice to indicate absence detected
        switchLED(on: false)
        sleep_ms(100)
        switchLED(on: true)
        sleep_ms(100)
        switchLED(on: false)
        sleep_ms(100)
        switchLED(on: true)

    case (false, false):
        // No presence detected
        // Check if LED is on and absence period ended
        guard gpio_get(LED_PIN), let absenceTime = absenceDetectedTime else { break }

        let sincenceAbsence = absolute_time_diff_us(absenceTime, get_absolute_time())
        let shouldTurnOff = sincenceAbsence > (1000 * 1000 * 60) // 1 minute from microseconds

        if shouldTurnOff {
            // Absence period ended, turn off LED
            switchLED(on: false)
            absenceDetectedTime = nil
        } else {
            // Blink once to indicate still absent
            switchLED(on: false)
            sleep_ms(200)
            switchLED(on: true)
        }
    }

    currentIsOn = newIsOn

    sleep_ms(refreshIntervalMS)
}