//
//  ThemeViewController+Extensions.swift
//  Nextcloud
//
//  Created by Julio Padron on 10/19/23.
//  Copyright © 2023 Marino Faggiana. All rights reserved.
//

import UIKit

extension ThemeViewController {

    /// Shows an alert with the given description or default text if nil.
    func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Unknown error")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
