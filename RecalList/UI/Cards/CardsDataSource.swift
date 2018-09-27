//
//  CardsDataSource.swift
//  RecalList
//
//  Created by Serge Nes on 9/17/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import Koloda

extension UIColor {
    static let pink = UIColor.init(netHex:0xffc7c7)
    static let green = UIColor.init(netHex:0xb2ffa1)
    static let blue = UIColor.init(netHex:0xadf4ff)
    static let purple = UIColor.init(netHex:0xb6caff)
}

let PAINT_IN_PINK_CONDITION = 10
let MARKED_AS_KNOWN = -1

class CardsDataSource: KolodaViewDataSource {
    private var viewModel: CardsViewModel
    
    init(viewModel: CardsViewModel) {
        self.viewModel = viewModel
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return viewModel.getCardsCount()
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card = viewModel.getCard(index: index)
        let container:UIView = UIView()
        let cardView:CardView = CardView.fromNib()
        cardView.frame = CGRectMake(0,0,koloda.frame.width,koloda.frame.height - 150)
        
        cardView.setup(card: card, index: index, cardsScreen: viewModel)
        
        if card.peeped > PAINT_IN_PINK_CONDITION {
            cardView.setColor(color: .pink)//pink
        }else if card.peeped == MARKED_AS_KNOWN {
            cardView.setColor(color: .green)//green
        }else if index % 2 == 0 {
            cardView.setColor(color: .blue)//blue
        }else{
            cardView.setColor(color: .purple)//purple
        }
        
        cardView.doRoundCorners()
        
        container.addSubview(cardView)
        container.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0)
        
        return container
    }
}
