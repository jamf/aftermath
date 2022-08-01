# Aftermath
<logo>
## About
Aftermath is a  Swift-based, open-source incident response framework.

Aftermath can be leveraged by defenders in order to collect and subsequently analyze the data from the compromised host. Aftermath can be deployed from an MDM (ideally), but it can also run independently from the infected user's command line. 

Results of Aftermath will be compressed into a zip archive. To unzip the archived files, run
```bash
unzip <path_to_aftermath_directory>
```


## Build
To build Aftermath locally, clone it from the repository
```bash
git clone https://github.com/jamf/aftermath.git
```
`cd` into the Aftermath directory
```bash
cd <path_to_aftermath_directory>
```
Build using XCode
```bash
xcodebuild
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
Aftermath needs to be root, as well as have full disk access (FDA) in order to run. FDA can be granted to the Terminal application in which it is running. If using an MDM to deploy Aftermath, FDA can be granted through PPPC in your MDM solution.

The default usage of Aftermath runs 
```bash
./aftermath
```
To specify certain options
```bash
./aftermath [option1] [option2]
```
Example
```bash
./aftermath -o /Users/user/Desktop --deep
```

## Help Menu

```bash
-o -> specify an output location for Aftermath collection results
     usage: -o Users/user/Desktop
--analyze -> Analyze the results of the Aftermath results
     usage: --analyze <path_to_aftermath_collection_file>
--cleanup -> Remove Aftermath Response Folders
--deep -> Perform a deep scan of the file system for modified and accessed timestamped metadata
    WARNING: This will be a time-intensive scan.
```

## Contributors
- Stuart Ashenbrenner
- Matt Benyo
- Jaron Bradley
- Ferdous Saljooki

## Thank You
This project leverages the open source [TrueTree](https://github.com/themittenmac/TrueTree) project, written by Jaron Bradley. 
