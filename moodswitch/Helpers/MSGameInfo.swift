//
//  MSGameInfo.swift
//  moodswitch
//
//  Created by Sam Richard on 10/2/24.
//

import Foundation

class MSGameInfo {
    var score: Int
    var difficultyLevel: Int = 1
    
    init() {
        score = 0
    }
    
    func reset() {
        score = 0
    }
    
    func incrementScore(by amount: Int) {
        score = score + amount
    }

}
