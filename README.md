
![](https://github.com/jamf/aftermath/blob/main/AftermathLogo.png)


![](https://img.shields.io/badge/release-2.2.1-bright%20green)&nbsp;![](https://img.shields.io/badge/macOS-12.0%2B-blue)&nbsp;![](https://img.shields.io/badge/license-MIT-orange)


## About
Aftermath is a  Swift-based, open-source incident response framework.

Aftermath can be leveraged by defenders in order to collect and subsequently analyze the data from the compromised host. Aftermath can be deployed from an MDM (ideally), but it can also run independently from the infected user's command line. 

Aftermath first runs a series of modules for collection. The output of this will either be written to the location of your choice, via the `-o` or `--output` option, or by default, it is written to the `/tmp` directory.

Once collection is complete, the final zip/archive file can be pulled from the end user's disk. This file can then be analyzed using the `--analyze` argument pointed at the archive file. The results of this will be written to the `/tmp` directory. The administrator can then unzip that analysis directory and see a parsed view of the locally collected databases, a timeline of files with the file creation, last accessed, and last modified dates (if they're available), and a storyline which includes the file metadata, database changes, and browser information to potentially track down the infection vector.


## Build
To build Aftermath locally, clone it from the repository
```bash
git clone https://github.com/jamf/aftermath.git
```
`cd` into the Aftermath directory
```bash
cd <path_to_aftermath_directory>
```
Build using Xcode
```bash
xcodebuild -scheme "aftermath"
``` 
`cd` into the Release folder
```bash
cd build/Release
```
Run aftermath
```bash
sudo ./aftermath
```

## Usage
Aftermath needs to be root, as well as have *full disk access (FDA)* in order to run. FDA can be granted to the Terminal application in which it is running.

The default usage of Aftermath runs 
```bash
sudo ./aftermath
```
To specify certain options
```bash
sudo ./aftermath [option1] [option2]
```
Examples
```bash
sudo ./aftermath -o /Users/user/Desktop --deep
```
```bash
sudo ./aftermath --analyze <path_to_collection_zip>
```

### External Unified Log Predicates
Users have the ability to pass Aftermath a text file of unified log predicates using the `--logs` or `-l` arguments. The file being passed to Aftermath is required to be a text file and each predicate needs to be newline-separated. In addition, each line item will be a dictionary object. The key in the dictionary will whatever the user desires to call this predicate. For example, if you want to see all login events, we will create a predicate and title it `login_events`.
```
login_events: processImagePath contains "loginwindow" and eventMessage contains "com.apple.sessionDidLogin
tcc: process == "tccd"
```

### Note
Because `eslogger` and `tcpdump` run on additional threads and the goal is to collect as much data from them as possible, they exit when aftermath exits. Because of this, the last line of the eslogger json file or the pcap file generated from tcpdump may be truncated.

### File Collection List
- Artifacts
    - Configuration Profiles
    - Log Files
    - LSQuarantine Database
    - Shell History and Profiles (bash, csh, fish, ksh, zsh)
    - TCC Database
    - XBS Database (XProtect Behabioral Service)
- Filesystem
    - Browser Data (Cookies, Downloads, Extensions, History)
        - Arc
        - Brave
        - Chrome
        - Edge
        - Firefox
        - Safari
    - File Data
        - Walk common directories to get accessed, birth, modified timestamps
    - Slack
- Network
    - Active network connections
    - Airport Preferences
- Persistence
    - BTM Database
    - Cron
    - Emond
    - Launch Items
        - Launch Agents
        - Launch Daemons
    - Login Hooks
    - Login Items
    - Overrides
        - launchd Overrides
        - MDM Overrides
    - Periodic Scripts
    - System Extensions
- Processes
    - Leverage [TrueTree](https://github.com/themittenmac/TrueTree) to create process tree 
- System Recon
    - Environment Variables
    - Install History
    - Installed Applications
    - Installed Users
    - Interfaces
    - MRT Version
    - Running Applications
    - Security Assessment (SIP status, Gatekeeper status, Firewall status, Filevault status, Remote Login, Airdrop status, I/O statistics, Screensharing status, Login History, Network Interface Parameters)
    - XProtect Version
    - XProtect Remediator (XPR) Version
- Unified Logs
    - Default Unified Logs (failed_sudo, login, manual_configuration_profile_install, screensharing, ssh, tcc, xprotect_remediator)
    - Additional can be passed in at runtime

## Releases
There is an Aftermath.pkg available under [Releases](https://github.com/jamf/aftermath/releases). This pkg is signed and notarized. It will install the aftermath binary at `/usr/local/bin/`. This would be the ideal way to deploy via MDM. Since this is installed in `bin`, you can then run aftermath like
```bash
sudo aftermath [option1] [option2]
```

## Uninstall
To uninstall the aftermath binary, run the `AftermathUninstaller.pkg` from the [Releases](https://github.com/jamf/aftermath/releases). This will uninstall the binary and also run `aftermath --cleanup` to remove aftermath directories. If any aftermath directories reside elsewhere, from using the `--output` command, it is the responsibility of the user/admin to remove said directories.

## Help Menu

```
--analyze -> analyze the results of the Aftermath results
     usage: --analyze <path_to_aftermath_collection_file>
--collect-dirs -> specify locations of (space-separated) directories to dump those raw files
    usage: --collect-dirs <path_to_dir> <path_to_another_dir>
--deep or -d -> perform a deep scan of the file system for modified and accessed timestamped metadata
    WARNING: This will be a time-intensive, memory-consuming scan.
--disable -> disable a set of aftermath features that may collect personal user data
    Available features to disable: browsers -> collecting browser information | browser-killswitch -> force-closes browers | -> databases -> tcc & lsquarantine databases | filesystem -> walking the filesystem for timestamps | proc-info -> collecting process information via TrueTree and eslogger | slack -> slack data | ul -> unified logging modules | all -> all aforementioned options 
    usage: --disable browsers browser-killswitch databases filesystem proc-info slack
           --disable all
--es-logs -> specify which Endpoint Security events (space-separated) to collect (defaults are: create exec mmap). To disable, see --disable es-logs
    usage: --es-logs setuid unmount write
--logs -> specify an external text file with unified log predicates (as dictionary objects) to parse
    usage: --logs /Users/<USER>/Desktop/myPredicates.txt
-o or --output -> specify an output location for Aftermath collection results (defaults to /tmp)
     usage: -o Users/user/Desktop
--pretty -> colorize Terminal output
--cleanup -> remove Aftermath folders from default locations ("/tmp", "/var/folders/zz/) 
```

## Contributors
- Stuart Ashenbrenner
- Jaron Bradley
- Maggie Zirnhelt
- Matt Benyo
- Ferdous Saljooki

## Thank You
This project leverages the open source [TrueTree](https://github.com/themittenmac/TrueTree) project, written and [licensed](https://github.com/themittenmac/TrueTree/blob/master/license.md) by Jaron Bradley. 
