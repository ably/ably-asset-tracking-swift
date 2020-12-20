class Subscriber: NSObject {
    let id: String
    let trackable: Trackable

    init(id: String, trackable: Trackable) {
        self.id = id
        self.trackable = trackable
    }
}
