//
//  ErrorHandler.swift
//  YelpSearch
//
//  Created by Rifeng Ding on 2020-07-25.
//  Copyright © 2020 Rifeng Ding. All rights reserved.
//

import UIKit

protocol ErrorHandler {
    func handle(_ error: Error)
}

extension UIViewController: ErrorHandler {
    func handle(_ error: Error) {

        var errorMessage = error.localizedDescription
        if let graphQLError = error as? GraphQLQuerryError {
            errorMessage = graphQLError.message
        }
        let alert = UIAlertController(title: title,
                                      message: errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
