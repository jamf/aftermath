//
//  Process.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 7/6/22.
//

import Foundation
import Darwin
import ProcLib

class Pids {
    
//    let procRawDir: URL
//    let saveFile: URL
    
    let MaxPathLen = Int(4 * MAXPATHLEN)
    typealias rpidFunc = @convention(c) (CInt) -> CInt
    let InfoSize = Int32(MemoryLayout<proc_bsdinfo>.stride)

    
//    init(procRawDir: URL, saveFile: URL) {
//        self.procRawDir = procRawDir
//        self.saveFile = saveFile
//    }
//
//    // Inspired by https://gist.github.com/kainjow/0e7650cc797a52261e0f4ba851477c2f
//    func getActivePids() -> [Int] {
//        // Call proc_listallpids once with nil/0 args to get the current number of pids
//        var pids = [Int]()
//        let initialNumPids = proc_listallpids(nil, 0)
//
//        // Allocate a buffer of these number of pids.
//        // Make sure to deallocate it as this class does not manage memory for us.
//        let buffer = UnsafeMutablePointer<pid_t>.allocate(capacity: Int(initialNumPids))
//        defer {
//            buffer.deallocate()
//        }
//
//        // Calculate the buffer's total length in bytes
//        let bufferLength = initialNumPids * Int32(MemoryLayout<pid_t>.size)
//
//        // Call the function again with our inputs now ready
//        let numPids = proc_listallpids(buffer, bufferLength)
//
//        // Loop through each pid
//        for i in 0..<numPids {
//            let pid = buffer[Int(i)]
//            pids.append(Int(pid))
//        }
//
//        return pids
//    }
//
//    // Get the path for the pid
//    func getPidPath(_ pidOfInterest:Int) -> String {
//        let pathBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: MaxPathLen)
//        defer { pathBuffer.deallocate() }
//        pathBuffer.initialize(repeating: 0, count: MaxPathLen)
//
//        var path: String
//        if proc_pidpath(Int32(pidOfInterest), pathBuffer, UInt32(MemoryLayout<Int8>.stride * MaxPathLen)) > 0 {
//            path = String(cString: pathBuffer)
//        } else {
//            path = "unknown"
//        }
//
//        return path
//    }
//
//    // Get responsible pid using private Apple API
//    func getResponsiblePid(_ pidOfInterest:Int) -> CInt {
//        let rpidSym:UnsafeMutableRawPointer! = dlsym(UnsafeMutableRawPointer(bitPattern: -1), "responsibility_get_pid_responsible_for_pid")
//        let pidCheck = unsafeBitCast(rpidSym, to: rpidFunc.self)(CInt(pidOfInterest))
//
//        var responsiblePid: CInt
//        if (pidCheck == -1) {
//            print("Error getting responsible pid for process " + String(pidOfInterest))
//            print("Defaulting to self")
//            responsiblePid = CInt(pidOfInterest)
//        } else {
//            responsiblePid = pidCheck
//        }
//
//        return responsiblePid
//    }
    
    
    func getPPID(_ pidOfInterest:Int, pidInfo:UnsafeMutablePointer<proc_bsdinfo>) -> UInt32? {
        // Call proc_pidinfo and return nil on error
        guard InfoSize == proc_pidinfo(Int32(pidOfInterest), PROC_PIDTBSDINFO, 0, pidInfo, InfoSize) else { return nil }
        
        return pidInfo.pointee.pbi_ppid
    }


    func getTimestamp(_ pidOfInterest:Int, pidInfo:UnsafeMutablePointer<proc_bsdinfo>) -> Date {
        // Call proc_pidinfo and return current date on error
        guard InfoSize == proc_pidinfo(Int32(pidOfInterest), PROC_PIDTBSDINFO, 0, pidInfo, InfoSize) else { return Date() }
        let ts = Date(timeIntervalSince1970: TimeInterval(pidInfo.pointee.pbi_start_tvsec))
        
        return ts
    }


    func getPidPath(_ pidOfInterest:Int) -> String {
        // Get the path for the pid
        let pathBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: MaxPathLen)
        defer { pathBuffer.deallocate() }
        pathBuffer.initialize(repeating: 0, count: MaxPathLen)

        var path: String
        if proc_pidpath(Int32(pidOfInterest), pathBuffer, UInt32(MemoryLayout<Int8>.stride * MaxPathLen)) > 0 {
            path = String(cString: pathBuffer)
        } else {
            path = "unknown"
        }
        
        return path
    }


    func getResponsiblePid(_ pidOfInterest:Int) -> CInt {
        // Get responsible pid using private Apple API
        let rpidSym:UnsafeMutableRawPointer! = dlsym(UnsafeMutableRawPointer(bitPattern: -1), "responsibility_get_pid_responsible_for_pid")
        let pidCheck = unsafeBitCast(rpidSym, to: rpidFunc.self)(CInt(pidOfInterest))
        
        var responsiblePid: CInt
        if (pidCheck == -1) {
            print("Error getting responsible pid for process " + String(pidOfInterest))
            print("Defaulting to self")
            responsiblePid = CInt(pidOfInterest)
        } else {
            responsiblePid = pidCheck
        }
        
        return responsiblePid
    }

    /* Old Code. No longer works on Big Sur+
    func getSubmittedByName(_ pidOfInterest: Int, _ launchdXPCInfo: [AnyHashable : Any]) -> String? {
        var submittedByName: String?
        if let path = launchdXPCInfo["path"] as? String {
            if (path.contains("submitted by")) {
                var submittedNameTmp = ""
                for x in path.split(separator: " ")[2...] {
                    submittedNameTmp += x + " "
                }
                
                submittedByName = String(submittedNameTmp.split(separator: ".").first!)
           }
       }
        return submittedByName
    }
    func getLaunchdProgramPath(_ pidOfInterest: Int, _ launchdXPCInfo: [AnyHashable : Any]) -> String? {
        var plistPath: String?
        if let programPath = launchdXPCInfo["program"] {
             plistPath = programPath as? String
        }
        
        return plistPath
    }
     */

    func getActivePids() -> [Int] {
        // Inspired by https://gist.github.com/kainjow/0e7650cc797a52261e0f4ba851477c2f
        
        // Call proc_listallpids once with nil/0 args to get the current number of pids
        var pids = [Int]()
        let initialNumPids = proc_listallpids(nil, 0)

        // Allocate a buffer of these number of pids.
        // Make sure to deallocate it as this class does not manage memory for us.
        let buffer = UnsafeMutablePointer<pid_t>.allocate(capacity: Int(initialNumPids))
        defer {
            buffer.deallocate()
        }

        // Calculate the buffer's total length in bytes
        let bufferLength = initialNumPids * Int32(MemoryLayout<pid_t>.size)

        // Call the function again with our inputs now ready
        let numPids = proc_listallpids(buffer, bufferLength)

        // Loop through each pid
        for i in 0..<numPids {
            let pid = buffer[Int(i)]
            pids.append(Int(pid))
        }
     
        return pids
    }
    


}
