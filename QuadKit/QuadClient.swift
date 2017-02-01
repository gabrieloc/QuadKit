//
//  Client.swift
//  QuadKit
//
//  Created by Gabriel O'Flaherty-Chan on 2017-01-23.
//  Copyright © 2017 Gabrieloc. All rights reserved.
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
