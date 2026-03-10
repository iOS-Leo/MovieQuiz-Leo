import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol  {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var alertPresenter = ResultAlertPresenter()
    
    private var presenter : MovieQuizPresenter!
    private var buttonsBlocked = false
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButton(_ sender: UIButton) {
        guard !buttonsBlocked else { return }
        
        
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        guard !buttonsBlocked else { return }
        
        
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private Methods
    
    
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        buttonsBlocked = false
        
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                
                self.presenter.restartGame()
                
            }
        )
        
        alertPresenter.show(in: self, model: model)
        
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        buttonsBlocked = true // Блокируем кнопки, пока видна рамка
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ?
            UIColor(named: "ypGreen")?.cgColor :
            UIColor(named: "ypRed")?.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    
    func showLoadingIndicator() {
        
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            
            
            self.showLoadingIndicator()
            
        }
        
        alertPresenter.show(in: self, model: model)
        
        
    }
    
}

