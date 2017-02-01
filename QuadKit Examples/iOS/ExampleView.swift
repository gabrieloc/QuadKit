//
//  ExampleView.swift
//  QuadKit
//
//  Created by Gabriel O'Flaherty-Chan on 2017-02-05.
//  Copyright © 2017 Gabrieloc. All rights reserved.
//

import UIKit

class ExampleView: UIView, ControlView {

	@IBOutlet weak var thrust: UIButton!
	@IBOutlet weak var connectButton: UIButton!
	
	public var inputHandler: InputHandler?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		thrust.isEnabled = false
	}
	
	func connectionUpdated(_ connected: Bool) {
		connectButton.isEnabled = !connected
		let connectTitle = connected ? "Connected" : "Reconnect"
		connectButton.setTitle(connectTitle, for: .normal)
		thrust.isEnabled = connected
	}

	@IBAction func beginThrust(_ sender: Any) {
		inputHandler?.inputUpdated(.thrust, selected: true)
	}

	@IBAction func endThrust(_ sender: Any) {
		inputHandler?.inputUpdated(.thrust, selected: false)
	}

	@IBAction func connectSelected(_ sender: Any) {
		inputHandler?.connectClient()
	}
}
