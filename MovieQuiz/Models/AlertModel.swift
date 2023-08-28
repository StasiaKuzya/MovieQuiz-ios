//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Анастасия on 22.08.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    let completion: (() -> Void)?
}
