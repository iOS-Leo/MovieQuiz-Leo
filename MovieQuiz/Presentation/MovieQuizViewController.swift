import UIKit

final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var alertPresenter = ResultAlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var buttonsBlocked = false
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        let moviesLoader = MoviesLoader()
        let factory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        self.questionFactory = factory
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButton(_ sender: UIButton) {
        if buttonsBlocked { return }
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        if buttonsBlocked { return }
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let text = getStatisticText(currentCorrect: correctAnswers, totalQuestions: questionsAmount)
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter.show(in: self, model: model)
        
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        buttonsBlocked = true
        if isCorrect {
            correctAnswers += 1 // 2
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?
        UIColor(named: "ypGreen")?.cgColor :
        UIColor(named: "ypRed")?.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        buttonsBlocked = false
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func getStatisticText(currentCorrect: Int, totalQuestions: Int) -> String {
        guard let service = statisticService else {
            return "Ошибка загрузки статистики"
        }
        let bestGame = service.bestGame
        let gamesCount = service.gamesCount
        let accuracy = service.totalAccuracy
        var recordLine: String
        
        
        if bestGame.total == 0 {
            recordLine = "Рекорд: ещё не установлен"
        } else {
            let bestGameDate = bestGame.date.dateTimeString
            recordLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))"
        }
        
        
        return """
            Ваш результат: \(currentCorrect)/\(totalQuestions)
            
            Количество сыгранных квизов: \(gamesCount)
            \(recordLine)
            Средняя точность: \(String(format: "%.2f", accuracy))%
            """
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
        
        
    }
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
        
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        
    }
}

