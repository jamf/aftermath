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
    lazy var storylineFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "storyline.csv")
    
    init(collectionDir: String) {
        
        self.collectionDir = collectionDir
        

    }
    
    func run() {
        self.log("Running analysis on collected aftermath files")
        
//        self.copyFileToCase(fileToCopy: URL(fileURLWithPath: "\(self.collectionDir)/metadata.csv"), toLocation: CaseFiles.analysisCaseDir, newFileName: "raw_metadata.csv")
        
        // ex: timestamp, tcc_update, com.jamf.aftermath, <updates>
       addTextToFile(atUrl: storylineFile, text: "timestamp,type,other,path")

        let dbParser = DatabaseParser(collectionDir: collectionDir, storylineFile: storylineFile)
        dbParser.run()
        
        let timeline = Timeline(collectionDir: collectionDir, timelineFile: timelineFile, storylineFile: storylineFile)
        timeline.run()
        
        let storyline = Storyline(collectionDir: collectionDir, storylineFile: storylineFile, timelineFile: timelineFile)
        storyline.run()
    
    }
}
