//
//  Identification.swift
//  QuadKit
//
//  Created by Gabriel O'Flaherty-Chan on 2017-02-11.
//  Copyright © 2017 Gabrieloc. All rights reserved.
//

import Foundation

typealias Byte = UInt8
typealias Packet = [Byte]

struct Conversation {
	
	let topic: String
	let packets: [Packet]
	
	init(topic: String, packets: [Packet]) {
		self.topic = topic
		self.packets = packets
	}
}

protocol QuadcopterModel {
	
	var identification: Conversation { get }
}

extension QuadClient {
	
	var allIdentificationConversations: [Conversation] {
	
		// This list should grow over time
		let supportedModels = [
			EachineE10W()
		]
	
		return supportedModels.map { $0.identification }
	}
}
