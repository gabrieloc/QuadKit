# QuadKit

QuadKit provides a simple set of interfaces for connecting and sending input data to your Wi-Fi enabled quadcopter.

## Installation

QuadKit relies on [SwiftSocket](https://github.com/swiftsocket/SwiftSocket), which lives as a git submodule. After cloning this repo, call:

`git submodule update --init --recursive`

*Carthage and CocoaPods support coming soon*

## Integration

Ensure any project using this framework includes `QuadKit.framework` and `SwiftSocket.framework` as embedded binaries.

To connect to your quadcopter, create an instance of `QuadClient` and call `-connect:`. Ensure that your device has been connected to the Wi-Fi network created by your quadcopter, before attempting to connect. Once a connection has been established, the client expects to be passed an `InputState` object via `-updateInput:`, in response to user interaction.

### Example

``` Swift

let client = QuadClient()
let inputState = InputState()
let thrustControl = UIControl()

func connectClient() {
	if let error = client.connect() {
		// Error connecting
	}
	thrustControl.enabled = true
}

func thrustControlTouched(_ thrustControl: UIControl) {
	inputState.thrust = thrustControl.selected ? 1.0 : 0.0
	client.updateInput(with inputState)
}
```

iOS and macOS samples can be found inside the `Examples/` directory.


## Contributing

While the format for input data appears to be generic across models (needs to be verified), identification data likely isn't. For this reason, `IdentificationSupport` defines a protocol `QuadcopterModel`, which individual models are intended to provide an implementation of. The protocol requires adopters to provide identification data, a stream of bytes, which get broadcasted to the quadcopter before anything else.

Identification data can be found by running a tool like `tcpdump` or `Wireshark` to get a packet trace, and collecting the first few packets your device sends your quadcopter in the software provided by it's manufacturer.

### Example
1. Connect your device via USB and create a RVI:
`$ rvictl -s (DEVICE UDID)`
2. Ensure the interface was created by running:
`$ ifconfig -l`
3. Verify that `rvi0` exists.
4. Turn on your quadcopter and join it's Wi-Fi network.
5. In a tool like [Wireshark](https://www.wireshark.org), begin capturing `rvi0`
6. Open the software provided by your quadcopter's manufacturer and access the input controls
7. Stop capturing and find what looks like identification data. It should consistently look the same every time you try to connect the app, and will appear before you begin receiving any form of input or video data
8. Record that data in byte arrays and have returned by your new `QuadcopterModel` adopting class in `QuadKit` in the `-identification` getter.
 

Apple provides step by step instructions for creating using various network debugging tools: [Technical Q&A QA1176: Getting a Packet Trace](https://developer.apple.com/library/content/qa/qa1176/_index.html).





