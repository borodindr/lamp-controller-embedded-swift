struct LED {
    let pin: UInt32

    var isOn: Bool {
        gpio_get(pin)
    }

    init(pin: UInt32) {
        self.pin = pin
        gpio_init(pin)
        gpio_set_dir(pin, true)
    }

    func set(on: Bool) {
        gpio_put(pin, on)
    }

    func blink(times: Int = 1, intervalMS: UInt32 = 100) {
        let initialState = isOn
        for _ in 0..<times {
            set(on: !initialState)
            sleep_ms(intervalMS)
            set(on: initialState)
            sleep_ms(intervalMS)
        }
    }
}

extension LED {
    static func blue() -> LED {
        LED(pin: LED_PIN)
    }
}