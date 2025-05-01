Fuzzing, also known as fuzz testing, is a software testing technique that involves feeding a program with invalid, unexpected, or random data to identify potential vulnerabilities and security flaws. It's an automated process that helps uncover issues like memory corruption, crashes, and logic errors that could be exploited by attackers or during security assessments.

**ffuf** stands for **Fuzz Faster U Fool**. It's a tool used for web enumeration, fuzzing, and directory brute forcing.

### Commands
1. `ffuf -u http://10.10.90.40/FUZZ -w /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt`
2. `ffuf -u http://10.10.90.40/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-files-lowercase.txt`
3. `ffuf -u http://10.10.90.40/indexFUZZ -w /usr/share/wordlists/SecLists/Discovery/Web-Content/web-extensions.txt`

https://www.freecodecamp.org/news/web-security-fuzz-web-applications-using-ffuf/

