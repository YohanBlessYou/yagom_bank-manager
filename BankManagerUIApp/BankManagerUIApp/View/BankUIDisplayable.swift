protocol BankUIDisplayable: AnyObject {
    func addToWaitingQueue(client: Client)
    func addToProcessingQueue(client: Client)
    func removeFromWaitingQueue(client: Client)
    func removeFromProcessingQueue(client: Client)
    func updateServiceTime(serviceTime: Double)
}
