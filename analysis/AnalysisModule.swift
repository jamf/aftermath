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
    let collectionDir: String
    lazy var timelineFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "timeline.csv")
    
    init(collectionDir: String) {
        
        self.collectionDir = collectionDir
    }
    
    func run() {
        self.log("Running analysis on collected aftermath files")
        

        let dbParser = DatabaseParser(collectionDir: collectionDir, timelineFile: timelineFile)
        dbParser.run()
        
        let timeline = Timeline(collectionDir: collectionDir, timelineFile: timelineFile)
        timeline.run()
        
    }
}
