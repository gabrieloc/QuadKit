//
//  ExampleViewController.swift
//  QuadKit Example
//
//  Created by Gabriel O'Flaherty-Chan on 2017-02-02.
//  Copyright © 2017 Gabrieloc. All rights reserved.
//

#if os(OSX)
import QuadKit_macOS
import Cocoa
typealias ViewController = NSViewController
#elseif os(iOS)
import QuadKit_iOS
import UIKit
typealias ViewController = UIViewController
#endif

enum ControllerInput: Int {
	case rollLeft, rollRight, pitchForward, pitchBack, thrust, yawLeft, yawRight
}

protocol ControlView {
	func connectionUpdated(_ connected: Bool)
	var inputHandler: InputHandler? { get set }
}

protocol InputHandler {
	func connectClient()
	func inputUpdated(_ input: ControllerInput, selected: Bool)
}

class ExampleViewController: ViewController, InputHandler {
	
	let client = QuadClient()
	var inputState = InputState()
	
	func inputUpdated(_ input: ControllerInput, selected: Bool) {

		switch input {
		case .rollLeft:
			inputState.roll = selected ? -1.0 : 0.0
		case .pitchForward:
			inputState.pitch = selected ? -1.0 : 0.0
		case .rollRight:
			inputState.roll = selected ? 1.0 : 0.0
		case .pitchBack:
			inputState.pitch = selected ? 1.0 : 0.0
		case .thrust:
			inputState.thrust = selected ? 1.0 : 0.0
		case .yawLeft:
			inputState.yaw = selected ? -1.0 : 0.0
		case .yawRight:
			inputState.yaw = selected ? 1.0 : 0.0
		}
		
		client.updateInput(with: inputState)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if var view = view as? ControlView {
			view.inputHandler = self
		}
	}
	
	func connectClient() {
		
		let error = client.connect()
		
		if let view = view as? ControlView {
			view.connectionUpdated(error == nil)
		}
		#if os(iOS)
		if error != nil {
			let alert = UIAlertController(title: "Connection Failed", message: "There was an issue establishing a connection with your quadcopter. \n\nEnsure that it's on and that your device is connected to the quadcopter's Wi-Fi network", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		#endif
	}
}
