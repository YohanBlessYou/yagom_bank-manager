//
//  BankManagerUIApp - BankViewController.swift
//  Created by yagom. 
//  Copyright © yagom academy. All rights reserved.
// 

import UIKit

class MainViewController: UIViewController {
    
    private var addTenClientsButton: UIButton!
    private var resetButton: UIButton!
    private var serviceTimeLabel: UILabel!
    private var waitingQueueLabel: UILabel!
    private var processingQueueLabel: UILabel!
    private var mainStackView: UIStackView!
    private var buttonStackView: UIStackView!
    private var queueLabelStackView: UIStackView!
    private var queueStackView: UIStackView!
    private var waitingQueueStackView: UIStackView!
    private var processingQueueStackView: UIStackView!
    
    private var bank: Bank?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bank = Bank(delegate: self)
        
        buildAllUIComponents()
        configureButtonActions()
        configureAutoLayout()
    }
    
    private func configureButtonActions() {
        addTenClientsButton.addTarget(
            self,
            action: #selector(addTenClients),
            for: .touchUpInside
        )
        resetButton.addTarget(
            self,
            action: #selector(resetAll),
            for: .touchUpInside
        )
    }
    
    @objc private func addTenClients() {
        bank?.addNewClients(numberOfClients: 10)
        bank?.run()
    }
    
    @objc private func resetAll() {  
        bank = Bank(delegate: self)
        
        mainStackView.removeFromSuperview()
        buildAllUIComponents()
        configureAutoLayout()
        configureButtonActions()
    }
}

//MARK: Building Views & Configure AutoLayout
extension MainViewController {
    private func serviceTimeDescription(serviceTime: Double) -> String {
        return "업무시간 - \(serviceTime.toTimeFormat)"
    }
    
    private func configureAutoLayout() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        mainStackView.addArrangedSubview(buttonStackView)
        mainStackView.addArrangedSubview(serviceTimeLabel)
        mainStackView.addArrangedSubview(queueLabelStackView)
        mainStackView.addArrangedSubview(queueStackView)
        
        buttonStackView.addArrangedSubview(addTenClientsButton)
        buttonStackView.addArrangedSubview(resetButton)

        queueLabelStackView.addArrangedSubview(waitingQueueLabel)
        queueLabelStackView.addArrangedSubview(processingQueueLabel)

        queueStackView.addArrangedSubview(waitingQueueStackView)
        queueStackView.addArrangedSubview(processingQueueStackView)
    }
    
    private func buildAllUIComponents() {
        buildButtons()
        buildServiceTimeLabel()
        buildQueueLabels()
        buildAllStackViews()
        view.addSubview(mainStackView)
    }
    
    private func buildButtons() {
        addTenClientsButton = UIButton(type: .system)
        addTenClientsButton.setTitle("고객 10명 추가", for: .normal)
        addTenClientsButton.setTitleColor(.systemBlue, for: .normal)
        addTenClientsButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        addTenClientsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addTenClientsButton.titleLabel?.numberOfLines = 0
        
        resetButton = UIButton(type: .system)
        resetButton.setTitle("초기화", for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
        resetButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        resetButton.titleLabel?.adjustsFontForContentSizeCategory = true
        resetButton.titleLabel?.numberOfLines = 0
    }
    
    private func buildServiceTimeLabel() {
        serviceTimeLabel = UILabel()
        serviceTimeLabel.text = serviceTimeDescription(serviceTime: 0)
        serviceTimeLabel.textAlignment = .center
        serviceTimeLabel.font = .preferredFont(forTextStyle: .title3)
        serviceTimeLabel.adjustsFontForContentSizeCategory = true
        serviceTimeLabel.numberOfLines = 0
    }
    
    private func buildQueueLabels() {
        waitingQueueLabel = UILabel()
        waitingQueueLabel.text = "대기중"
        waitingQueueLabel.textAlignment = .center
        waitingQueueLabel.backgroundColor = .systemGreen
        waitingQueueLabel.textColor = .white
        waitingQueueLabel.font = .preferredFont(forTextStyle: .title1)
        waitingQueueLabel.adjustsFontForContentSizeCategory = true
        waitingQueueLabel.numberOfLines = 0
        
        processingQueueLabel = UILabel()
        processingQueueLabel.text = "업무중"
        processingQueueLabel.textAlignment = .center
        processingQueueLabel.backgroundColor = .systemIndigo
        processingQueueLabel.textColor = .white
        processingQueueLabel.font = .preferredFont(forTextStyle: .title1)
        processingQueueLabel.adjustsFontForContentSizeCategory = true
        processingQueueLabel.numberOfLines = 0
    }
    
    private func buildAllStackViews() {
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 10.0
        
        buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        
        queueLabelStackView = UIStackView()
        queueLabelStackView.axis = .horizontal
        queueLabelStackView.distribution = .fillEqually
        
        queueStackView = UIStackView()
        queueStackView.axis = .horizontal
        queueStackView.distribution = .fillEqually
        queueStackView.alignment = .top
        
        waitingQueueStackView = UIStackView()
        waitingQueueStackView.axis = .vertical
        waitingQueueStackView.spacing = 10.0
        waitingQueueStackView.alignment = .center
        
        processingQueueStackView = UIStackView()
        processingQueueStackView.axis = .vertical
        processingQueueStackView.spacing = 10.0
        processingQueueStackView.alignment = .center
    }
}

//MARK: ClientStackViewManager
extension MainViewController {
    enum ClientStackViewManager {
        static func add(client: Client, to stackView: UIStackView) {
            let label = generateClientLabel(client: client)
            stackView.addArrangedSubview(label)
        }
        
        static func remove(client: Client, from stackView: UIStackView) {
            let subviews = stackView.arrangedSubviews
            
            let labelsToRemove = subviews.compactMap {
                $0 as? UILabel
            }.filter {
                $0.text == client.descriptionForLabel
            }
            
            labelsToRemove.forEach {
                $0.removeFromSuperview()
            }
        }
        
        private static func generateClientLabel(client: Client) -> UILabel {
            let label = UILabel()
            label.text = "\(client.waitingNumber) - \(client.service.rawValue)"
            
            switch client.service {
            case .deposit:
                label.textColor = .black
            case .loan:
                label.textColor = .systemPurple
            }
            return label
        }
    }
}

//MARK: BankUIUpdatable
extension MainViewController: BankUIDisplayable {
    func addToWaitingQueue(client: Client) {
        ClientStackViewManager.add(client: client, to: waitingQueueStackView)
    }
    
    func addToProcessingQueue(client: Client) {
        ClientStackViewManager.add(client: client, to: processingQueueStackView)
    }
    
    func removeFromWaitingQueue(client: Client) {
        ClientStackViewManager.remove(client: client, from: waitingQueueStackView)
    }
    
    func removeFromProcessingQueue(client: Client) {
        ClientStackViewManager.remove(client: client, from: processingQueueStackView)
    }
    
    func updateServiceTime(serviceTime: Double) {
        serviceTimeLabel.text = serviceTimeDescription(serviceTime: serviceTime)
    }
}
