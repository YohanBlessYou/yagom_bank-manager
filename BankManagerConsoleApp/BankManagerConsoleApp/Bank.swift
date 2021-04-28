//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by steven on 2021/04/28.
//

import Foundation

struct BankPrinter {
    enum MenuPhrase {
        static let bankOpen = "1 : 은행개점"
        static let exit = "2 : 종료"
        static let input = "입력 : "
    }
    
    static func printMenu() {
        print(MenuPhrase.bankOpen)
        print(MenuPhrase.exit)
        print(MenuPhrase.input, terminator:"")
    }
    
    static func printFinishPharse(_ totalCustomerNumber: Int, _ totalSecond: Double) {
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(totalCustomerNumber)명이며, 총 업무시간은 \(totalSecond)초입니다.")
    }
    
    static func printWrongInputPharse() {
        print("잘못된 입력입니다. 다시 입력해주세요.")
    }
}

struct Inputer {
    enum StringConstant {
        static let blank = ""
    }
    
    static func receive() -> String {
        guard let input = readLine() else {
            return StringConstant.blank
        }
        return input
    }
}

class Bank {
    private var bankManager: BankManager
    
    init() {
        bankManager = BankManager(numberOfBanker: 1)
    }
    
    private func startWork() {
        let startTime = CFAbsoluteTimeGetCurrent()
        bankManager.inputCustomersToWaitingLine()
        let endTime = CFAbsoluteTimeGetCurrent()
        BankPrinter.printFinishPharse(bankManager.numberOfCustomer, endTime - startTime)
    }
    
    func open() {
        while (true) {
            BankPrinter.printMenu()
            let input = Inputer.receive()
            switch input {
            case "1":
                startWork()
            case "2":
                return
            default:
                BankPrinter.printWrongInputPharse()
            }
        }
    }
}
