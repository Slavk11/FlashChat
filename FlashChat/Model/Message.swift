//
//  Message.swift
//  FlashChat
//
//  Created by Сазонов Станислав on 05.11.2023.
//

import Foundation
import CoreText

enum Sender {
    case me, you
}

struct Message {
    let sender: String
    let body: String
}
