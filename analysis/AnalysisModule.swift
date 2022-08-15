//
//  AnalysisModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC//

import Foundation

class AnalysisModule: AftermathModule, AMProto {
    
    let name = "Analysis Module"
    let dirName = "Analysis"
    let description = "A module for analyzing results of Aftermath"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    let analysisDir: String
    
    init(analysisDir: String) {
        
        self.analysisDir = analysisDir
    }
    
    func run() {
        self.log("Running from the analysis module")
                
        let parser = Parser(analysisDir: analysisDir)
        parser.parseTCC()
        parser.parseLSQuarantine()
    }
}
