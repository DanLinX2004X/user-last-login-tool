# user-last-login-tool.spec
# -----------------------------------------------------------------------------
# RPM Specification File for user-last-login-tool

# 1. Package Metadata (Метаданные пакета)
Name: user-last-login-tool
Version: 1.0.0
Release: 1%{?dist}
Summary: SRE tool to generate a CSV report of last login times.
License: MIT
URL: https://github.com/DanLinX2004X/user-last-login-tool
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
Packager: DanLin <dan.laktionov.io@gmail.com>

# 2. Dependencies (Зависимости)
# Указываем необходимые пакеты для работы скрипта (last, lastlog, date, getent, bash)
Requires: bash, coreutils, shadow-utils, util-linux

# 3. Description (Описание)
%description
The user-last-login-tool is an SRE script designed to analyze system login records
using 'last' (wtmp log) and 'lastlog'. This cascading approach ensures
reliability on both modern and centralized (LDAP/SSSD) Linux systems.
It generates a structured CSV report detailing the username, last login date,
and the days elapsed since the last login for users above a minimum UID threshold.

# -----------------------------------------------------------------------------
# 4. Preparation and Build Stages (Подготовка и Сборка)

%prep
%setup -q

%build
# %build is often left empty for Bash scripts

# -----------------------------------------------------------------------------
# 5. Installation Stage (Установка)

%install
# Create the necessary standard directories inside the package root
install -d -m 755 %{buildroot}/usr/bin
install -d -m 755 %{buildroot}/usr/share/man/man1
install -d -m 755 %{buildroot}/usr/share/licenses/%{name}

# 1. Install the executable script to /usr/bin/
install -m 755 user_last_login.sh %{buildroot}/usr/bin/user_last_login.sh

# 2. Install the man page to /usr/share/man/man1/
install -m 644 user_last_login.1 %{buildroot}/usr/share/man/man1/user_last_login.1

# 3. Install the License file
install -m 644 LICENSE %{buildroot}/usr/share/licenses/%{name}/LICENSE

# -----------------------------------------------------------------------------
# 6. Files List (Список файлов для включения в пакет)

%files
%license LICENSE
/usr/bin/user_last_login.sh
/usr/share/man/man1/user_last_login.1
%doc

# -----------------------------------------------------------------------------
# 7. Changelog (История изменений)

%changelog
* Fri Nov 28 2025 DanLin <dan.laktionov.io@gmail.com> - 1.0.0-1
- Initial release of user-last-login-tool.
- Includes man page and MIT license.
