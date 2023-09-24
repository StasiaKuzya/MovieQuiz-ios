import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        presenter.viewController = self

        
        imageView.backgroundColor = .ypBackground
        activityIndicator.color = .ypWhite
        
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)

        showLoadingIndicator()
        presenter.questionFactory?.loadData()

    }
    
    // MARK: - Public Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        enableButtons()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        let resultText = presenter.makeResultMessage()

        let result = AlertModel(
                        title: "Этот раунд окончен!",
                        text: resultText,
                        buttonText: "Сыграть ещё раз",
                        completion: {
                            self.presenter.restartGame()})

            AlertPresenter.showAlert(alertModel: result, delegate: self)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
        
    func showNetworkError(message: String) {
        
        let errorAlert = AlertModel(title: "Ошибка",
                                    text: message,
                                    buttonText: "Попробовать ещё раз",
                                    completion: {
                                        self.presenter.restartGame()})
        
        AlertPresenter.showAlert(alertModel: errorAlert, delegate: self)
        
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func disableButtons() {
        buttons.forEach { $0.isEnabled = false }
    }
    
    func enableButtons() {
        buttons.forEach { $0.isEnabled = true }
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
