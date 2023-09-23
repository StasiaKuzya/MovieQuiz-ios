//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Анастасия on 22.09.2023.
//

import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func disableButtons()
    func enableButtons()
}


final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties

    private var currentQuestionIndex: Int = 0
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - Properties
    
    weak var viewController: MovieQuizViewControllerProtocol?
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
//    weak var viewController: MovieQuizViewController?
    var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }
    
    // MARK: - Private Methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Methods
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
         let message = error.localizedDescription
         viewController?.showNetworkError(message: message)
     }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
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
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClick() {
        didAnswer(isYes: true)
    }
    func noButtonClick() {
        didAnswer(isYes: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let totalAccuracy = statisticService.totalAccuracy
        
        let resultText = """
        Ваш результат: \(correctAnswers)/10
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%
        """
        return resultText
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
                viewController?.show(quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.proceedToNextQuestionOrResults()
        }
        viewController?.disableButtons()
    }
}
