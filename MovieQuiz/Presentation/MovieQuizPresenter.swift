
import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers: Int = 0
    
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol? = StatisticService()
    private var lastStepModel: QuizStepViewModel?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    private enum Constants {
        static let resultsTitle = "Этот раунд окончен!"
        static let playAgainButtonText = "Сыграть ещё раз"
        static let statsErrorMessage = "Ошибка загрузки статистики"
        static let noRecordMessage = "Рекорд: ещё не установлен"
        static let resultLabel = "Ваш результат: "
        static let gamesCountLabel = "Количество сыгранных квизов: "
        static let averageAccuracyLabel = "Средняя точность: "
        static let recordLabel = "Рекорд: "
    }
    
    // MARK: - Private Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (
            image: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
        
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
        
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.correctAnswer == isYes
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func makeResultsMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        guard let statisticService = statisticService else {
            return Constants.statsErrorMessage
        }
        let bestGame = statisticService.bestGame
        let gamesCount = statisticService.gamesCount
        let accuracy = statisticService.totalAccuracy
        
        var recordLine: String
        
        
        if bestGame.total == 0 {
            recordLine = Constants.noRecordMessage
        } else {
            let bestGameDate = bestGame.date.dateTimeString
            recordLine = "\(Constants.recordLabel)\(bestGame.correct)/\(bestGame.total) (\(bestGameDate))"
        }
        
        
        return """
            \(Constants.resultLabel)\(correctAnswers)/\(questionsAmount)
            
            \(Constants.gamesCountLabel)\(gamesCount)
            \(recordLine)
            \(Constants.averageAccuracyLabel)\(String(format: "%.2f", accuracy))%
            """
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            let text = makeResultsMessage()
            
            let viewModel = QuizResultsViewModel(
                title: Constants.resultsTitle,
                text: text,
                buttonText: Constants.playAgainButtonText)
            viewController?.show(quiz: viewModel)
        } else {
            
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}



