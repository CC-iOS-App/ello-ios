////
///  ProfileBioViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ProfileBioViewSpec: QuickSpec {
    override func spec() {
        describe("ProfileBioView") {
            it("snapshots") {
                let subject = ProfileBioView(frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: 375, height: 60)
                    ))
                subject.bio = "<p>bio</p>"
                waitUntil { done in
                    delay(0.1) {
                        expectValidSnapshot(subject, named: "ProfileBioView", device: .Custom(subject.frame.size))
                        done()
                    }
                }
            }
        }
    }
}
