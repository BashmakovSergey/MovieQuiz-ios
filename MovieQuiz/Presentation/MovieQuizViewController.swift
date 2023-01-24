import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
// MARK: - Outlets
    
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenterProtocol?
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter?.delegate = self
        questionFactory?.requestNextQuestion()
    }
    
// MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
//MARK: - Private functions
    /*
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
*/
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"

        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }
    
    private func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect{
            correctAnswers += 1
            //здесь присутвует защита от прокликивания
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.cornerRadius = 20
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPGreen")?.cgColor : UIColor(named: "YPGreen")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showNextQuestionOrResults()
                }
        }else{
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.cornerRadius = 20
            imageView.layer.borderColor = isCorrect ? UIColor(named: "YPRed")?.cgColor : UIColor(named: "YPRed")?.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
                }
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == self.questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let totalAccuracyPercentage = String(format: "%.2f", statisticService.totalAccuracy * 100) + "%"
            let localizedTime = statisticService.bestGame.date.dateTimeString
            let bestGameStats = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"

            let text =
            """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGameStats) (\(localizedTime))
            Средняя точность: \(totalAccuracyPercentage)
            """

            let alert = AlertModel(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз") { [weak self] in
                guard let self = self else { return }

                self.currentQuestionIndex = 0 // сброс счета
                self.correctAnswers = 0

                self.questionFactory?.requestNextQuestion()  // заново показываем первый вопрос
            }
            alertPresenter?.show(result: alert)
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего урока на 1
            questionFactory?.requestNextQuestion()
        }
    }

    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    
    }
    

