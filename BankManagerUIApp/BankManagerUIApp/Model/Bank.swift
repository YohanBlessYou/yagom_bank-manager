import Foundation

class Bank {
    weak var delegate: BankUIDisplayable?
    
    private var currentClientNumber = 0
    private var isRunning = false
    private var elapsedServiceTime = 0.0
    private var timer: Timer?
    private let newClients = Queue<Client>()
    
    private let depositSemaphore = DispatchSemaphore(value: 2)
    private let loanSemaphore = DispatchSemaphore(value: 1)
    private let depositDispatchQueue = DispatchQueue(label: "depositDispatchQueue")
    private let loanDispatchQueue = DispatchQueue(label: "loanDispatchQueue")
    private let group = DispatchGroup()

    init() { }
    
    init(delegate: BankUIDisplayable) {
        self.delegate = delegate
    }

    func run() {
        if isRunning {
            processAllServicesForNewClients()
        } else {
            startBankingSerivce()
        }
    }
    
    func addNewClients(numberOfClients: Int) {
        for _ in (1...numberOfClients) {
            guard let service = Bank.Service.allCases.randomElement() else {
                return
            }
            self.currentClientNumber += 1
            let client = Client(waitingNumber: self.currentClientNumber, service: service)
            newClients.enqueue(client)
            delegate?.addToWaitingQueue(client: client)
        }
    }
}

//MARK: Banking Service Private Methods
extension Bank {
    private func startBankingSerivce() {
        isRunning = true
        fireTimer()
        processAllServicesForNewClients()
        group.notify(queue: DispatchQueue.global()) { [weak self] in
            self?.isRunning = false
            self?.invalidateTimer()
        }
    }

    private func processAllServicesForNewClients() {
        while let client = newClients.dequeue() {
            let queue = { () -> DispatchQueue in
                switch client.service {
                case .deposit:
                    return depositDispatchQueue
                case .loan:
                    return loanDispatchQueue
                }
            }()
            
            let semaphore = { () -> DispatchSemaphore in
                switch client.service {
                case .deposit:
                    return depositSemaphore
                case .loan:
                    return loanSemaphore
                }
            }()
            
            processServiceAsync(queue: queue, semaphore: semaphore, client: client)
        }
    }
    
    private func processServiceAsync(queue: DispatchQueue, semaphore: DispatchSemaphore, client: Client) {
        //MARK: 초기화 버튼에 의해 self가 해제되므로, semaphore.signal()이 실행될 수 있도록 group에 대한 직접참조를 확보
        let group = group
        queue.async(group: group) { [weak self] in
            semaphore.wait()
            DispatchQueue.main.sync {
                self?.delegate?.addToProcessingQueue(client: client)
                self?.delegate?.removeFromWaitingQueue(client: client)
            }
            
            DispatchQueue.global().async(group: group) {
                Thread.sleep(forTimeInterval: client.service.timeForCompletion)
                DispatchQueue.main.sync {
                    self?.delegate?.removeFromProcessingQueue(client: client)
                }
                semaphore.signal()
            }
        }
    }
}

//MARK: Timer methods
extension Bank {
    private func fireTimer() {
        timer = Timer(timeInterval: 0.013, repeats: true) { [weak self] _ in
            self?.elapsedServiceTime += 0.013
            guard let elapsedServiceTime = self?.elapsedServiceTime else {
                return
            }
            self?.delegate?.updateServiceTime(serviceTime: elapsedServiceTime)
        }
        
        guard let timer = timer else {
            return
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
    }
}

//MARK: Service Type
extension Bank {
    enum Service: String, CaseIterable {
        case deposit = "예금"
        case loan = "대출"
        
        var timeForCompletion: Double {
            switch self {
            case .deposit:
                return 0.7
            case .loan:
                return 1.1
            }
        }
    }
}
