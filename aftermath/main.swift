//
//  main.swift
//  aftermath
//
//

import Foundation

print(#"""

          \      _|  |                 \  |         |    |
         _ \    |    __|   _ \   __|  |\/ |   _` |  __|  __ \
        ___ \   __|  |     __/  |     |   |  (   |  |    | | |
      _/    _\ _|   \__| \___| _|    _|  _| \__,_| \__| _| |_|
                                                              _( (~\
       _ _                        /                          ( \> > \
   -/~/ / ~\                     :;                \       _  > /(~\/
  || | | /\ ;\                   |l      _____     |;     ( \/ /   /
  _\\)\)\)/ ;;;                  `8o __-~     ~\   d|      \   \  //
 ///(())(__/~;;\                  "88p;.  -. _\_;.oP        (_._/ /
(((__   __ \\   \                  `>,% (\  (\./)8"         ;:'  i
)))--`.'-- (( ;,8 \               ,;%%%:  ./V^^^V'          ;.   ;.
((\   |   /)) .,88  `: ..,,;;;;,-::::::'_::\   ||\         ;[8:   ;
 )|  ~-~  |(|(888; ..``'::::8888oooooo.  :\`^^^/,,~--._    |88::| |
  \ -===- /|  \8;; ``:.      oo.8888888888:`((( o.ooo8888Oo;:;:'  |
 |_~-___-~_|   `-\.   `        `o`88888888b` )) 888b88888P""'     ;
  ;~~~~;~~         "`--_`.       b`888888888;(.,"888b888"  ..::;-'
   ;      ;              ~"-....  b`8888888:::::.`8888. .:;;;''
      ;    ;                 `:::. `:::OOO:::::::.`OO' ;;;''
 :       ;                     `.      "``::::::''    .'
    ;                           `.   \_              /
  ;       ;                       +:   ~~--  `:'  -';
                                   `:         : .::/
      ;                            ;;+_  :::. :..;;;
"""#
)

// Case management creation
let argManager = ArgManager(suppliedArgs:CommandLine.arguments)

// Start Aftermath
CaseFiles.CreateCaseDir()
let mainModule = AftermathModule()
mainModule.log("Aftermath Started")


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


// Persistence
mainModule.log("Starting Persistence Module")
let persistenceModule = PersistenceModule()
persistenceModule.run()
mainModule.log("Finished logging persistence items")


// FileSystem
mainModule.log("Started gathering file system information...")
let browserModule = BrowserModule()
browserModule.run()
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


// Memory
mainModule.log("Started memory dump...")
let memoryModule = MemoryModule()
memoryModule.run()
mainModule.log("Finishing memory dump")


// End Aftermath
mainModule.log("Aftermath Finished")

