//
//  LoadyAnimationType.swift
//  loady
//
//  Created by Farshad Jahanmanesh on 11/6/19.
//  Copyright © 2019 farshadJahanmanesh. All rights reserved.
//

import Foundation
public struct LoadyAnimationType: RawRepresentable {
	public var rawValue: Key
	public init(rawValue: Key) {
		self.rawValue = rawValue
	}
	public struct Key: RawRepresentable, Equatable {
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		public var rawValue: String
	}
}
