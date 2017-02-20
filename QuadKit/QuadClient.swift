//
//  Client.swift
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

import Foundation
import SwiftSocket


public class QuadClient {

	let udpClient = UDPClient(address: "172.16.10.1", port: 8895)
	let tcpClient = TCPClient(address: "172.16.10.1", port: 8888)
	var controller = InputController()
	
	var verbose = false
	
	public struct QuadClientError: Error {
		enum ErrorKind {
			case connectionTimeout
			case failedToIdentify
		}
		let kind: ErrorKind
		let reason: String
	}
	
	func print(_ items: Any) {
		if verbose {
			Swift.print(items)
		}
	}

	public init() {}
	
	public func connect(withTimeout timeout: Int = 10, verbose: Bool = false) -> QuadClientError? {

		self.verbose = verbose
		
		if let connectionError = connectClient(withTimeout: timeout) {
			print("Couldn't connect: \(connectionError.reason)")
			return connectionError
		}
		
		if let identificationError = sendIdentification() {
			return identificationError
		}
		
		beginBroadcasting()
		
		return nil
	}
	
	func connectClient(withTimeout timeout: Int) -> QuadClientError? {
		
		switch tcpClient.connect(timeout: timeout) {
		case .failure(let socketError):
			return QuadClientError(kind: .connectionTimeout, reason: socketError.localizedDescription)
		default:
			return nil
		}
	}
	
	func sendIdentification() -> QuadClientError? {

		func isConversationValid(_ conversation: Conversation) -> Bool {

			let description = conversation.topic
			
			return conversation.packets.reduce(false, { (identified, message) -> Bool in
				
				print("\(description): Sending message \(message)")
				switch tcpClient.send(data: message) {
				case .success:
					let response = tcpClient.read(1024*10, timeout: 5) ?? []
					print("\(description): Received response \(response.count) bytes long")
					return true
				case .failure(let error):
					print("\(description): Failed: \(error)")
					return false
				}
			})
		}
		
		let identified = allIdentificationConversations.reduce(true, {
			$0 && isConversationValid($1)
		})
		
		return identified ? nil : QuadClientError(kind: .failedToIdentify, reason: "One or more identification errors")
	}
	
	// MARK: Input
	
	static let InputSyncInterval: TimeInterval = 0.05
	
	func beginBroadcasting() {
		
		udpClient.enableBroadcast()
		Timer.scheduledTimer(timeInterval: QuadClient.InputSyncInterval,
		                     target: self,
		                     selector: #selector(sendInputData),
		                     userInfo: nil,
		                     repeats: true)
	}
	
	public func updateInput(with state: InputState) {
		controller.state = state
	}
	
	@objc func sendInputData() {
		
		let inputData = controller.data
		switch udpClient.send(data: inputData) {
		case .success:
			print(controller.prettyData)
			break
		case .failure(let error):
			print("Failed to send input: \(error)")
		}
	}
}
