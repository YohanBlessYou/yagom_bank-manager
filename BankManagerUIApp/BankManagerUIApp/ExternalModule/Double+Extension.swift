extension Double {
    var toTimeFormat: String {
        let minute = Int(self / 60)
        let second = Int(self) % 60
        let milisecond = Int((self - Double(Int(self))) * 1000)
        return String(format: "%.2d:%.2d:%.3d", minute, second, milisecond)
    }
}
