# Nimrod module for parsing files in /etc/.

# Written by Adam Chesak.
# Released under the MIT open source license.


import strutils


type
    EtcPasswd* = ref object
        username* : string
        password* : string
        passwordEncrypted* : bool
        userID* : int
        groupID* : int
        userInfo* : string
        homeDirectory* : string
        shell* : string

    EtcGroup* = ref object
        name* : string
        password* : string
        passwordEncrypted* : bool
        groupID* : int
        members* : seq[string]

    EtcCrontab* = ref object 
        minute* : string
        hour* : string
        dayMonth* : string
        month* : string
        dayWeek* : string
        command* : string
        special* : bool
        specialValue* : string

    EtcFstab* = ref object 
        fileSystem* : string
        directory* : string
        fsType: string
        options* : seq[string]
        dump* : int
        pass* : int


proc removeBlanks(s : seq[string], length : int): seq[string] = 
    ## Removes all blanks from s and returns a new seq of specified length.
    ## Used to get rid of spacing.
    
    var n = newSeq[string](length)
    var c : int = 0
    for i in s:
        if i != " " and i != "":
            n[c] = i
            c += 1
        if c == length:
            break
    return n


proc readPasswd*(filename : string = "/etc/passwd"): seq[EtcPasswd] = 
    ## Reads /etc/passwd, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[EtcPasswd](len(r) - 1)
    
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        var s = r[i].split(':')
        var row : EtcPasswd
        row.username = s[0]
        row.password = s[1]
        row.passwordEncrypted = s[1] == "x"
        row.userID = parseInt(s[2])
        row.groupID = parseInt(s[3])
        row.userInfo = s[4]
        row.homeDirectory = s[5]
        row.shell = s[6]
        p[i] = row
    
    return p


proc readGroup*(filename : string = "/etc/group"): seq[EtcGroup] = 
    ## Reads /etc/group, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[EtcGroup](len(r) - 1)
    
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        var s = r[i].split(':')
        var row : EtcGroup
        row.name = s[0]
        row.password = s[1]
        row.passwordEncrypted = s[1] == "x"
        row.groupID = parseInt(s[2])
        row.members = s[3].split(',')
        p[i] = row
    
    return p


proc readCrontab*(filename : string = "/etc/crontab"): seq[EtcCrontab] = 
    ## Reads /etc/crontab, or the given file in the same format.
    ##
    ## Returned sequence may be longer than the total number of commands.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[EtcCrontab](len(r) - 1)
    
    var c : int = 0
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        if r[i].unindent().startsWith("#"):
            continue
        var s = r[i].split(' ').removeBlanks(6)
        var row : EtcCrontab
        if s[0].startsWith("@"):
            row.special = true
            row.specialValue = s[0]
            row.command = s[1]
        else:
            row.special = false
            row.minute = s[0]
            row.hour = s[1]
            row.dayMonth = s[2]
            row.month = s[3]
            row.dayWeek = s[4]
            row.command = s[5]
        p[c] = row
        c += 1
    
    return p


proc readShells*(filename : string = "/etc/shells"): seq[string] = 
    ## Reads /etc/shells, or the given file in the same format.
    ##
    ## Returned sequence may be longer than the total number of shells.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[string](len(r) - 1)
    
    var c : int = 0
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        if r[i].unindent().startsWith("#"):
            continue
        p[c] = r[i]
        c += 1
    
    return p


proc readFstab*(filename : string = "/etc/fstab"): seq[EtcFstab] = 
    ## Reads /etc/fstab, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[EtcFstab](len(r) - 1)
    
    var c : int = 0
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        if r[i].unindent().startsWith("#"):
            continue
        var s = r[i].split(' ').removeBlanks(6)
        var row : EtcFstab
        row.fileSystem = s[0]
        row.directory = s[1]
        row.fsType = s[2]
        row.options = s[3].split(',')
        row.dump = parseInt(s[4])
        row.pass = parseInt(s[5])
        p[c] = row
        c += 1
    
    return p


proc readMtab*(filename : string = "/etc/mtab"): seq[EtcFstab] =
    ## Reads /etc/mtab, or the given file in the same format.
    
    return readFstab("/etc/mtab")


proc readHosts*(filename : string = "/etc/hosts"): seq[seq[string]] = 
    ## Reads /etc/hosts, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[seq[string]](len(r) - 1)
    
    var c : int = 0
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        if r[i].unindent().startsWith("#"):
            continue
        var s = r[i].split(' ').removeBlanks(3)
        p[c] = s
        c += 1
    
    return p
