//
//  ExampleView.swift
//  QuadKit
//
//  Created by Gabriel O'Flaherty-Chan on 2017-02-05.
//  Copyright © 2017 Gabrieloc. All rights reserved.
//

import Cocoa

extension ControllerInput {
	
	init?(keyCode: Int) {
		let mapping = ControllerInput.keyCodeMapping
		guard let input = mapping.first(where: { $0.value == keyCode }) else {
			return nil
		}
		self = input.key
	}
	
	func keyCode() -> Int {
		return ControllerInput.keyCodeMapping[self]!
	}
	
	static let keyCodeMapping: [ControllerInput: Int] = [
		.rollLeft:		123,
		.rollRight:		124,
		.pitchBack:		125,
		.pitchForward:	126,
		.thrust:		49,
		.yawLeft:		6,
		.yawRight:		7
	]
}

extension NSView {
	var isSelected: Bool {
		get { return alphaValue == 1.0 }
		set { alphaValue = newValue ? 1.0 : 0.5 }
	}
}

class ExampleView: NSView, ControlView {

	@IBOutlet weak var rollLeft: NSTextField!
	@IBOutlet weak var rollRight: NSTextField!
	@IBOutlet weak var pitchUp: NSTextField!
	@IBOutlet weak var pitchDown: NSTextField!
	@IBOutlet weak var yawLeft: NSTextField!
	@IBOutlet weak var yawRight: NSTextField!
	@IBOutlet weak var thrust: NSTextField!
	@IBOutlet weak var connect: NSButton!
	
	public var inputHandler: InputHandler?

	override func awakeFromNib() {
		super.awakeFromNib()
		
		let controls = [rollLeft, rollRight, pitchUp, pitchDown, thrust, yawLeft, yawRight]
		controls.forEach { $0!.isSelected = false }
	}
	
	func directionView(for input: ControllerInput) -> NSView {
		switch input {
		case .rollLeft:		return rollLeft
		case .pitchForward:	return pitchDown
		case .rollRight:	return rollRight
		case .pitchBack:	return pitchUp
		case .thrust:		return thrust
		case .yawLeft:		return yawLeft
		case .yawRight:		return yawRight
		}
	}
	
	func connectionUpdated(_ connected: Bool) {
		let connectionTitle = connected ? "Connected" : "Reconnect"
		connect.title = connectionTitle
		
	}
	
	func updateSelection(for input: ControllerInput, selected: Bool) {
		
		directionView(for: input).isSelected = selected
		inputHandler?.inputUpdated(input, selected: selected)
	}
	
	@IBAction func connectSelected(_ sender: Any) {
		inputHandler?.connectClient()
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	override func keyDown(with event: NSEvent) {
		if let input = ControllerInput(keyCode: Int(event.keyCode)) {
			updateSelection(for: input, selected: true)
		}
	}
	
	override func keyUp(with event: NSEvent) {
		
		if let input = ControllerInput(keyCode: Int(event.keyCode))  {
			updateSelection(for: input, selected: false)
		}
	}
}
