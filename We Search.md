When performing a web directory search (also known as directory brute-forcing or directory enumeration), the goal is to find hidden or unlinked directories and files on a web server. The best tools for this task are:

⸻

🔧 1. Dirb

Overview: Simple and effective directory brute-forcing tool using wordlists.

Command:

dirb http://target.com/

With custom wordlist:

dirb http://target.com/ /path/to/wordlist.txt



⸻

🔧 2. Gobuster (Fast and modern, written in Go)

Overview: Faster and more flexible than Dirb; supports directory and DNS fuzzing.

Install:

sudo apt install gobuster

Command:

gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt

Options:
	•	-u: Target URL
	•	-w: Wordlist
	•	-t: Number of threads (optional, e.g., -t 50)

⸻

🔧 3. Dirsearch

Overview: Python-based, very customizable, supports recursive brute-forcing.

Clone & run:

git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch
python3 dirsearch.py -u http://target.com -e php,html,txt

Options:
	•	-e: File extensions to search for
	•	-w: Use a custom wordlist

⸻

🔧 4. FFUF (Fuzz Faster U Fool)

Overview: Very fast and modern tool for fuzzing files/directories.

Command:

ffuf -u http://target.com/FUZZ -w /usr/share/wordlists/dirb/common.txt

Options:
	•	-u: URL with FUZZ as the injection point
	•	-w: Wordlist

⸻

🔧 5. Wfuzz (Powerful, but slightly more complex)

Command:

wfuzz -c -w /usr/share/wordlists/dirb/common.txt --hc 404 http://target.com/FUZZ

Options:
	•	--hc 404: Hide 404 responses

⸻

✅ Best Tool Recommendation
	•	For beginners: Use Dirb or Gobuster
	•	For speed and flexibility: Use Gobuster or FFUF
	•	For recursive or extension-specific searches: Use Dirsearch

Would you like a comparison table or guidance on how to interpret the results?