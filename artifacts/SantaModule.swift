import Foundation

public struct SantaStatus {
    public let version: String?
    public let status: String?
    public let exportedConfigPath: String?
    public let logFiles: [String]

    public init(version: String?, status: String?, exportedConfigPath: String?, logFiles: [String]) {
        self.version = version
        self.status = status
        self.exportedConfigPath = exportedConfigPath
        self.logFiles = logFiles
    }
}

public enum SantaError: Error {
    case executionFailed(String)
}

public final class SantaCollector {
    static func runCommand(_ arguments: [String]) -> (output: String?, exitCode: Int32) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments

        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = outPipe

        do {
            try process.run()
        } catch {
            return ("", -1)
        }

        process.waitUntilExit()
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        return (output?.trimmingCharacters(in: .whitespacesAndNewlines), process.terminationStatus)
    }

    public static func version() -> String? {
        let res = runCommand(["santactl", "version"]) // PATH lookup via /usr/bin/env; returns output if available
        return res.output
    }

    public static func status() -> String? {
        let res = runCommand(["santactl", "status"])
        return res.output
    }

    @discardableResult
    public static func exportConfiguration(to path: String) -> Bool {
        let res = runCommand(["santactl", "rule", "--export", path])
        return res.exitCode == 0
    }

    public static func listLogFiles(atPath path: String = "/var/db/santa") -> [String] {
        let fm = FileManager.default
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            return items.map { (path as NSString).appendingPathComponent($0) }
        } catch {
            return []
        }
    }

    public static func collect(exportConfigTo configPath: String? = nil) -> SantaStatus {
        let ver = version()
        let stat = status()
        var exportedPath: String? = nil
        if let p = configPath {
            if exportConfiguration(to: p) {
                exportedPath = p
            }
        }
        let logs = listLogFiles()
        return SantaStatus(version: ver, status: stat, exportedConfigPath: exportedPath, logFiles: logs)
    }
}
