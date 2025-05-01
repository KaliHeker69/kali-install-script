**Hashcat Cheatsheet**

Hashcat is a powerful password recovery tool. It primarily uses the GPU for speed.

**Disclaimer:** Use Hashcat ethically and legally. Cracking passwords of systems you do not own or have explicit permission to test is illegal.

> [!Imp]
> VirtualBox does not support GPU passthrough so only CPU mode will work in it. Always use `-D 1` for cpu mode.
> ```bash
hashcat -D 1 -m [hash-mode] [hash-file] [wordlist]

---

**1. Basic Syntax**

The fundamental structure of a Hashcat command is:

```bash
hashcat [options] [hashfile] [input_files or mask]
```

*   `[options]`: Controls how Hashcat runs (attack mode, hash type, rules, session, etc.)
*   `[hashfile]`: The file containing the hashes you want to crack (usually one hash per line).
*   `[input_files or mask]`: Dictionaries, rule files, or a mask definition, depending on the attack mode.

---

**2. Key Concepts**

*   **Hash Type (`-m <number>`):** Specifies the type of hash you are trying to crack. This is **crucial**.
    *   Find hash types: Run `hashcat --help` or `hashcat -m`. You'll see a long list with numbers.
    *   Examples:
        *   `-m 0`: MD5
        *   `-m 100`: SHA1
        *   `-m 1000`: NTLM
        *   `-m 22000`: WPA/WPA2/PSK (often needs handshake files converted with `cap2hccapx` or `hcxpcapngtool`)
        *   `-m 2500`: WPA-Enterprise (RADIUS)
        *   `-m 5600`: MySQL323
        *   `-m 11000`: DCC2 (Django)
        *   `-m 13100`: Kerberos 5, etype 23
        *   `-m 1800`: SHA512crypt (Linux)
        *   `-m 7100`: SHA256crypt (Linux)
        *   `-m 3000`: LM

*   **Attack Mode (`-a <number>`):** Specifies the cracking technique.
    *   `-a 0`: **Dictionary Attack** (using wordlists)
    *   `-a 1`: **Combinator Attack** (combining two wordlists)
    *   `-a 2`: **Brute-force** (deprecated, use -a 3)
    *   `-a 3`: **Mask Attack** (defining character sets and lengths, true brute-force)
    *   `-a 6`: **Hybrid Attack (Dictionary + Mask)** (e.g., `password` + `123`)
    *   `-a 7`: **Hybrid Attack (Mask + Dictionary)** (e.g., `123` + `password`)

*   **Hash File Format:** Usually one hash per line. For some types (like WPA), special formats are needed (e.g., `.hccapx`, `.hc22000` converted from handshakes).

*   **Input Files:**
    *   `wordlist.txt`: Standard dictionary file for `-a 0`, `-a 1`, `-a 6`, `-a 7`.
    *   `rules.rule`: Rule file for modifying dictionary words (used with `-r`).
    *   `mask`: String defining the brute-force pattern for `-a 3`, `-a 6`, `-a 7`.

---

**3. Mask Attack Symbols (`-a 3`)**

Used to define character sets for brute-force attacks.

| Symbol | Description                                  | Example                               |
| :----- | :------------------------------------------- | :------------------------------------ |
| `?l`   | lowercase alphabet (`abcdefghijklmnopqrstuvwxyz`) | `?l?l?l?l` (4 lowercase letters)    |
| `?u`   | uppercase alphabet (`ABCDEFGHIJKLMNOPQRSTUVWXYZ`) | `?u?u?u?u` (4 uppercase letters)    |
| `?d`   | digits (`0123456789`)                        | `?d?d?d?d` (4 digits)               |
| `?s`   | special characters (`!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~`) | `?s?s` (2 special characters)     |
| `?a`   | all printable ASCII (`?l?u?d?s`)              | `?a?a?a?a` (4 any printable ASCII)  |
| `?h`   | lower-half of a hex-charset (`0123456789abcdef`) | `?h?h?h?h` (4 lowercase hex)        |
| `?H`   | upper-half of a hex-charset (`0123456789ABCDEF`) | `?H?H?H?H` (4 uppercase hex)        |
| `?b`   | All 8-bit characters (`0x00 - 0xff`)         | `?b?b`                                |

**Custom Charsets:** Define your own sets using `--charset` or directly in the mask.

```bash
hashcat -a 3 -m 0 hash.txt --charset=123,!@# ?1?1?1?1?2?2
# Uses '?1' for '123' and '?2' for ',!@#'
```

Or inline (newer Hashcat versions):

```bash
hashcat -a 3 -m 0 hash.txt ?l?d -1 aeiou -2 135 ?1?2?d?d
# ?1 = aeiou, ?2 = 135
```

---

**4. Common Attack Examples**

*   **Dictionary Attack (`-a 0`)**
    ```bash
    hashcat -a 0 -m 0 hash.txt rockyou.txt
    # Crack MD5 hashes in hash.txt using rockyou.txt
    ```

*   **Dictionary Attack with Rules (`-a 0 -r`)**
    ```bash
    hashcat -a 0 -m 1000 ntlm_hashes.txt passwords.txt -r rules/best64.rule
    # Crack NTLM hashes using passwords.txt mutated by best64.rule
    ```

*   **Combinator Attack (`-a 1`)**
    ```bash
    hashcat -a 1 -m 0 hash.txt dictionary1.txt dictionary2.txt
    # Crack MD5 by combining every word from dictionary1 with every word from dictionary2
    ```

*   **Mask Attack (`-a 3`)**
    ```bash
    hashcat -a 3 -m 1000 ntlm_hashes.txt ?l?l?l?l?d?d?d?d
    # Crack NTLM using 8-character mask: 4 lowercase letters followed by 4 digits
    ```
    *   **Incrementing Mask Length:** Use `--increment` for variable lengths.
        ```bash
        hashcat -a 3 -m 0 hash.txt ?d?d?d?d?d?d --increment --increment-min 4 --increment-max 8
        # Crack MD5 hashes using masks of only digits, starting from 4 digits up to 8 digits
        ```

*   **Hybrid Attack (Dictionary + Mask, `-a 6`)**
    ```bash
    hashcat -a 6 -m 100 ntlm_hashes.txt passwords.txt ?d?d?d
    # Crack NTLM by appending 3 digits (?d?d?d) to each word in passwords.txt (e.g., password123)
    ```

*   **Hybrid Attack (Mask + Dictionary, `-a 7`)**
    ```bash
    hashcat -a 7 -m 100 ntlm_hashes.txt ?u?l passwords.txt
    # Crack NTLM by prepending 1 uppercase and 1 lowercase letter (?u?l) to each word in passwords.txt (e.g., Abpassword)
    ```

---

**5. Important Options**

*   **Hardware/Performance:**
    *   `-d <devices>`: Specify devices to use (e.g., `-d 1` for device 1, `-d 1,2` for devices 1 and 2).
    *   `-w <level>`: Workload profile (1-4). 3 (default) balances speed and responsiveness. 4 is fastest but less responsive.
    *   `--benchmark`: Run benchmarks for supported hash types on your hardware.
    *   `--force`: Disable driver/runtime error checking. Use with caution! Required for WSL, sometimes needed for certain drivers.
    *   `-S`: Skip self-test. Use if `--force` is not enough.

*   **Session Management:**
    *   `-s <num>`: Skip the first `<num>` candidates. Useful for manual resume.
    *   `-l <num>`: Limit the cracking process to the first `<num>` candidates.
    *   `--session <name>`: Give the session a name. Hashcat saves progress (checkpoint) under this name in `hashcat.potfile` and session files.
    *   `--status`: Show real-time cracking status. Use `s` key during cracking.
    *   `--status-timer <seconds>`: Automatically show status every X seconds.
    *   `--runtime <seconds>`: Stop cracking after X seconds.

*   **Output & Results:**
    *   `--outfile <file>`: Write cracked hashes (hash:password) to this file.
    *   `--outfile-format <num>`: Format of the output file (0=hash:plain, 1=hash, 2=plain, etc.). `2` is common if you *only* want the cracked passwords.
    *   `--show`: Show cracked hashes from the potfile for the given hash file and hash type.
    *   `--left`: Show *uncracked* hashes from the hash file (compares against the potfile).
    *   `--potfile-disable`: Do not use or write to the potfile. Generally not recommended as it's crucial for resume and showing results.
    *   `--remove`: Remove the hash from the hash file after it's cracked (uses the potfile implicitly).

*   **Cracking Options:**
    *   `-r <file>`: Load rules from a file.
    *   `--optimized-kernel`: Use optimized kernels (default). Use `--keep-guessing` if you suspect hashes are salted inconsistently.
    *   `--stdout`: Print candidate passwords to stdout instead of cracking (useful for testing masks/rules or piping).

*   **Hash File Options:**
    *   `--username`: Assume the hash file includes usernames (e.g., `user:hash`). Useful for some hash types (`-m 1000`).

---

**6. Utility Commands**

*   `hashcat --help`: Display help and list all options.
*   `hashcat -m <number>`: Display help specifically for a hash type, including its expected format.
*   `hashcat --benchmark`: Benchmark your hardware.
*   `hashcat --show -m <type> <hashfile>`: Show already cracked hashes from the potfile for a specific hash file and type.
*   `hashcat --left -m <type> <hashfile>`: Show hashes that *haven't* been cracked yet.

---

**7. Workflow Tips**

1.  **Identify the Hash Type:** Use online tools or recognize formats (`-m <number>`).
2.  **Choose an Attack Mode:** Dictionary is usually fastest, then Hybrid, then Mask.
3.  **Get Good Input:** Use reputable dictionaries (`rockyou.txt`, etc.), potent rule files (`hashcat-rules`), or craft intelligent masks.
4.  **Start with a Dictionary + Rules:** This is often the most efficient first step.
    ```bash
    hashcat -a 0 -m <type> hashes.txt dictionary.txt -r rules/best64.rule --session my_crack
    ```
5.  **If not cracked, try Hybrid:** Combine dictionary with numbers or symbols.
    ```bash
    hashcat -a 6 -m <type> hashes.txt dictionary.txt ?d?d?d --session my_crack_hybrid
    ```
6.  **Try Intelligent Masks:** Based on common patterns (e.g., CompanyYYYY!, NameYear, known password policies). Start with shorter masks and increment.
    ```bash
    hashcat -a 3 -m <type> hashes.txt ?l?l?l?l?d?d --increment --increment-min 4 --increment-max 8 --session my_crack_mask
    ```
7.  **Use Sessions:** Always use `--session` to easily pause, resume, and manage multiple tasks.
    *   To resume: `hashcat --session <name>` (Hashcat will pick up where it left off automatically).
8.  **Check Results:** After a session finishes or is paused, use `--show`.
    ```bash
    hashcat --show -m <type> hashes.txt
    ```
9.  **Use `--remove`:** If you have a large hash file and want subsequent attacks to only target the remaining uncracked hashes. Add `--remove` to your cracking command.

---
Okay, here is a detailed guide on how to crack hashes found in the `/etc/shadow` file using Hashcat.

**Understanding `/etc/shadow` Hashes**

The `/etc/shadow` file stores password hashes and related information for local users on a Linux/Unix system. The hashes are typically salted and use modern, strong algorithms. The format of each line is usually:

`username:password_hash:last_changed:minimum_days:maximum_days:warning_days:inactive_days:expiry_date:`

We are primarily interested in the `username` and `password_hash` fields.

**Important Considerations and Warnings:**

1.  **Permissions:** The `/etc/shadow` file is only readable by the `root` user. You need root privileges (or the file obtained through other means) to access its contents.
2.  **Legality & Ethics:** Cracking passwords you do not own or have explicit permission to test is **illegal and unethical**. This guide is for educational purposes, authorized security testing (pentesting), or recovering your *own* forgotten password.
3.  **Hash Strength:** Modern `/etc/shadow` hashes (like bcrypt `$2a/$2b/$2y$`, SHA256crypt `$5$`, SHA512crypt `$6$`) are designed to be computationally expensive to crack, even with GPUs. This process can take a *very* long time or be impossible depending on password complexity and available hardware.
4.  **Salting:** `/etc/shadow` hashes are always salted. This means rainbow tables are ineffective, and Hashcat must calculate each password candidate for *each* hash individually.

---
## **Steps to Crack `/etc/shadow` Hashes with Hashcat**

**Step 1: Obtain the Hashes**

You need to extract the `username` and `password_hash` fields from the `/etc/shadow` file. The standard format for Hashcat with the `--username` option is `username:hash`.

1.  **Get the `/etc/shadow` file:**
    *   If you have root access: `sudo cat /etc/shadow > shadow_file.txt`
    *   If you have physical access or a backup, copy the file.

2.  **Extract Username and Hash:** Use `cut` to get the first two fields separated by a colon:
    ```bash
    cut -d: -f1,2 shadow_file.txt > shadow_hashes.txt
    ```
    This will create a file `shadow_hashes.txt` with contents like:
    ```
    root:$6$somerandomsalt$...:
    user1:$y$somerandomsalt$...:
    user2:$5$somerandomsalt$...:
    ```
    *(Note: The trailing colon might appear depending on the cut command and the original file, Hashcat usually handles this gracefully, but `cut -d: -f1,2 --output-delimiter :` is more precise if your `cut` supports it. The basic `cut -d: -f1,2` is often sufficient).*

**Step 2: Identify the Hash Type(s)**

This is CRITICAL. Hashcat needs to know exactly which algorithm was used. Look at the prefix of the hash string in `shadow_hashes.txt`.

*   `$1$`: **MD5crypt** (`-m 500`) - Older, less common now.
*   `$2a$`, `$2b$`, `$2y$`: **bcrypt** (`-m 3200`) - Common and strong.
*   `$5$`: **SHA256crypt** (`-m 7400`) - Common and strong.
*   `$6$`: **SHA512crypt** (`-m 1800`) - Common and strong, typically slower than SHA256crypt but faster than bcrypt on GPUs.
*   Other types might exist (e.g., `$`, `$_`, `$*$` for DES/ISC/etc.). Check `hashcat --help -m` for the full list and their identifiers.

**Important:** A single `shadow_hashes.txt` file might contain different hash types if users were created/migrated at different times or if the system configuration changed. Hashcat can *only* process one hash type (`-m`) at a time. You might need to split your `shadow_hashes.txt` file into separate files for each hash type if you want to attack them concurrently.

**Example:** If `shadow_hashes.txt` has both `$6$` and `$5$` hashes, you'd create `shadow_sha512.txt` and `shadow_sha256.txt` and run two separate Hashcat commands.

**Step 3: Choose Your Attack Strategy**

The most common and effective strategies for `/etc/shadow` are:

1.  **Dictionary Attack (`-a 0`):** Using lists of common passwords.
    *   Start with large, well-known lists (`rockyou.txt`, dictionaries from seclists).
2.  **Dictionary Attack with Rules (`-a 0 -r`):** Modifying dictionary words (appending numbers, changing case, adding symbols). This is highly effective as many users base passwords on dictionary words. Use rules files like `hashcat-rules` (e.g., `best64.rule`).
3.  **Hybrid Attack (`-a 6` or `-a 7`):** Combining dictionary words with masks (e.g., `password123`, `2024password`).
4.  **Mask Attack (`-a 3`):** Brute-forcing specific patterns (e.g., `?l?l?l?l?d?d` for 4 lowercase letters + 2 digits). Use this if other methods fail and you suspect a specific structure or policy.

**Step 4: Run Hashcat**

Now, construct your Hashcat command based on the hash type, attack mode, and input files.

**General Command Structure:**

```bash
hashcat -m <hash_type_number> -a <attack_mode_number> --username [options] <hashfile> [input_files_or_mask]
```

**Key Options for /etc/shadow:**

*   `-m <number>`: Required. The hash type found in Step 2.
*   `-a <number>`: Required. Attack mode (0, 1, 3, 6, 7).
*   `--username`: **REQUIRED** because your input file is `username:hash`. Tells Hashcat to parse this format correctly.
*   `--session <name>`: Highly Recommended. Allows you to pause (`p`) and resume (`r`) the session later. `hashcat --session <name>` to resume.
*   `--outfile <file>`: Saves cracked hashes (`hash:password`) to a file.
*   `--outfile-format 2`: Saves *only* the password to the outfile (useful if you want a list of recovered passwords).
*   `--remove`: Removes cracked hashes from the input hash file (`shadow_hashes.txt`). Useful if running multiple attacks on the same file. (Requires `--username` to work correctly with this format).
*   `--force` / `-S`: Sometimes needed in virtual environments or with specific drivers if Hashcat reports errors. Use with caution.
*   `-w <level>`: Workload (3 is default, 4 is aggressive GPU usage).
*   `--increment`: For mask attacks (`-a 3`), allows specifying a range of lengths (e.g., `--increment --increment-min 6 --increment-max 8`).

**Example Commands:**

*   **Basic Dictionary Attack (MD5crypt):**
    ```bash
    hashcat -m 500 -a 0 --username shadow_hashes.txt rockyou.txt --session shadow_crack_dict_md5 --outfile cracked_md5.txt
    ```

*   **Dictionary Attack with Rules (SHA512crypt):**
    ```bash
    # Assuming shadow_hashes.txt only contains $6$ hashes or you split it
    hashcat -m 1800 -a 0 --username shadow_sha512.txt /path/to/your/wordlist.txt -r /path/to/hashcat/rules/best64.rule --session shadow_crack_dict_rules_sha512 --outfile cracked_sha512.txt
    ```

*   **Hybrid Attack (Dictionary + Mask, SHA256crypt):**
    ```bash
    # Assuming shadow_hashes.txt only contains $5$ hashes or you split it
    # Appends 3 digits to dictionary words (e.g., password123)
    hashcat -m 7400 -a 6 --username shadow_sha256.txt /path/to/your/wordlist.txt ?d?d?d --session shadow_crack_hybrid_sha256 --outfile cracked_sha256.txt
    ```

*   **Mask Attack (bcrypt):**
    ```bash
    # Assuming shadow_hashes.txt only contains $2a$/etc. hashes or you split it
    # Bruteforce 8 characters: 4 lowercase, 4 digits
    hashcat -m 3200 -a 3 --username shadow_bcrypt.txt ?l?l?l?l?d?d?d?d --session shadow_crack_mask_bcrypt --outfile cracked_bcrypt.txt
    ```
    *   **Mask Attack with Increment (bcrypt, digits only, length 6-10):**
        ```bash
        hashcat -m 3200 -a 3 --username shadow_bcrypt.txt ?d?d?d?d?d?d?d?d?d?d --increment --increment-min 6 --increment-max 10 --session shadow_crack_mask_inc_bcrypt --outfile cracked_bcrypt_digits.txt
        ```

**Step 5: Check Results**

*   **During cracking:** Press `s` to see the status (speed, progress, cracked hashes).
*   **After stopping/finishing:** Use the `--show` option with the same hash file and hash type:
    ```bash
    hashcat --show -m <hash_type_number> --username shadow_hashes.txt
    ```
    This will display cracked hashes from your `hashcat.potfile` that correspond to the hashes in `shadow_hashes.txt`.

*   If you used `--outfile`, check that file for the cracked hashes/passwords.

*   To see which hashes *weren't* cracked, use `--left`:
    ```bash
    hashcat --left -m <hash_type_number> --username shadow_hashes.txt
    ```

**Step 6: Iterate and Refine**

If your initial attack didn't crack everything, try different strategies:

*   Use a larger dictionary.
*   Use different rule sets.
*   Try different hybrid attacks.
*   Craft more intelligent masks based on potential password policies or user habits.
___
## Salted Hash Attack

**What is a Salt?**

In password hashing, a "salt" is a piece of random data added to a password *before* it is hashed.

Instead of hashing just the password:
`hash = HASH_ALGORITHM(password)`

Hashing with a salt involves combining the password and the salt:
`hash = HASH_ALGORITHM(password + salt)`

The salt is **not a secret**. It is stored alongside the resulting hash.

**Why is Salting Used?**

1.  **Defeat Rainbow Tables:** Rainbow tables are precomputed tables of hashes. Without salts, if two users have the same password (e.g., "password123"), their hashes will be identical. A rainbow table entry for `hash("password123")` would crack both simultaneously. With salting, `hash("password123" + salt1)` produces a completely different result than `hash("password123" + salt2)`. This forces an attacker to compute guesses individually for *each* hash, rendering generic rainbow tables useless.
2.  **Prevent Hashing Identical Passwords:** Even if a dictionary attack is performed, two users with the same password and *different* salts will appear as different hashes in the hash list, making it slightly less obvious when common passwords are used.
3.  **Increase Workload (Indirectly):** While not the primary goal, the per-hash calculation required by salting increases the overall computation needed for an attack compared to looking up precomputed values.

**How to Find Out If a Hash is Salted?**

The most reliable way is to **look at the structure of the hash string itself** and identify the algorithm used. Salted hashes are designed to include the salt within or alongside the hash value itself.

Here are common indicators and formats:

1.  **Prefixes and Delimiters:** Many salted hash formats use specific prefixes (like `$`) and delimiters (like `$`, `.`, or `:`). The presence of these structured components often indicates salting.
2.  **Common Unix/Linux Formats (`$type$salt$hash`):** This is the most recognizable pattern, notably used in `/etc/shadow`.
    *   `$1$...`: **MD5crypt** (salted)
    *   `$2a$`, `$2b$`, `$2y$...`: **bcrypt** (always salted)
    *   `$5$...`: **SHA256crypt** (always salted)
    *   `$6$...`: **SHA512crypt** (always salted)
    *   `_...` : **DEScrypt** (older, salted)
    *   `$` : **DES** (older, may or may not be salted depending on system)
    *   `*` or `!` : Indicate locked or no password, not a crackable hash.
3.  **Base64 Encoded Strings:** Some systems (databases, web applications) might store salted hashes as a single Base64 string. You might see parts of the string that aren't just the hash value – this could be the salt prepended or appended before Base64 encoding.
4.  **Database/Application-Specific Formats:** Look at the database schema or application code. Often, the salt is stored in a separate column next to the hash, or the application logic defines how salt and hash are combined before storage.
5.  **Hashcat `--help -m <number>`:** The best way to *confirm* for a specific hash type is to check Hashcat's documentation or help output for that type. When you run `hashcat --help -m <hash_type_number>`, it will show the expected format of the hash string, and you will see the salt component included in the description.

**Example:**

Compare:
*   **Unsalted MD5:** `e10adc3949ba59abbe56e057f20f883e` (Just the hex hash value)
*   **Salted MD5crypt (`-m 500`):** `$1$somerandomsalt$actualhashvalue` (Prefix `$1$`, the salt `somerandomsalt`, and the hash `actualhashvalue`, separated by `$`)
*   **Salted SHA512crypt (`-m 1800`):** `$6$somerandomsaltstring$actualhashvalue...` (Prefix `$6$`, a potentially longer salt string, and a longer hash value, separated by `$`)

If the hash string you have contains multiple components separated by delimiters, and these components match the format described for a known salted algorithm by Hashcat's help, it's salted. If it's just a plain hex or Base64 string *without* obvious structure (like an MD5 or SHA1 hash *might* look if unsalted), you might need more context (source code, database schema) to know if a salt was used separately.

**How to Crack Salted Hashes with Hashcat**

This is where Hashcat makes your life simpler. You **DO NOT** typically need to manually extract the salt and provide it separately to Hashcat.

Hashcat knows the expected format for hundreds of hash types, including where the salt is located within the hash string itself.

**The key is identifying the correct hash type (`-m <number>`).**

Once you specify the correct `-m` value for a salted hash type (like `-m 1800` for SHA512crypt or `-m 3200` for bcrypt), Hashcat automatically:

1.  Reads the hash string from your input file.
2.  Parses the string according to the rules for that specific hash type (e.g., it knows for `$6$salt$hash` that the part between the second and third `$` is the salt).
3.  For *each* password candidate it generates (from a dictionary, rules, or mask), it takes that candidate, combines it with the extracted salt from the specific hash it's currently trying to crack, runs the appropriate hashing algorithm, and compares the result to the stored hash value.
4.  It does this individually for every hash in your file.

**Steps using Hashcat:**

1.  **Obtain the Hash(es):** Get the string(s) representing the hash(es) you want to crack. Ensure they are in the format they were stored (e.g., the full `$6$salt$hash` string).
2.  **Identify the Hash Type:** Based on the format/prefix (as described above), determine the Hashcat `-m` number. This is the MOST IMPORTANT step. Use `hashcat --help -m <number>` to verify the format Hashcat expects.
3.  **Format Your Input File:** Put the hashes (one per line) into a file (`hashes.txt`). If the original format was `username:hash` (like `/etc/shadow`), keep that format and plan to use Hashcat's `--username` option.
4.  **Choose an Attack Mode:** Decide on dictionary (`-a 0`), rules (`-r`), hybrid (`-a 6`/`-a 7`), or mask (`-a 3`).
5.  **Run Hashcat:** Construct the command using the correct hash type (`-m`), attack mode (`-a`), your hash file, and your input (dictionary/mask/rules).

**Example Commands (Similar to the `/etc/shadow` example, as they are common salted hashes):**

*   **Cracking SHA512crypt (`-m 1800`) with a dictionary and rules:**
    ```bash
    # Input file `sha512_hashes.txt` contains lines like: $6$somesalt1$hash1... , $6$somesalt2$hash2...
    hashcat -m 1800 -a 0 sha512_hashes.txt rockyou.txt -r rules/best64.rule --session sha512_crack
    ```
    *Hashcat reads `$6$somesalt1$hash1...`, extracts `somesalt1`, tries `HASH_SHA512("password" + "somesalt1")` for each candidate "password" from `rockyou.txt` + rules, compares to `hash1...`. Then it moves to the next line, reads `$6$somesalt2$hash2...`, extracts `somesalt2`, tries `HASH_SHA512("password" + "somesalt2")`, compares to `hash2...`, and so on.*

*   **Cracking bcrypt (`-m 3200`) with a mask:**
    ```bash
    # Input file `bcrypt_hashes.txt` contains lines like: $2a$10$somesalt1...hash1... , $2y$12$somesalt2...hash2...
    hashcat -m 3200 -a 3 bcrypt_hashes.txt ?l?l?l?l?d?d --increment --increment-min 6 --increment-max 8 --session bcrypt_crack_mask
    ```
    *Hashcat reads a bcrypt hash, parses its salt and cost factor, generates mask candidates (like `abcd12`, `efgh34`), computes `HASH_BCRYPT(candidate + salt, cost)`, compares to the stored hash. It repeats this for every mask candidate against the *current* hash's salt, then moves to the next hash in the file.*

*   **Cracking `/etc/shadow` format (mixed types) - requires splitting file or running separate commands:**
    ```bash
    # Assuming shadow_hashes.txt contains user:hash lines, some $6$, some $5$
    # First, crack SHA512crypt hashes ($6$)
    hashcat -m 1800 -a 0 --username shadow_hashes.txt dicts/mylist.txt --session shadow_crack_sha512 --outfile cracked_sha512.txt --remove

    # Then, crack SHA256crypt hashes ($5$) that remain in shadow_hashes.txt
    hashcat -m 7400 -a 0 --username shadow_hashes.txt dicts/mylist.txt --session shadow_crack_sha256 --outfile cracked_sha256.txt --remove
    ```
    *The `--username` option tells Hashcat to handle the `username:hash` input format correctly when parsing the hashes and their salts.*

**In Summary:**

*   Salting adds randomness to the hashing process by including a unique piece of data (the salt) alongside the password before hashing.
*   Identify if a hash is salted by looking at its structure and prefix and cross-referencing with known salted hash formats or `hashcat --help -m <number>`.
*   To crack a salted hash with Hashcat, the primary requirement is to identify the **correct hash type (`-m`)**. Hashcat handles the extraction and use of the salt automatically based on the specified hash type's format.

Salting makes rainbow tables ineffective and increases the per-guess computation, but it does *not* prevent dictionary, rule, or mask attacks; it just forces them to be executed per hash individually.