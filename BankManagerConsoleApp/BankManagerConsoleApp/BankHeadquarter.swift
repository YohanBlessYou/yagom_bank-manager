//
//  BankHeadquarter.swift
//  BankManagerConsoleApp
//
//  Created by Yeon on 2021/01/12.
//

import Foundation

class BankHeadquarter {
    let queue: DispatchQueue
    let second: Double = 1_000_000
    static let shared = BankHeadquarter()
    
    private init() {
        self.queue = DispatchQueue.init(label: "loanJudgementQueue")
    }
    
    func approveLoanTask(customer: Customer) {
        queue.sync { 
            print("\(BankManagerMessage.start)".format(customer.waitNumber, customer.priority.description, BankHeadquarter.Task.loanJudgement.rawValue))
            usleep(useconds_t(BankHeadquarter.Task.loanJudgement.timeForTask * second))
            print("\(BankManagerMessage.end)".format(customer.waitNumber, customer.priority.description, BankHeadquarter.Task.loanJudgement.rawValue))
        }
    }
    
    enum Task: String {
        case loanJudgement = "대출심사"
        
        var timeForTask: TimeInterval {
            switch self {
            case .loanJudgement:
                return 0.5
            }
        }
    }
}
