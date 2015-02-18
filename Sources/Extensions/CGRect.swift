//
//  CGRect.swift
//

extension CGRect {

// MARK: debug
    func tap(_ name:String = "frame") -> CGRect {
        println("\(name): \(self)")
        return self
    }

// MARK: helpers
    var x:CGFloat { return self.origin.x }
    var y:CGFloat { return self.origin.y }

// MARK: absolute dimensions
    var minX:CGFloat { return CGRectGetMinX(self) }
    var midX:CGFloat { return CGRectGetMidX(self) }
    var maxX:CGFloat { return CGRectGetMaxX(self) }

    var minY:CGFloat { return CGRectGetMinY(self) }
    var midY:CGFloat { return CGRectGetMidY(self) }
    var maxY:CGFloat { return CGRectGetMaxY(self) }

    var width:CGFloat { return CGRectGetWidth(self) }
    var height:CGFloat { return CGRectGetHeight(self) }

// MARK: dimension setters
    func atOrigin(amt:CGPoint) -> CGRect {
        var f = self
        f.origin = amt
        return f
    }

    func withSize(amt:CGSize) -> CGRect {
        var f = self
        f.size = amt
        return f
    }

    func atX(amt:CGFloat) -> CGRect {
        var f = self
        f.origin.x = amt
        return f
    }

    func atY(amt:CGFloat) -> CGRect {
        var f = self
        f.origin.y = amt
        return f
    }

    func withWidth(amt:CGFloat) -> CGRect {
        var f = self
        f.size.width = amt
        return f
    }

    func withHeight(amt:CGFloat) -> CGRect {
        var f = self
        f.size.height = amt
        return f
    }

// MARK: inset(xxx:)
    func inset(#all:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: all, left: all, bottom: all, right: all))
    }

    func inset(#topBottom:CGFloat, sides: CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: topBottom, left: sides, bottom: topBottom, right: sides))
    }

    func inset(#top:CGFloat, sides: CGFloat, bottom: CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: top, left: sides, bottom: bottom, right: sides))
    }

    func inset(#top:CGFloat, left:CGFloat, bottom:CGFloat, right:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }

// MARK: shrinkXxx
    func shrinkLeft(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: 0, left: amt, bottom: 0, right: 0))
    }

    func shrinkRight(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: amt))
    }

    func shrinkDown(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: amt, left: 0, bottom: 0, right: 0))
    }

    func shrinkUp(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: 0, left: 0, bottom: amt, right: 0))
    }

// MARK: growXxx
    func growLeft(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: 0, left: -amt, bottom: 0, right: 0))
    }

    func growRight(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -amt))
    }

    func growDown(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: -amt, left: 0, bottom: 0, right: 0))
    }

    func growUp(amt:CGFloat) -> CGRect {
        return UIEdgeInsetsInsetRect(self, UIEdgeInsets(top: 0, left: 0, bottom: -amt, right: 0))
    }

// MARK: fromXxx
    func fromTop() -> CGRect {
        return CGRect(x: minX, y: minY, width: width, height: 0)
    }

    func fromBottom() -> CGRect {
        return CGRect(x: minX, y: maxY, width: width, height: 0)
    }

    func fromLeft() -> CGRect {
        return CGRect(x: minX, y: minY, width: 0, height: height)
    }

    func fromRight() -> CGRect {
        return CGRect(x: maxX, y: minY, width: 0, height: height)
    }

// MARK: shiftXxx
    func shiftUp(amt:CGFloat) -> CGRect {
        return self.atY(self.y - amt)
    }

    func shiftDown(amt:CGFloat) -> CGRect {
        return self.atY(self.y + amt)
    }

    func shiftLeft(amt:CGFloat) -> CGRect {
        return self.atX(self.x - amt)
    }

    func shiftRight(amt:CGFloat) -> CGRect {
        return self.atX(self.x + amt)
    }

}