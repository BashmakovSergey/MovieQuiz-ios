//
//  StaticsticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Башмаков Сергей on 17.01.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}
