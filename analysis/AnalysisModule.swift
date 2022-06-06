//
//  AnalysisModule.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/3/22.
//

import Foundation

class AnalysisModule: AftermathModule, AMProto {
    
    let name = "Analysis Module"
    let dirName = "Analysis"
    let description = "A module for analyzing results of Aftermath"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        self.log("Running from the analysis module")
    }
}
