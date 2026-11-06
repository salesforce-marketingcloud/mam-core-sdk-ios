//
//  HomeViewController.swift
//  LearningApp
//
//  Copyright © 2025 Salesforce. All rights reserved.
//

import UIKit
import SFMCSDK
import CoreLocation
import PushFeatureSDK
import MobileAppMessagingSDK
import InboxFeatureSDK

// MARK: - Notification Names

extension Notification.Name {
    static let locationFeatureToggled = Notification.Name("LocationFeatureToggled")
}

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var tableView: UITableView!
    private var locationUpdateObserver: NSObjectProtocol?
    private var locationToggleObserver: NSObjectProtocol?
    private var currentLocationText: String = "Location not yet updated"
    
    // MARK: - Section Data
    
    private enum Section: Int, CaseIterable {
        case documentation
        case registration
        case sdkFeatures
        case runtimeToggles
        case deviceInformation
        
        var title: String {
            switch self {
            case .documentation: return "Documentation"
            case .registration: return "Registration Management"
            case .sdkFeatures: return "SDK Features"
            case .runtimeToggles: return "Runtime Toggles"
            case .deviceInformation: return "Device Information"
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .documentation: return DocumentationRow.allCases.count
            case .registration: return RegistrationRow.allCases.count
            case .sdkFeatures: return SDKFeaturesRow.allCases.count
            case .runtimeToggles: return RuntimeToggleRow.allCases.count
            case .deviceInformation: return DeviceInfoRow.allCases.count
            }
        }
    }
    
    // MARK: - Row Definitions
    
    private enum DocumentationRow: Int, CaseIterable {
        case viewDocs
    }
    
    private enum RegistrationRow: Int, CaseIterable {
        case setValues
        case viewDebugState
    }
    
    private enum SDKFeaturesRow: Int, CaseIterable {
        case inbox
        case customEvent
    }
    
    private enum RuntimeToggleRow: Int, CaseIterable {
        case mobileAppMessagingAnalytics
        case inbox
        
        var title: String {
            switch self {
            case .mobileAppMessagingAnalytics: return "MAM Analytics"
            case .inbox: return "Inbox"
            }
        }
        
        var toggleType: ToggleCell.ToggleType {
            switch self {
            case .mobileAppMessagingAnalytics: return .mobileAppMessagingAnalytics
            case .inbox: return .inbox
            }
        }
    }

    private enum DeviceInfoRow: Int, CaseIterable {
        case mamDeviceID
        case pushToken
        
        var title: String {
            switch self {
            case .mamDeviceID: return "Copy MAM Device ID"
            case .pushToken: return "Copy Push Token"
            }
        }
        
        var subtitle: String {
            switch self {
            case .mamDeviceID: return "Copy Mobile App Messaging device identifier"
            case .pushToken: return "Copy APNS device token"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    deinit {
        if let observer = locationUpdateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = locationToggleObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MobilePush SDK Learning App"
        view.backgroundColor = .white
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: "SubtitleCell")
        tableView.register(ToggleCell.self, forCellReuseIdentifier: "ToggleCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    private func openDocumentation() {
        guard let url = URL(string: "https://developer.salesforce.com/docs/marketing/mobilepush/guide/overview.html") else { return }
        UIApplication.shared.open(url)
    }
    
    private func setRegistrationValues() {
        let vc = RegistrationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func viewDebugState() {
        let vc = DebugStateViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
        
    private func trackCustomEvent() {
        let vc = CustomEventTrackingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func openInbox() {
        InboxFeature.requestSdk { [weak self] inboxSdk in
            DispatchQueue.main.async {
                guard let self else { return }
                guard let inboxSdk else {
                    self.showAlert(title: "Inbox Unavailable", message: "Inbox is not ready yet.")
                    return
                }
                // Honor the Inbox setting exposed under Runtime Toggles.
                guard inboxSdk.isInboxEnabled() else {
                    self.showAlert(
                        title: "Inbox Disabled",
                        message: "Enable Inbox under Runtime Toggles before opening Inbox Messages."
                    )
                    return
                }

                self.navigationController?.pushViewController(InboxTableViewController(), animated: true)
            }
        }
    }

    private func copyMAMDeviceID() {
        MobileAppMessaging.requestSdk { [weak self] mam in
            guard let deviceID = mam?.deviceIdentifier() else {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Not Available", message: "MAM Device ID not available yet")
                }
                return
            }
            
            UIPasteboard.general.string = deviceID
            DispatchQueue.main.async {
                self?.showAlert(title: "Copied", message: "MAM Device ID:\n\(deviceID)")
            }
        }
    }
    
    private func copyPushToken() {
        PushFeature.requestSdk { [weak self] pushFeature in
            guard let token = pushFeature?.deviceToken() else {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Not Available", message: "Push token not available yet.\n\nMake sure:\n• App has registered for remote notifications\n• Device token has been received")
                }
                return
            }
            
            UIPasteboard.general.string = token
            DispatchQueue.main.async {
                self?.showAlert(title: "Copied", message: "Push Token copied to clipboard:\n\n\(token)")
            }
        }
    }
    
    // MARK: - Helper
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        return sec.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .documentation:
            return configureDocumentationCell(for: indexPath)
        case .registration:
            return configureRegistrationCell(for: indexPath)
        case .sdkFeatures:
            return configureSDKFeaturesCell(for: indexPath)
        case .runtimeToggles:
            return configureRuntimeTogglesCell(for: indexPath)
        case .deviceInformation:
            return configureDeviceInformationCell(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    // MARK: - Cell Configuration
    
    private func configureDocumentationCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as? SubtitleCell else {
            return UITableViewCell()
        }
        cell.configure(
            title: "View Documentation",
            subtitle: "Open SDK documentation"
        )
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func configureRegistrationCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as? SubtitleCell,
              let row = RegistrationRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch row {
        case .setValues:
            cell.configure(
                title: "Set Values",
                subtitle: "Configure user identity and party attributes"
            )
        case .viewDebugState:
            cell.configure(
                title: "View Debug State",
                subtitle: "View complete SDK state (JSON)"
            )
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func configureSDKFeaturesCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let row = SDKFeaturesRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch row {
        case .inbox:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = "Inbox Messages"
            cell.accessoryType = .disclosureIndicator
            return cell

        case .customEvent:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = "Track Custom Event"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    private func configureRuntimeTogglesCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as? ToggleCell,
              let row = RuntimeToggleRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.configureForRuntimeToggle(type: row.toggleType, title: row.title)
        return cell
    }
    
    private func configureDeviceInformationCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as? SubtitleCell,
              let row = DeviceInfoRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.configure(title: row.title, subtitle: row.subtitle)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .documentation:
            openDocumentation()
        case .registration:
            guard let row = RegistrationRow(rawValue: indexPath.row) else { return }
            switch row {
            case .setValues:
                setRegistrationValues()
            case .viewDebugState:
                viewDebugState()
            }
        case .sdkFeatures:
            guard let row = SDKFeaturesRow(rawValue: indexPath.row) else { return }
            switch row {
            case .inbox:
                openInbox()
            case .customEvent:
                trackCustomEvent()
            }
        case .deviceInformation:
            guard let row = DeviceInfoRow(rawValue: indexPath.row) else { return }
            switch row {
            case .mamDeviceID:
                copyMAMDeviceID()
            case .pushToken:
                copyPushToken()
            }
        case .runtimeToggles:
            break
        }
    }
}
