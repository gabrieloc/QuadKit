//
//  InputState.swift
//  QuadKit
//
//  Created by Gabriel O'Flaherty-Chan on 2017-03-01.
//  Copyright © 2017 Gabrieloc. All rights reserved.
//

import Foundation

func clamp(_ x: Double, min: Double, max: Double) -> Double {
	return Swift.min(max, Swift.max(min, x))
}

func clamp(_ x: Int, min: Int, max: Int) -> Int {
	return Swift.min(max, Swift.max(min, x))
}

extension Double {
	var byteValue: Byte {
		return Byte(clamp(self, min: 0.0, max: 1.0) * 0xFF)
	}
}

public struct InputState {
	
	public var trimPitch = 0.0	// Z Movement Calibration
	public var trimRoll = 0.0	// X Movement Calibration
	
	// Y Movement
	public var thrust: Double {
		get { return _trimPitch }
		set { _trimPitch = clamp(newValue, min: 0, max: 1) }
	}
	
	// X Movement
	public var pitch: Double {
		get { return _pitch }
		set { _pitch = clamp(newValue, min: -1, max: 1) }
	}
	
	// Z Movement
	public var roll: Double {
		get { return _roll }
		set { _roll = clamp(newValue, min: -1, max: 1) }
	}
	
	// Y Rotation
	public var yaw: Double {
		get { return _yaw }
		set { _yaw = clamp(newValue, min: -1, max: 1) }
	}
	
	private var _trimPitch = 0.0
	private var _trimRoll = 0.0
	private var _thrust = 0.0
	private var _pitch = 0.0
	private var _roll = 0.0
	private var _yaw = 0.0
	
	private enum InputType: Int {
		case thrust, pitch, roll, yaw
	}
	
	public init() {}
	
	func normalized() -> InputState {
		
		var n = InputState()
		
		n.trimPitch = trimPitch
		n.trimRoll = trimRoll
		
		n.thrust = thrust
		n.pitch = (pitch + 1.0) * 0.5
		n.roll = (roll + 1.0) * 0.5
		n.yaw = (yaw + 1.0) * 0.5
		
		return n
	}
	
	func getFinalValues(roll: inout Byte, pitch: inout Byte, thrust: inout Byte, yaw: inout Byte) {
		
		let normalized = self.normalized()
		
		let calibratedRoll = Int(normalized.roll.byteValue) + Int(normalized.trimRoll)
		let calibratedPitch = Int(normalized.pitch.byteValue) + Int(normalized.trimPitch)
		
		roll = Byte(clamp(calibratedRoll, min: 0, max: Int(Byte.max)))
		pitch = Byte(clamp(calibratedPitch, min: 0, max: Int(Byte.max)))
		thrust = normalized.thrust.byteValue
		yaw = normalized.yaw.byteValue
	}
}
