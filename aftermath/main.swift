//
//  main.swift
//  aftermath
//
//  Created by Jaron Bradley on 11/16/21.
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

// Check Permissions
// Case management creation

let argManager = ArgManager(suppliedArgs:CommandLine.arguments)

let caseHandler = CaseHandler()

caseHandler.log("Aftermath Started")

// System Recon - Sal
caseHandler.log("Started system recon")
let systemReconModule = SystemReconModule(caseHandler: caseHandler)
systemReconModule.start()
caseHandler.log("Finished system recon")

// Network

// Processes

// Persistence - DJ Beef Stew
caseHandler.log("Started logging persistence items")
let persistenceModule = PersistenceModule(caseHandler: caseHandler)
persistenceModule.start()
caseHandler.log("Finished logging persistence items")

// FileSystem

// Artifacts
caseHandler.log("Started gathering artifacts...")
let artifactModule = ArtifactsModule(caseHandler: caseHandler)
artifactModule.start()
caseHandler.log("Finished gathering artifacts")

// Logs - Benyo
caseHandler.log("Started logging unified logs")
let unifiedLogModule = UnifiedLogModule(caseHandler: caseHandler)
unifiedLogModule.start()
caseHandler.log("Finished logging unified logs")

caseHandler.log("Aftermath Finished")
