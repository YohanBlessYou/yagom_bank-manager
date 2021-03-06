class Queue<T> {
    private var head: Node<T>?
    private weak var tail: Node<T>?
    
    var isEmpty: Bool {
        return head == nil
    }

    func enqueue(_ value: T) {
        let node = Node(value)
        if isEmpty {
            head = node
        } else {
            tail?.link(to: node)
        }
        tail = node
    }

    func dequeue() -> T? {
        let value = head?.value
        head = head?.next
        return value
    }
    
    func clear() {
        head = nil
    }
    
    func peek() -> T? {
        return head?.value
    }
}

extension Queue {
    class Node<S> {
        let value: S
        private(set) var next: Node?
        
        init(_ value: S) {
            self.value = value
        }
        
        func link(to nextNode: Node) {
            next = nextNode
        }
        
        func unlink() {
            next = nil
        }
    }
}
