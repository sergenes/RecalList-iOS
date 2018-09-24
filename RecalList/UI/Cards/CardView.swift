//
//  CardView.swift
//  RecalList
//
//  Created by Serge Nes on 9/15/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

import UIKit

public class CardView: UIView {
    
    var cardsScreen: CardsScreenProtocol!
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var markAsLearnedButton: UIButton!
    
    private var markedAsLearned = false
    private var backUpColor:UIColor?
    
    func setup(card: Card, index:Int, cardsScreen: CardsScreenProtocol) {
        self.cardsScreen = cardsScreen
        
        if cardsScreen.getDirection() == 0 {
            frontLabel.text = card.word
            backLabel.text = card.translation
        }else{
            frontLabel.text = card.translation
            backLabel.text = card.word
        }
        self.tag = card.index
        
        countLabel.text = "\(index+1) of \(cardsScreen.getCardsCount())"
        
        if card.peeped == -1 {
            markAsLearnedButton.setTitle("cancel", for: .normal)
        }else{
            markAsLearnedButton.setTitle("mark as learned", for: .normal)
        }
    }
    
    func doRoundCorners(){
        self.roundCorners(cornerRadius: 20.0)
        self.frontView.roundCorners(cornerRadius: 20.0)
        self.backView.roundCorners(cornerRadius: 20.0)
    }
    
    @IBAction func pressTranslate(_ sender: UIButton) {
        UIView.transition(from: self.frontView, to: self.backView, duration: 1, options: [.transitionFlipFromBottom, .showHideTransitionViews], completion: nil)
        self.backView.translatesAutoresizingMaskIntoConstraints = false
        
        cardsScreen.peepTranslation(index: self.tag)
    }
    
    @IBAction func pressBack(_ sender: UIButton) {
        UIView.transition(from: self.backView, to: self.frontView, duration: 1, options: [.transitionFlipFromBottom, .showHideTransitionViews], completion: nil)
        self.frontView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func pressSay(_ sender: Any) {
        cardsScreen.sayWord(index: self.tag)
    }
    
    @IBAction func pressMarkAsLearned(_ sender: UIButton) {
        if markedAsLearned {
            markedAsLearned = false
            cardsScreen.markAsLearned(index: self.tag)
            setColor(color:backUpColor!)
        }else{
            backUpColor = self.backgroundColor
            markedAsLearned = true
            cardsScreen.markAsLearned(index: self.tag)
            setColor(color: .green)
        }
        if markedAsLearned {
            sender.setTitle("cancel", for: .normal)
        }else{
            sender.setTitle("mark as learned", for: .normal)
        }
        pressBack(sender)
    }
    
    func setColor(color:UIColor){
        self.backgroundColor = color
        self.backView.backgroundColor = color
        self.frontView.backgroundColor = color
    }
    
}
