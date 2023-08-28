//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Анастасия on 27.08.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}


final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        let record = GameRecord(correct: count, total: amount, date: Date())
        
        if record.isBetterThan(bestGame) {
            bestGame = record
        }
        
        let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let totalTotal = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        
        userDefaults.set(totalCorrect, forKey: Keys.correct.rawValue)
        userDefaults.set(totalTotal, forKey: Keys.total.rawValue)
        
        gamesCount += 1
        
        userDefaults.set(gamesCount, forKey: Keys.gamesCount.rawValue)
        
    }
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            let totalCorrectAnswers = userDefaults.integer(forKey: Keys.correct.rawValue)
            let totalQuestionsAnswered = userDefaults.integer(forKey: Keys.total.rawValue)
            
            if totalQuestionsAnswered > 0 {
                return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
            } else {
                return 0.0
            }
        }
        set {
            userDefaults.set(newValue, forKey: "totalAccuracy")
        }
    }
    
    var gamesCount: Int{
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
}






