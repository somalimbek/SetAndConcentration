//
//  CardBehavior.swift
//  SetAndConcentration
//
//  Created by Limbek Soma on 2019. 12. 04..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class CardFlyawayBehavior: UIDynamicBehavior {
    
    var snap: UISnapBehavior?
    let pointToSnapTo: CGPoint
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var floatingBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 0.8
        behavior.resistance = 1
        return behavior
    }()

    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (.pi*2).arc4random
        push.magnitude = Constants.pushMagnitude
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    private func snap(_ item: UIDynamicItem, snapTo pointToSnap: CGPoint) {
        collisionBehavior.removeItem(item)
        floatingBehavior.removeItem(item)
        snap = UISnapBehavior(item: item, snapTo: pointToSnap)
        snap!.damping = Constants.snapDamping
        addChildBehavior(snap!)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        floatingBehavior.addItem(item)
        push(item)
        
        Timer.scheduledTimer(withTimeInterval: Constants.timeToWaitForMatchedCardsToFlyAround, repeats: false) { _ in
            self.snap(item, snapTo: self.pointToSnapTo)
        }
    }
    
    func removeItem(_ item: UIDynamicItem) {
        if let snap = snap {
            removeChildBehavior(snap)
        } else {
            collisionBehavior.removeItem(item)
            floatingBehavior.removeItem(item)
        }
    }
    
    init(in animator: UIDynamicAnimator, pointToFlyTo: CGPoint) {
        pointToSnapTo = pointToFlyTo
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(floatingBehavior)
        animator.addBehavior(self)
    }
}

extension CardFlyawayBehavior {
    struct Constants {
        static let pushMagnitude = CGFloat(5.0).arc4random + 20.0
        static let snapDamping = CGFloat(0.7)
        static let timeToWaitForMatchedCardsToFlyAround = 1.0
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
