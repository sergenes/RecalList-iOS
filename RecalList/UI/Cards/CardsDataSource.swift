//
//  CardsDataSource.swift
//  RecalList
//
//  Created by Serge Nes on 9/17/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit
import Koloda

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
        
        cardView.setup(card: card, cardsScreen: viewModel)
        
        if index % 2 == 0 {
            cardView.setColor(color: UIColor.init(netHex:0xb6caff))
        }else{
            cardView.setColor(color: UIColor.init(netHex:0xadf4ff))
        }
        
        cardView.doRoundCorners()
        
        container.addSubview(cardView)
        container.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0)
        
        return container
    }
}
