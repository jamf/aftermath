# Aftermath

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
Aftermath needs to be root, as well as have *full disk access (FDA)* in order to run. FDA can be granted to the Terminal application in which it is running. If using an MDM to deploy Aftermath, FDA can be granted through PPPC in your MDM solution.

The default usage of Aftermath runs 
```bash
sudo ./aftermath
```
To specify certain options
```bash
sudo ./aftermath [option1] [option2]
```
Example
```bash
sudo ./aftermath -o /Users/user/Desktop --deep
```
```bash
sudo ./aftermath --analyze <path_to_collection_zip>
```

## Help Menu

```
-o or --output -> specify an output location for Aftermath collection results (defaults to /tmp)
     usage: -o Users/user/Desktop
--analyze -> Analyze the results of the Aftermath results
     usage: --analyze <path_to_aftermath_collection_file>
--cleanup -> Remove Aftermath Response Folders
--deep or -d -> Perform a deep scan of the file system for modified and accessed timestamped metadata
    WARNING: This will be a time-intensive, memory-consuming scan.
```

## Contributors
- Stuart Ashenbrenner
- Jaron Bradley
- Maggie Zirnhelt
- Matt Benyo
- Ferdous Saljooki

## Thank You
This project leverages the open source [TrueTree](https://github.com/themittenmac/TrueTree) project, written by Jaron Bradley. 
