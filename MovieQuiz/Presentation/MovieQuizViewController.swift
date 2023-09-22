import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
//    private var currentQuestionIndex = 0
    private var correctAnswers = 0
//    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.backgroundColor = .ypBackground
        activityIndicator.color = .ypWhite
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        questionFactory?.loadData()

    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
        
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    // MARK: - Private Methods
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let questionStep = QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//        return questionStep
//    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        enableButtons()
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {imageView.layer.borderColor = UIColor.ypRed.cgColor}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        disableButtons()
    }
    
    private func showNextQuestionOrResults() {
//        if currentQuestionIndex == questionsAmount - 1 {
        if presenter.isLastQuestion() {
            
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            
            let resultText = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%
            """
            
            let result = AlertModel(
                            title: "Этот раунд окончен!",
                            text: resultText,
                            buttonText: "Сыграть ещё раз",
                            completion: {
                                self.presenter.resetQuestionIndex()
                                self.correctAnswers = 0
                                self.questionFactory?.requestNextQuestion()})
            
            AlertPresenter.showAlert(alertModel: result, delegate: self)
            
        } else {
//            currentQuestionIndex += 1
            presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func disableButtons() {
        buttons.forEach { $0.isEnabled = false }
    }
    
    private func enableButtons() {
        buttons.forEach { $0.isEnabled = true }
    }
        
    private func showNetworkError(message: String) {
        
        let errorAlert = AlertModel(title: "Ошибка",
                                    text: message,
                                    buttonText: "Попробовать ещё раз",
                                    completion: {
                                        self.presenter.resetQuestionIndex()
                                        self.correctAnswers = 0
                                        self.questionFactory?.requestNextQuestion()})
        
        AlertPresenter.showAlert(alertModel: errorAlert, delegate: self)
        
    }
    // MARK: - IBAction
    
    @IBAction private func yesButtonClick(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClick(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

    
/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
