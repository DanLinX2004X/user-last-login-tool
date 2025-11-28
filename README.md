# user-last-login-tool

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/DanLinX2004X/user-last-login-tool/ci.yml?branch=main&label=CI%20Tests)](https://github.com/DanLinX2004X/user-last-login-tool/actions)
[![License](https://img.shields.io/github/license/DanLinX2004X/user-last-login-tool?color=blue)](LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![GitHub tag](https://img.shields.io/github/v/tag/DanLinX2004X/user-last-login-tool)](https://github.com/DanLinX2004X/user-last-login-tool/tags)


**🇺🇸 English** | **🇷🇺 [Russian Version](README.ru.md)**

## 💡 Overview

The **`user-last-login-tool`** is a simple, yet robust, Bash script designed for **SRE** (Site Reliability Engineering) and **DevOps** environments. Its primary function is to analyze system login records using a **cascading logic**: first checking the **wtmp log (`last`)** for interactive sessions, and then falling back to **`lastlog`**. This ensures the most accurate last login time is reported.

This tool is optimized for system monitoring and compliance auditing on Linux distributions.

## ✨ Features

* **Customizable Filtering:** Filters users based on a specified **Minimum User ID (UID)** (defaults to 1000).
* **Detailed Metrics:** Reports the username, the exact last login date, and the **number of days elapsed** since the last login.
* **Safe Execution:** Creates dedicated log (`/var/log/sre-tools/`) and report (`/opt/sre-reports/`) directories.
* **Professional Distribution:** Supports packaging for **AUR**, **DEB**, and **RPM** ecosystems, alongside standard `make install`.
* **Reliable Cascading Logic:** Uses `last` (for interactive terminal logins) and `lastlog` (for terminal/FTP logins) to determine the most recent login time, ensuring accuracy across various Linux configurations. * **Customizable Filtering:** Filters users based on a specified **Minimum User ID (UID)** (defaults to 1000). *

## 🛠️ Installation

### Method 1: Using Make (Source Install)

This method is recommended for developers and system administrators who want to install the script to standard local paths (`/usr/local/bin` and `/usr/local/man/man1`).

1.  Clone the repository:
    ```bash
    git clone https://github.com/DanLinX2004X/user-last-login-tool.git
    cd user-last-login-tool
    ```
2.  Install the script, man page, and working directories:
    ```bash
    sudo make install
    ```
3.  Verify installation:
    ```bash
    man user_last_login
    ```

### Method 2: Using Package Managers (Recommended for Users)

The project provides ready-to-use specifications for major Linux distributions:

| Distribution | Package Type | Tool | File/Location |
| :--- | :--- | :--- | :--- |
| **Arch/CachyOS** | AUR | `paru`, `yay` | `PKGBUILD` (to be pushed to AUR) |
| **Debian/Ubuntu** | DEB | `dpkg` | Files in `debian/` |
| **Red Hat/Fedora**| RPM | `rpm` | `user-last-login-tool.spec` |

### Method 3: Docker Execution

You can run the script in an isolated environment without installing system dependencies:

You can run the script in an isolated environment without installing system dependencies: 
1. Build the Docker image: 
```bash
 docker build -t user-last-login . 
 ``` 
2. Run the script and **mount the report directory** (e.g., set minimum UID to 500): 
```bash 
# The report will be saved in your current directory (/path/to/local/reports) 
docker run --rm -v $(pwd)/reports:/opt/sre-reports user-last-login --uid 500 
```

---

## 🚀 Usage

Once installed, the script is run directly from the command line.

### Synopsis

```bash
user_last_login.sh [OPTIONS]
```

### Options

|Option|Description|Default|
|---|---|---|
|-u, --uid <UID>|Set the minimum User ID (UID) to include in the report.|1000|
|-d, --dir <PATH>|Set an alternative path for saving the CSV report.|/opt/sre-reports|
|-h, --help|Display usage information and exit.||
|-v, --version|Display script version and exit.||




### Example

To generate a report for all users with a UID greater than 500:

```bash
user_last_login.sh -u 500
```

### Output

The script generates a report named `user_last_login_YYYY-MM-DD.csv` in the report directory.

|Username|Last_Login_Date|Days_Ago|
|---|---|---|
|danlin|Wed Oct 30 14:30:00 2025|29|
|deployer|Never logged|N/A|




---

## ⚙️ Development and Testing

The project uses **ShellCheck** for linting and **Bats** (Bash Automated Testing System) for functional testing.

To run the full test suite locally:

```bash
make test
```

---

## 🤝 Contributing

We welcome contributions! As this script aims for reliability across various Linux environments, including systems using **LDAP** or **SSSD**, any help in testing or improving the logic is highly appreciated.

### How to Contribute:

* **Reporting Issues:** If you encounter a bug (especially with LDAP/SSSD integration or package installation), please open an Issue detailing the problem and your system environment.
* **Pull Requests:** Feel free to fork the repository and submit a Pull Request with fixes, new features, or improvements to the documentation or packaging files (DEB/RPM/PKGBUILD).
* **Testing:** If you run the tool on systems with complex authentication setups, sharing your success or failure results helps validate our cascading logic.

Please ensure that any new code adheres to the existing coding style and passes the unit tests (`make test`).

---

## 📝 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 👋 Contact

-   **Author:** DanLIn
