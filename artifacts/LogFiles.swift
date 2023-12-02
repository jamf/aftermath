//
//  LogFiles.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class LogFiles: ArtifactsModule {
    
    let logFilesDir: URL
    
    init(logFilesDir: URL) {
        self.logFilesDir = logFilesDir
    }
    
    func captureLogFiles() {
        
        // create raw directories
        let systemRawDir = self.createNewDir(dir: self.logFilesDir, dirname: "system_logs")
        let auditRawDir = self.createNewDir(dir: self.logFilesDir, dirname: "audit_logs")
        let aslRawDir = self.createNewDir(dir: self.logFilesDir, dirname: "asl_logs")
        
        let varLogPaths = ["/var/log/wifi.log", "/var/log/appfirewall.log", "/var/log/fsck_apfs.log", "/var/log/fsck_apfs_error.log", "/var/log/fsck_hfs.log", "/var/log/install.log", "/var/log/hdiejectd.log", "/var/log/apache2/access_log", "/var/log/apache2/error_log", "/var/log/system.log"]
        let auditLogs = filemanager.filesInDirRecursive(path: "/var/audit/")
        let aslLogs = filemanager.filesInDirRecursive(path: "/var/log/asl/")
                
        
        for file in varLogPaths {
            
            let filePath = URL(fileURLWithPath: file)
            if (filemanager.fileExists(atPath: filePath.path)) {
                self.copyFileToCase(fileToCopy: filePath, toLocation: systemRawDir)
            }
        }
        
        for auditLog in auditLogs {
            self.copyFileToCase(fileToCopy: auditLog, toLocation: auditRawDir)
        }
        
        for aslLog in aslLogs {
            if aslLog.pathExtension == "asl" {
                self.copyFileToCase(fileToCopy: aslLog, toLocation: aslRawDir)
            }
        }
    }
    
    func captureUserLogs() {
        let userLogsRawDir = self.createNewDir(dir: self.logFilesDir, dirname: "user_logs")
        
        for user in getBasicUsersOnSystem() {
            let paths = ["\(user.homedir)/Library/Logs/fsck_apfs.log", "\(user.homedir)/Library/Logs/fsck_hfs.log"]
            
            for p in paths {
                let filePath = URL(fileURLWithPath: p)
                if (filemanager.fileExists(atPath: filePath.path)) {
                    self.copyFileToCase(fileToCopy: filePath, toLocation: userLogsRawDir)
                } else { continue }
            }
        }
    }
    
    func collectDiagnosticsReports() {
        let diagReportsDir = self.createNewDir(dir: self.logFilesDir, dirname: "diagnostics_reports")

        let files = filemanager.filesInDirRecursive(path: "/Library/Logs/DiagnosticReports")
        for file in files {
            let filePath = URL(fileURLWithPath: file.relativePath)
            if (filemanager.fileExists(atPath: filePath.path)) {
                self.copyFileToCase(fileToCopy: filePath, toLocation: diagReportsDir)
            }
        }
        
        for user in getBasicUsersOnSystem() {
            let files = filemanager.filesInDirRecursive(path: "\(user.homedir)/Library/Logs/DiagnosticReports")
            for file in files {
                let filePath = URL(fileURLWithPath: file.relativePath)
                if (filemanager.fileExists(atPath: filePath.path)) {
                    self.copyFileToCase(fileToCopy: filePath, toLocation: diagReportsDir, newFileName: "\(user.username)_\(filePath.lastPathComponent)")
                }
            }
        }
    }
    
    func collectCrashReports() {
        let crashReportsDir = self.createNewDir(dir: self.logFilesDir, dirname: "crash_reporter")
        
        let files = filemanager.filesInDirRecursive(path: "/Library/Logs/CrashReporter")
        for file in files {
            let filePath = URL(fileURLWithPath: file.relativePath)
            if (filemanager.fileExists(atPath: filePath.path)) {
                self.copyFileToCase(fileToCopy: filePath, toLocation: crashReportsDir)
            }
        }
    }
    
    override func run() {
        captureLogFiles()
        captureUserLogs()
        collectDiagnosticsReports()
        collectCrashReports()
    }
}
