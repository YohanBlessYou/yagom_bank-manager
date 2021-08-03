//
//  LinkedList.swift
//  BankManagerConsoleApp
//
//  Created by 김태영 on 2021/07/27.
//

import Foundation

class LinkedList<T> {
    
    private var head: Node<T>?
    private weak var tail: Node<T>?

    var headIsEmpty: Bool {
        head == nil
    }
    
    var headValue: T? {
        return head?.value
    }
    
    var tailValue: T? {
        return tail?.value
    }
    
    func append(value: T) {
        if headIsEmpty {
            head = Node(value: value, next: nil)
            tail = head
        } else {
            tail?.next = Node(value: value, next: nil)
            tail = tail?.next
        }
    }
    
    func removeFirst() -> T? {
        defer {
            head = head?.next
        }
        return head?.value
    }
    
    func removeAll() {
        head = nil
    }
}