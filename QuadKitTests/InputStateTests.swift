//
//  InputStateTests.swift
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

import XCTest
@testable import QuadKit_iOS

class InputStateTests: XCTestCase {
	
	func createInputStateMax() -> InputState {
		var inputState = InputState()
		inputState.thrust = DBL_MAX
		inputState.pitch = DBL_MAX
		inputState.roll = DBL_MAX
		inputState.yaw = DBL_MAX
		return inputState
	}
	
	func createInputStateMin() -> InputState {
		var inputState = InputState()
		inputState.thrust = -DBL_MAX
		inputState.pitch = -DBL_MAX
		inputState.roll = -DBL_MAX
		inputState.yaw = -DBL_MAX
		return inputState
	}
	
	func testInputStateMaxValues() {
		
		let inputState = createInputStateMax()
		XCTAssertEqual(inputState.thrust, 1)
		XCTAssertEqual(inputState.pitch, 1)
		XCTAssertEqual(inputState.roll, 1)
		XCTAssertEqual(inputState.yaw, 1)
	}
	
	func testInputStateMinValues() {
		
		let inputState = createInputStateMin()
		XCTAssertEqual(inputState.thrust, 0)
		XCTAssertEqual(inputState.pitch, -1)
		XCTAssertEqual(inputState.roll, -1)
		XCTAssertEqual(inputState.yaw, -1)
	}
	
	func testInputStateNormalizedValues() {
		
		let normalized = InputState().normalized()
		
		XCTAssertEqual(normalized.thrust, 0)
		XCTAssertEqual(normalized.pitch, 0.5)
		XCTAssertEqual(normalized.roll, 0.5)
		XCTAssertEqual(normalized.yaw, 0.5)
	}
	
	func testInputStateMaxNormalizedValues() {
		
		let inputState = createInputStateMax()
		let normalized = inputState.normalized()
		
		XCTAssertEqual(normalized.thrust, 1)
		XCTAssertEqual(normalized.pitch, 1)
		XCTAssertEqual(normalized.roll, 1)
		XCTAssertEqual(normalized.yaw, 1)
	}
	
	func testInputStateMinNormalizedValues() {
		
		let inputState = createInputStateMin()
		let normalized = inputState.normalized()
		
		XCTAssertEqual(normalized.thrust, 0)
		XCTAssertEqual(normalized.pitch, 0)
		XCTAssertEqual(normalized.roll, 0)
		XCTAssertEqual(normalized.yaw, 0)
	}
	
	func testInputStateMaxByteValues() {
		
		let inputState = createInputStateMax()
		
		var thrust = Byte()
		var pitch = Byte()
		var roll = Byte()
		var yaw = Byte()
		inputState.getFinalValues(roll: &roll, pitch: &pitch, thrust: &thrust, yaw: &yaw)
		
		XCTAssertEqual(thrust, Byte.max)
		XCTAssertEqual(pitch, Byte.max)
		XCTAssertEqual(roll, Byte.max)
		XCTAssertEqual(yaw, Byte.max)
	}
	
	func testInputStateMinByteValues() {
		
		let inputState = createInputStateMin()
		
		var thrust = Byte()
		var pitch = Byte()
		var roll = Byte()
		var yaw = Byte()
		inputState.getFinalValues(roll: &roll, pitch: &pitch, thrust: &thrust, yaw: &yaw)
		
		XCTAssertEqual(thrust, Byte.min)
		XCTAssertEqual(pitch, Byte.min)
		XCTAssertEqual(roll, Byte.min)
		XCTAssertEqual(yaw, Byte.min)
	}
}
