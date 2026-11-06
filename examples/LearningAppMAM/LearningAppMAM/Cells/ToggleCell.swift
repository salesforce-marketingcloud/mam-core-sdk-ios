//
//  ToggleCell.swift
//  LearningApp
//
//  Copyright © 2025 Salesforce. All rights reserved.
//

import UIKit
import SFMCSDK
import MobileAppMessagingSDK
import InboxFeatureSDK

class ToggleCell: UITableViewCell {
    
    enum ToggleType {
        case mobileAppMessagingAnalytics
        case inbox
    }
    
    private var toggleAction: ((Bool) -> Void)?
    
    private let toggle: UISwitch = {
        let toggle = UISwitch()
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        accessoryView = toggle
        selectionStyle = .none
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset cell state for reuse
        textLabel?.text = nil
        textLabel?.alpha = 1.0
        toggle.isOn = false
        toggle.isEnabled = true
        toggleAction = nil
        backgroundColor = nil
        contentView.backgroundColor = nil
    }
    
    // MARK: - Configuration Methods
    
    /// Configures cell for runtime toggles (Analytics, MAM Analytics, PI Analytics, Location, Inbox)
    func configureForRuntimeToggle(type: ToggleType, title: String) {
        textLabel?.text = title
        fetchInitialState(for: type)
        toggleAction = { [weak self] enabled in
            self?.handleToggleChange(for: type, enabled: enabled)
        }
    }
        
    // MARK: - Private Helpers
    
    private func fetchInitialState(for type: ToggleType) {
        switch type {
        case .mobileAppMessagingAnalytics:
            MobileAppMessaging.requestSdk { [weak self] mam in
                let isOn = mam?.isAnalyticsEnabled() ?? false
                self?.updateToggle(isOn: isOn)
            }
        case .inbox:
            InboxFeature.requestSdk { [weak self] inboxSdk in
                let isOn = inboxSdk?.isInboxEnabled() ?? false
                self?.updateToggle(isOn: isOn)
            }
        }
    }
    
    private func handleToggleChange(for type: ToggleType, enabled: Bool) {
        switch type {
        case .mobileAppMessagingAnalytics:
            MobileAppMessaging.requestSdk { mam in
                mam?.setAnalyticsEnabled(enabled)
            }
        case .inbox:
            InboxFeature.requestSdk { inboxSdk in
                inboxSdk?.setInboxEnabled(enabled)
            }
        }
    }
    
    private func updateToggle(isOn: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.toggle.isOn = isOn
        }
    }
    
    @objc private func toggleChanged() {
        toggleAction?(toggle.isOn)
    }
}
