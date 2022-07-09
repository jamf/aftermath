//
//  tree.swift
//  aftermath
//
// The following code (with minor modifications) is from TrueTree, written by Jaron Bradley.
//  2020 TheMittenMac
// TrueTree: https://github.com/themittenmac/TrueTree
// Inspired by https://www.journaldev.com/21383/swift-tree-binary-tree-data-structure


import Foundation
import LaunchdXPC


class Node<T> {
    var pid: T
    var ppid: UInt32
    weak var parent: Node?
    var procPath: String
    var responsiblePid: CInt
    var timestamp: Date
    var submittedByPlist: String?
    var submittedByPid: Int?
    var launchdProgramPath: String?
    var children: [Node] = []
    var source: String?
    
    init(_ pid: T, ppid: UInt32, procPath: String, responsiblePid: CInt, timestamp: Date) {
        self.pid = pid
        self.ppid = ppid
        self.procPath = procPath
        self.responsiblePid = responsiblePid
        self.timestamp = timestamp
    }
    
    func printNodeData() -> [String] {
        var val: String
        
            if self.procPath.hasSuffix(".plist") {
                val = "\u{001B}[0;34m\(self.procPath)\u{001B}[0;0m"
            } else if self.procPath.hasSuffix("Terminated)") {
                val = "\u{001B}[0;31m\(self.procPath)\u{001B}[0;0m"
            } else if self.procPath.hasSuffix("(Exec'ed into below process)") {
                val = "\u{001B}[0;33m\(self.procPath)   \(self.pid)\u{001B}[0;0m"
            } else {
                val = "\(self.procPath)   \u{001B}[0;35m\(self.pid)\u{001B}[0;0m"
            
                val += "   \u{001B}[0;36m\(self.timestamp)\u{001B}[0;0m"
            
           
                if let source = self.source {
                    val += "   \u{001B}[0;31m\(source)\u{001B}[0;0m"
                }
                
            }
    
            return [val] + self.children.flatMap{$0.printNodeData()}.map{"    "+$0}
    }
    
    func printTree(_ toFile: URL?) {
        let text = printNodeData().joined(separator: "\n")
        if let toFile = toFile {
            
            do {
                try text.write(to: toFile, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Could not write TrueTree output to specified file")
            }
        } else {
            let text = printNodeData().joined(separator: "\n")
            print(text)
        }
    }
}


class Tree {
    func buildStandardTree(_ nodePidDict:[Int:Node<Any>]) -> Node<Any> {
        // Builds a tree using standard unix pids and ppids
        for (_, node) in nodePidDict {
            let ppid = Int(node.ppid)
            if let parentNode = nodePidDict[ppid] {
                parentNode.children.append(node)
            }
        }
        
        guard let rootNode = nodePidDict[1] else {
            exit(1)
        }
        
        return rootNode
    }


    func buildTrueTree(_ nodePidDict:[Int:Node<Any>]) -> Node<Any> {
        // Empty dictionary to hold plist items
        var nodePlistDict = [String:Node<Any>]()
        
        // Builds a tree based on the TrueTree concept and returns the root node
        for (pid, node) in nodePidDict {
            if pid == 1 {
                continue
            }
            // If a plist was responsible for the creation of a process add the plist as a node entry
            // Pids don't matter as we will only reference the procPath
            if let submittedByPlist = node.submittedByPlist {
                if nodePlistDict[submittedByPlist] == nil {
                    let plistNode = Node<Any>(-1, ppid:1, procPath:submittedByPlist, responsiblePid:-1, timestamp: Date())
                    nodePlistDict[submittedByPlist] = plistNode
                    
                    // Assign this plist as a child node to launchd
                    nodePidDict[1]?.children.append(plistNode)
                }
            }
            
            var trueParentPid:Int?
            var trueParentPlist:String?
            var source: String?
            trueParentPlist = nil
            
            // Find the pid (or plist) we should use as the parent
            if let submittedByPlist = node.submittedByPlist {
                trueParentPlist = submittedByPlist
                source = "Aquired parent from -> launchd_xpc"
            } else if let submittedByPid = node.submittedByPid {
                if nodePidDict.keys.contains(submittedByPid) {
                    trueParentPid = submittedByPid
                    source = "Aquired parent from -> Application_Services"
                } else {
                    trueParentPid = Int(node.ppid)
                }

            } else if let submittedByPlist = node.submittedByPlist {
                trueParentPlist = submittedByPlist
                source = "Aquired parent from -> submitted_by_plist"
            } else if node.responsiblePid != pid {
                trueParentPid = Int(node.responsiblePid)
                source = "Aquired parent from -> responsible_pid"
            } else {
                trueParentPid = Int(node.ppid)
                source = "Aquired parent from -> parent_process_id"
            }
            
            node.source = source
                
            var parentNode: Node<Any>?
            // Grab the parent of this node and assign this node as a child to it
            if let trueParentPid = trueParentPid {
                parentNode = nodePidDict[trueParentPid]
            } else if let trueParentPlist = trueParentPlist {
                parentNode = nodePlistDict[trueParentPlist]
            }
            
            parentNode?.children.append(node)
        }
        
        guard let rootNode = nodePidDict[1] else {
            exit(1)
        }
        
        return rootNode
    }


    func createNodeDictionary() -> [Int:Node<Any>] {
        
        let pids = Pids()
        
        var nodePidDict = [Int:Node<Any>]()
        
        // Go through each pid and create an initial tree node for it with all of the pid info we can find
        for pid in pids.getActivePids() {
            // Skip kernel pid as we won't be able to collect info on it
            if pid == 0 {
               continue
            }
            
            // Create the tree node
            let p = UnsafeMutablePointer<proc_bsdinfo>.allocate(capacity: 1)
            guard let ppid = pids.getPPID(pid, pidInfo: p) else {
                print("Issue collecting pid information for \(pid). Skipping...")
                continue
            }
            
            let responsiblePid = pids.getResponsiblePid(pid)
            let path = pids.getPidPath(pid)
            let ts = pids.getTimestamp(pid, pidInfo: p)
            
            defer { p.deallocate() }
            
            let node = Node<Any>(pid as Any, ppid:ppid, procPath:path, responsiblePid: responsiblePid, timestamp: ts)
            
            let submitted = getSubmittedPid(Int32(pid))
            if submitted != 0 {
                node.submittedByPid = Int(submitted)
            }
            
            if let launchctlPlist = getSubmittedByPlist(UInt(pid)) {
                if launchctlPlist.hasSuffix(".plist") {
                    node.submittedByPlist = launchctlPlist
                }
            }
            
            nodePidDict[pid] = node
        }
        
        return nodePidDict
    }
}
