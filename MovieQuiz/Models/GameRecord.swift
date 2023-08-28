//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Анастасия on 28.08.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    // Метод сравнения рекордов по количеству правильных ответов
    func isBetterThan(_ otherRecord: GameRecord) -> Bool {
        return correct >= otherRecord.correct
    }
}
