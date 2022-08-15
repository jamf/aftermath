//
//  main.swift
//  aftermath

//  Copyright  2022 JAMF Software, LLC


import Foundation


// Case management creation
let argManager = ArgManager(suppliedArgs:CommandLine.arguments)
let mode = argManager.mode
let analysisDir = argManager.analysisDir
let outputDir = argManager.outputDir
let deepScan = argManager.deep




if mode == "default" {
    // Start Aftermath

    CaseFiles.CreateCaseDir()
    let mainModule = AftermathModule()
    mainModule.log("Aftermath Started")
    
    mainModule.addTextToFile(atUrl: CaseFiles.metadataFile, text: "file,birth,modified,accessed")
    
    
    // System Recon
    mainModule.log("Started system recon")
    let systemReconModule = SystemReconModule()
    systemReconModule.run()
    mainModule.log("Finished system recon")


    // Network
    mainModule.log("Started gathering network information...")
    let networkModule = NetworkModule()
    networkModule.run()
    mainModule.log("Finished gathering network information")


    // Processes
    mainModule.log("Starting process dump...")
    let procModule = ProcessModule()
    procModule.run()
    mainModule.log("Finished gathering process information")


    // Persistence
    mainModule.log("Starting Persistence Module")
    let persistenceModule = PersistenceModule()
    persistenceModule.run()
    mainModule.log("Finished logging persistence items")


    // FileSystem
    mainModule.log("Started gathering file system information...")
    let fileSysModule = FileSystemModule()
    fileSysModule.run()
    mainModule.log("Finished gathering file system information")


    // Artifacts
    mainModule.log("Started gathering artifacts...")
    let artifactModule = ArtifactsModule()
    artifactModule.run()
    mainModule.log("Finished gathering artifacts")

    
    // Logs
    mainModule.log("Started logging unified logs")
    let unifiedLogModule = UnifiedLogModule()
    unifiedLogModule.run()
    mainModule.log("Finished logging unified logs")
    
    
    // Copy from cache to /tmp
    CaseFiles.MoveCaseDir(outputDir: outputDir)
    
    // End Aftermath
    mainModule.log("Aftermath Finished")
}


if mode == "--analyze" {
    // Start Aftermath
    
    // Create analysis case file
    CaseFiles.CreateAnalysisCaseDir()
    
    let mainModule = AftermathModule()
    mainModule.log("Aftermath Analysis Started")
    
    let unzippedDirectory = mainModule.unzipArchive(location: analysisDir)
    
    mainModule.log("Started analysis on Aftermath directory: \(unzippedDirectory)")
    let analysisModule = AnalysisModule(analysisDir: unzippedDirectory)
    analysisModule.run()
    mainModule.log("Finished analysis module")
    
    // Move analysis directory to tmp
    CaseFiles.MoveAnalysisCaseDir()
    
    // End Aftermath
    mainModule.log("Aftermath Finished")
    
}

