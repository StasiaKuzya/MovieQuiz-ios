//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Анастасия on 20.08.2023.
//

import Foundation
import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            }
            catch {
                print("Failed to load image")
                let alertModel = AlertModel(
                    title: "Ошибка",
                    text: "Не удалось загрузить изображение фильма. Пожалуйста, повторите попытку позже.",
                    buttonText: "Попробовать ещё раз",
                    completion: nil
                )
                guard let delegateViewController = self.delegate as? UIViewController else {
                    return }
                
                AlertPresenter.showAlert(alertModel: alertModel, delegate: delegateViewController)
                
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRatingForQuestion = arc4random_uniform(3) + 7

            let text = "Рейтинг этого фильма больше чем \(randomRatingForQuestion)?"
            let correctAnswer = rating >= Float(randomRatingForQuestion)
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
        
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}

