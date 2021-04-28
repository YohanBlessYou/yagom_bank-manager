//
//  BankManager.swift
//  BankManagerConsoleApp
//
//  Created by steven on 2021/04/28.
//

import Foundation

class CustomerMaker {
    private var _numberOfCustomer: Int
    var numberOfCustomer: Int {
        return _numberOfCustomer
    }
    
    init() {
        self._numberOfCustomer = Int.random(in: 10...30)
    }
    
    func makeCustomers() -> [Customer] {
        var customers: [Customer] = []
        for i in 1..._numberOfCustomer {
            customers.append(Customer(waitingNumber: i))
        }
        return customers
    }
}

class BankManager {
    private var numberOfBanker: Int
    private var waitingLine: OperationQueue
    private var customerMaker: CustomerMaker
    var numberOfCustomer: Int {
        return customerMaker.numberOfCustomer
    }
    
    init(numberOfBanker: Int) {
        self.numberOfBanker = numberOfBanker
        waitingLine = OperationQueue()
        customerMaker = CustomerMaker()
        waitingLine.maxConcurrentOperationCount = self.numberOfBanker
    }
    
    func inputCustomersToWaitingLine() {
        customerMaker.makeCustomers().forEach{ waitingLine.addOperation($0.bankTask) }
        waitingLine.waitUntilAllOperationsAreFinished()
    }
}

