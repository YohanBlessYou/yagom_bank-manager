struct Client {    
    let waitingNumber: Int
    let service: Bank.Service
    
    var descriptionForLabel: String {
        return "\(waitingNumber) - \(service.rawValue)"
    }
}
