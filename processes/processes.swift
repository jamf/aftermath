//
//  process.swift
//  TrueTree
//
//  Created by Jaron Bradley on 11/1/19.
//  2020 TheMittenMac
//

import Foundation
import ProcLib
import LaunchdXPC

struct ttProcess {
    let pid: Int
    let ppid: Int
    let responsiblePid: Int
    let path: String
    let submittedByPid: Int?
    let submittedByPlist: String?
    let timestamp: String
    let node: Node
    let trueParentPid: Int
    let source: String
    let network: [NetworkConnection]
}


class ProcessCollector {
    var processes = [ttProcess]()
    let timestampFormat = DateFormatter()
    let InfoSize = Int32(MemoryLayout<proc_bsdinfo>.stride)
    let MaxPathLen = Int(4 * MAXPATHLEN)
    typealias rpidFunc = @convention(c) (CInt) -> CInt
    
    init() {
        timestampFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.collect()
    }
    
    func collect() {
        // Inspired by https://gist.github.com/kainjow/0e7650cc797a52261e0f4ba851477c2f
        
        // Call proc_listallpids once with nil/0 args to get the current number of pids
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
        
        // Loop through each pid and build a process struct
        for i in 0..<numPids {
            // Set the source string for when we locate a true parent
            var source: String = "Unknown"
            
            // Get Pid
            let pid = Int(buffer[Int(i)])
            
            // Skip for kernel process
            guard pid != 0 else { continue }
            
            // Get Parent
            let ppid = getPPID(pid) ?? 1
            
            // Get ResponsiblePid
            let responsiblePid = getResponsiblePid(pid)
            
            // Get SubmittedPid
            let submittedPid = Int(getSubmittedPid(Int32(pid)))
            
            // Get Process Path
            let path = getPath(pid)
            
            // Get Process Timestamp
            let ts = timestampFormat.string(from: getTimestamp(pid))
            
            // Get true parent. Plist parents will be handled elsewhere
            let trueParent: Int
            if submittedPid > 1 {
                trueParent = submittedPid
                source = "application_services"
            } else if responsiblePid != pid {
                trueParent = responsiblePid
                source = "responsible_pid"
            } else {
                trueParent = ppid
                source = "parent_process"
            }
            
            // Collect a plist if it caused this program to run
            var plistNode: String?
            if let launchctlPlist = getSubmittedByPlist(UInt(pid)) {
                if launchctlPlist.hasSuffix(".plist") {
                    plistNode = launchctlPlist
                    source = "launchd_xpc"
                }
            }
            
            // Collect network connections
            let n = TTNetworkConnections(pid: Int32(pid))
            let networkConnections = n.connections
            
            // Create the tree node
            let node = Node(pid, path: path, timestamp: ts, source: source, displayString: path)
            
            // Create the process entry
            let p = ttProcess(pid: pid,
                            ppid: ppid,
                            responsiblePid: responsiblePid,
                            path: path,
                            submittedByPid: submittedPid,
                            submittedByPlist: plistNode ?? nil,
                            timestamp: ts,
                            node: node,
                            trueParentPid: trueParent,
                            source: source,
                            network: networkConnections
            )
            
            // Add the process to the array of captured processes
            processes.append(p)
            
        }
        
        // Sort the processes by time
        processes = processes.sorted { $0.timestamp < $1.timestamp }
    }
    
    func getPPID(_ pidOfInterest:Int) -> Int? {
        // Call proc_pidinfo and return nil on error
        let pidInfo = UnsafeMutablePointer<proc_bsdinfo>.allocate(capacity: 1)
        guard InfoSize == proc_pidinfo(Int32(pidOfInterest), PROC_PIDTBSDINFO, 0, pidInfo, InfoSize) else { return nil }
        defer { pidInfo.deallocate() }
        
        return Int(pidInfo.pointee.pbi_ppid)
    }
    
    func getResponsiblePid(_ pidOfInterest:Int) -> Int {
        // Get responsible pid using private Apple API
        let rpidSym:UnsafeMutableRawPointer! = dlsym(UnsafeMutableRawPointer(bitPattern: -1), "responsibility_get_pid_responsible_for_pid")
        let responsiblePid = unsafeBitCast(rpidSym, to: rpidFunc.self)(CInt(pidOfInterest))
        
        guard responsiblePid != -1 else {
            print("Error getting responsible pid for process \(pidOfInterest). Setting to responsible pid to itself")
            return pidOfInterest
        }
        
        return Int(responsiblePid)
    }
    
    func getPath(_ pidOfInterest: Int) -> String {
        let pathBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: MaxPathLen)
        defer { pathBuffer.deallocate() }
        pathBuffer.initialize(repeating: 0, count: MaxPathLen)

        if proc_pidpath(Int32(pidOfInterest), pathBuffer, UInt32(MemoryLayout<Int8>.stride * MaxPathLen)) == 0 {
            return "unknown"
        }
        
        return String(cString: pathBuffer)
    }
    
    func getTimestamp(_ pidOfInterest: Int) -> Date {
        // Call proc_pidinfo and return current date on error
        let pidInfo = UnsafeMutablePointer<proc_bsdinfo>.allocate(capacity: 1)
        guard InfoSize == proc_pidinfo(Int32(pidOfInterest), PROC_PIDTBSDINFO, 0, pidInfo, InfoSize) else { return Date() }
        defer { pidInfo.deallocate() }
        
        return Date(timeIntervalSince1970: TimeInterval(pidInfo.pointee.pbi_start_tvsec))
    }
    
    func getNodeForPid(_ pidOfInterest: Int) -> Node? {
        for proc in processes {
            if proc.pid == pidOfInterest {
                return proc.node
            }
        }
        
        return nil
    }
}

extension ProcessCollector {
    func printTimeline(outputFile:String?) {
        for proc in processes {
            let text = "\(proc.timestamp)   \(proc.path)   \(proc.pid)"
            if let outputFile = outputFile {
                let fileUrl = URL(fileURLWithPath: outputFile)
                do {
                    try text.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print("Could not write TrueTree output to specified file")
                }
            }
            print("\(proc.timestamp)   \(proc.path)   \(proc.pid)")
        }
    }
}
