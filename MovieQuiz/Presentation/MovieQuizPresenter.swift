//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Анастасия on 22.09.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    
    // MARK: - Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
