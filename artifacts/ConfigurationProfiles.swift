//
//  ConfigurationProfiles.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class ConfigurationProfiles: ArtifactsModule {
    
    override func run() {
        
        self.log("Writing installed configuration profiles...")
        
        let outputFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "config_profiles.txt")
            
        let command = "profiles -C -o stdout-xml"
        let output = Aftermath.shell("\(command)")
        
        self.addTextToFile(atUrl: outputFile, text: output)
    }
}
