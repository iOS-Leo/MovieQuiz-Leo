
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
    var lastStepModel: QuizStepViewModel?
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
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
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = currentQuestion.correctAnswer == isYes
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
        
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
        
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
    
    
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        guard let statisticService = statisticService else {
            return "Ошибка загрузки статистики"
        }
        let bestGame = statisticService.bestGame
        let gamesCount = statisticService.gamesCount
        let accuracy = statisticService.totalAccuracy
        
        var recordLine: String
        
        
        if bestGame.total == 0 {
            recordLine = "Рекорд: ещё не установлен"
        } else {
            let bestGameDate = bestGame.date.dateTimeString
            recordLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGameDate))"
        }
        
        
        return """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            
            Количество сыгранных квизов: \(gamesCount)
            \(recordLine)
            Средняя точность: \(String(format: "%.2f", accuracy))%
            """
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
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
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    
}



