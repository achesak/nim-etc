# Nimrod module for parsing files in /etc/.

# Written by Adam Chesak.
# Released under the MIT open source license.


import strutils


type TEtcPasswd* = tuple[username : string, password : string, passwordEncrypted : bool, userID : int, groupID : int,
                      userInfo : string, homeDirectory : string, shell : string]

type TEtcGroup* = tuple[name : string, password : string, passwordEncrypted : bool, groupID : int, members : seq[string]]

type TEtcCrontab* = tuple[minute : string, hour : string, dayMonth : string, month : string, dayWeek : string, command : string]


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


proc readPasswd*(filename : string = "/etc/passwd"): seq[TEtcPasswd] = 
    ## Reads /etc/passwd, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[TEtcPasswd](len(r) - 1)
    
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        var s = r[i].split(':')
        var row : TEtcPasswd
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


proc readGroup*(filename : string = "/etc/group"): seq[TEtcGroup] = 
    ## Reads /etc/group, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[TEtcGroup](len(r) - 1)
    
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        var s = r[i].split(':')
        var row : TEtcGroup
        row.name = s[0]
        row.password = s[1]
        row.passwordEncrypted = s[1] == "x"
        row.groupID = parseInt(s[2])
        row.members = s[3].split(':')
        p[i] = row
    
    return p


proc readCrontab*(filename : string = "/etc/crontab"): seq[TEtcCrontab] = 
    ## Reads /etc/crontab, or the given file in the same format.
    
    var f : string = readFile(filename)
    var r = f.splitLines()
    var p = newSeq[TEtcCrontab](len(r) - 1)
    
    for i in 0..high(r):
        if r[i].strip() == "":
            continue
        if r[i].unindent().startsWith("#"):
            continue
        var s = r[i].split(' ').removeBlanks(6)
        var row : TEtcCrontab
        row.minute = s[0]
        row.hour = s[1]
        row.dayMonth = s[2]
        row.month = s[3]
        row.dayWeek = s[4]
        row.command = s[5]
        p[i] = row
    
    return p
    

#################################### ALSO PARSE: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#/etc/hosts
#/etc/hosts.allow
#/etc/hosts.deny
#/etc/fstab
#/etc/mtab
#/etc/shells
#/etc/securetty
#/etc/networks
#/etc/protocols
#/etc/services


var i = "         this                 is                    a                     test"
var k = i.split(' ')
k = removeBlanks(k, 4)
for i in k:
    echo(i)