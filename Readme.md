

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


# Aftermath
<logo>
## About
Aftermath is a  Swift-based, open-source incident response framework.

Aftermath can be leveraged by defenders in order to collect and subsequently analyze the data from the compromised host. Aftermath can be deployed from an MDM (ideally), but it can also run independently. 


## Usage
Aftermath needs to be root, as well as have full disk access (FDA) in order to run. FDA can be granted to the Terminal application in which it is running. If using an MDM to deploy Aftermath, FDA can be granted through PPPC in your MDM solution.

The default usage of Aftermath runs 
```bash
./Aftermath
```
To specify certain options
```bash
./Aftermath [option1] [option2]
```
Example
```bash
./Aftermath -o /Users/user/Desktop --deep
```

## Help Menu

```bash
-o -> specify an output location for Aftermath results
     usage: -o Users/user/Desktop
--analyze -> Analyze the results of the Aftermath results
     usage: --analyze <path_to_file>
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
