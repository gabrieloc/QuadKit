//
//  ExampleView.swift
//  QuadKit
//
//  Copyright (c) <2017>, Gabriel O'Flaherty-Chan
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by skysent.
//  4. Neither the name of the skysent nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY skysent ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL skysent BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
