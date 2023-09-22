import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        presenter.viewController = self

        
        imageView.backgroundColor = .ypBackground
        activityIndicator.color = .ypWhite
        
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        presenter.questionFactory?.loadData()

    }
    
    // MARK: - QuestionFactoryDelegate
    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        presenter.didReceiveNextQuestion(question: question)
//    }
//    
//    func didLoadDataFromServer() {
//        activityIndicator.stopAnimating()
//        questionFactory?.requestNextQuestion()
//    }
//
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
    // MARK: - Private Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        enableButtons()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.correctAnswers += 1
        } else {imageView.layer.borderColor = UIColor.ypRed.cgColor}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.presenter.showNextQuestionOrResults()
        }
        disableButtons()
    }
        
    private func disableButtons() {
        buttons.forEach { $0.isEnabled = false }
    }
    
    private func enableButtons() {
        buttons.forEach { $0.isEnabled = true }
    }
        
    func showNetworkError(message: String) {
        
        let errorAlert = AlertModel(title: "Ошибка",
                                    text: message,
                                    buttonText: "Попробовать ещё раз",
                                    completion: {
                                        self.presenter.restartGame()})
        
        AlertPresenter.showAlert(alertModel: errorAlert, delegate: self)
        
    }
    // MARK: - IBAction
    
    @IBAction private func yesButtonClick(_ sender: UIButton) {
        presenter.yesButtonClick()
    }
    
    @IBAction private func noButtonClick(_ sender: UIButton) {
        presenter.noButtonClick()
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
