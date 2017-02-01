//
//  QuadControl.swift
//  QuadKit
//
//  Created by Gabriel O'Flaherty-Chan on 2017-02-01.
//  Copyright © 2017 Gabrieloc. All rights reserved.
//

import Foundation
import SwiftSocket

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

// Represents the data (in bytes) sent to the quadcopter
public struct InputState {
	
	public var trimPitch = 0.0	// Z Movement Calibration
	public var trimRoll = 0.0	// X Movement Calibration
	public var thrust = 0.0		// Y Movement
	public var pitch = 0.0		// X Movement
	public var roll = 0.0		// Z Movement
	public var yaw = 0.0		// Y Rotation
	
	public enum InputType: Int {
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


// Represents the data (in bytes) sent to the quadcopter
struct InputData {
	
	let start: (Byte, Byte) = (0x66, 0xCC)
	let end: (Byte, Byte) = (0x99, 0x33)
	let data: (Byte, Byte, Byte, Byte)
	
	init(_ data: (Byte, Byte, Byte, Byte)) {
		self.data = data
	}
	
	func createChecksum(_ bytes: [Byte]) -> Byte {
		return bytes.reduce ( 0, { $0 ^ $1 }) & 0xFF
	}
	
	public var formatted: [Byte] {
		let bytes = [data.0, data.1, data.2, data.3, 0x0]
		let checksum = createChecksum(bytes)
		return [start.0] + bytes + [checksum, end.0, start.1] + bytes + [checksum, end.1]
	}
}

struct InputController {
	
	var state = InputState()
	
	var data: [Byte] {
		
		var yaw: Byte = 0
		var roll: Byte = 0
		var pitch: Byte = 0
		var thrust: Byte = 0
		state.getFinalValues(roll: &roll,
		                     pitch: &pitch,
		                     thrust: &thrust,
		                     yaw: &yaw)
		
		// NOTE: This format may vary by model. Consider refactoring if this is the case.
		let data = InputData((roll, pitch, thrust, yaw))
		return data.formatted
	}
	
	var prettyData: String {
		
		let hexData = data.map { "0x\(String(format: "%X", $0))" }
		return hexData.joined(separator: ", ")
	}
}
