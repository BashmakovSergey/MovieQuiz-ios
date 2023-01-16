//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Башмаков Сергей on 12.01.2023.
//

import Foundation
import UIKit
//убрали приватность у стуктуры, потому что не запускалось окно и нет подсказок из урока
struct QuizStepViewModel{
    let image: UIImage
    let question: String
    let questionNumber: String
}
