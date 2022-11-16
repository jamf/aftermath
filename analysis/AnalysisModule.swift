//
//  AnalysisModule.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation

@available(macOS 12, *)
class AnalysisModule: AftermathModule, AMProto {
    
    let name = "Analysis Module"
    let dirName = "Analysis"
    let description = "A module for analyzing results of Aftermath"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    let collectionDir: String
    lazy var timelineFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "temp_timeline.csv")
    lazy var storylineFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "temp_storyline.csv")
    
    
    init(collectionDir: String) {
        self.collectionDir = collectionDir
    }
    
    func run() {
        self.log("Running analysis on collected aftermath files")
        
        let _ = self.copyFileToCase(fileToCopy: URL(fileURLWithPath: "\(collectionDir)/Recon/system_information.txt"), toLocation: CaseFiles.analysisCaseDir, isAnalysis: true)
       addTextToFile(atUrl: storylineFile, text: "timestamp,type,other,path")

        let dbParser = DatabaseParser(collectionDir: collectionDir, storylineFile: storylineFile)
        dbParser.run()
        
        let logParser = LogParser(collectionDir: collectionDir, storylineFile: storylineFile)
        logParser.run()
        
        let processParser = ProcessParser(collectionDir: collectionDir, storylineFile: storylineFile)
        processParser.run()
        
        let timeline = Timeline(collectionDir: collectionDir, timelineFile: timelineFile, storylineFile: storylineFile)
        timeline.run()
        
        let storyline = Storyline(collectionDir: collectionDir, storylineFile: storylineFile, timelineFile: timelineFile)
        storyline.run()
    
    }
}
