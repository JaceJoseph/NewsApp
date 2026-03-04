//
//  Helper.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
import UIKit

class NetworkHelper {
    var getAPIToken: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "api_token") as? String else {
            return ""
        }
        return value
    }
    
    func formatISO8601DateString(
        _ isoString: String?,
        outputFormat: String = "dd MMM yyyy, HH:mm"
    ) -> String {
        guard let isoString else { return "" }

        // ISO8601 with fractional seconds
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // ISO8601 without fractional seconds
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]

        var date: Date?
        if let parsedDate = isoWithFraction.date(from: isoString) {
            date = parsedDate
        } else if let parsedDate = iso.date(from: isoString) {
            date = parsedDate
        }

        guard let finalDate = date else { return isoString } // fallback to raw

        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        return formatter.string(from: finalDate)
    }
}

private let loadingIndicatorTag = 999_999

extension UIViewController {
    func showLoading() {
        if view.viewWithTag(loadingIndicatorTag) != nil {
            return
        }
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.tag = loadingIndicatorTag
        
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func hideLoading() {
        if let indicator = view.viewWithTag(loadingIndicatorTag) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
    func showDynamicToast(message : String, font: UIFont){
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 8;
        toastContainer.clipsToBounds  =  true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font.withSize(10.0)
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        self.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 8)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -8)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -8)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 8)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 16)
        let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: -16)
        let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -100)
        self.view.addConstraints([c1, c2, c3])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
