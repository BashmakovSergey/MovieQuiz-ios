//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Башмаков Сергей on 17.01.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}
