**Gobuster Scan on website**
```shell
gobuster dir -u <Target_URL> -w <Wordlist> -x <Extension_Files_To_Look>
```

**Nikto**
```Shell
nikto -h <TargetIP_or_Domain>
```

**Zip File Cracking**
```Shell
fcrackzip -v -u -D -p rockyou.txt <File>
```

**Dirb**
*Normal Website scanning*
```Shell
dirb http://target.com <Wordlist_Path> -X <Extensions> -o <Save_Output>
```

**Python Script to get a shell**
```Python
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

```Python
python3 -c 'import os;os.system("/bin/bash")'
```

**Imp Links**
https://blog.syselement.com/ine/courses/ejpt
https://github.com/NoorQureshi/kali-linux-cheatsheet

