//
//  FilePermissions.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 8/17/22.
//

import Foundation

class FilePermissions {
    
    
    func getFilePermissions(fromFile: URL) -> Int? {
        
        return Int(String(mode(for: fromFile).rawValue, radix: 8))
    }
    
    private func mode(for path: URL) -> FileMode {
        return path.path.withCString { cs in
            var status = stat()
            stat(cs, &status)
            return FileMode(rawValue: status.st_mode)
        }
    }
}



struct FileMode: OptionSet {
    let rawValue: mode_t
    init(rawValue: mode_t) {
        self.rawValue = rawValue
    }
    
    static let userAll = FileMode(rawValue: S_IRWXU) /* RWX mask for owner */
    static let userRead = FileMode(rawValue: S_IRUSR) /* R for owner */
    static let userWrite = FileMode(rawValue: S_IWUSR) /* W for owner */
    static let userExecute = FileMode(rawValue: S_IXUSR) /* X for owner */

    static let groupAll = FileMode(rawValue: S_IRWXG) /* RWX mask for group */
    static let groupRead = FileMode(rawValue: S_IRGRP) /* R for group */
    static let groupWrite = FileMode(rawValue: S_IWGRP) /* W for group */
    static let groupExecute = FileMode(rawValue: S_IXGRP) /* X for group */

    static let otherAll = FileMode(rawValue: S_IRWXO) /* RWX mask for other */
    static let otherRead = FileMode(rawValue: S_IROTH) /* R for other */
    static let otherWrite = FileMode(rawValue: S_IWOTH) /* W for other */
    static let otherExecute = FileMode(rawValue: S_IXOTH) /* X for other */

    static let setUserIdOnExe = FileMode(rawValue: S_ISUID) /* set user id on execution */
    static let setGroupIdOnExe = FileMode(rawValue: S_ISGID) /* set group id on execution */
    static let saveSwappedTextAfterUse = FileMode(rawValue: S_ISVTX) /* save swapped text even after use */
}
