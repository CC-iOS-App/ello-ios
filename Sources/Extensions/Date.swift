////
///  Date.swift
//

extension Date {

    func toServerDateString() -> String {
        return ServerDateFormatter.string(from: self)
    }

    func toHTTPDateString() -> String {
        return HTTPDateFormatter.string(from: self)
    }

    var isInPast: Bool {
        let now = AppSetup.shared.now
        return self.compare(now) == ComparisonResult.orderedAscending
    }

}
