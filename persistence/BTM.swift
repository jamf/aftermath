//
//  BTM.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 10/17/23.
//

import Foundation

class BTM: PersistenceModule {
    
    override func run() {
        self.log("Dumping btm file")
        
        let command = "sfltool dumpbtm"
        let output = Aftermath.shell(command)
        
        let btmDumpFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "btm.txt")
        self.addTextToFile(atUrl: btmDumpFile, text: output)
    }
}
