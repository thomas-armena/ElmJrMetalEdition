//
//  EVEditor.swift
//  ElmJrMetalEdition
//
//  Created by Thomas Armena on 2021-01-01.
//  Copyright © 2021 Thomas Armena. All rights reserved.
//

import UIKit

protocol EVEditorDelegate {
    func editor(_ editor: EVEditor, didChangeTextEditorWidth width: CGFloat)
    func editor(_ editor: EVEditor, didChangeTextEditorHeight height: CGFloat)
    func editor(_ editor: EVEditor, didChangeSourceCode sourceCode: String)
}

class EVEditor {
    
    var delegate: EVEditorDelegate?
    var sourceCode: String
    var textEditorWidth: CGFloat
    var textEditorHeight: CGFloat
    
    init(){
        sourceCode = ""
        textEditorWidth = 500
        textEditorHeight = 500
    }
    
    func setTextEditorWidth(_ width: CGFloat) {
        textEditorWidth = width
        delegate?.editor(self, didChangeTextEditorWidth: width)
    }
    
    func setTextEditorHeight(_ height: CGFloat) {
        textEditorHeight = height
        delegate?.editor(self, didChangeTextEditorHeight: height)
    }
    
    func setSourceCode(_ sourceCode: String) {
        self.sourceCode = sourceCode
        delegate?.editor(self, didChangeSourceCode: sourceCode)
    }
    
    func run() {
        print(sourceCode)
        print("------")
        let lexer = EILexer(text: sourceCode)
        while(true){
            let token = try! lexer.nextToken()
            print(token)
            if token.type == .endOfFile {
                break
            }
        }

    }
}
