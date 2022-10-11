# Bash Startup Files
# When invoked as an interactive login shell, Bash looks for the /etc/profile file, and if the file exists,
# it runs the commands listed in the file. Then Bash searches for ~/.bash_profile, ~/.bash_login, and ~/.profile files, in the listed order,
# and executes commands from the first readable file found.

# When Bash is invoked as an interactive non-login shell, it reads and executes commands from ~/.bashrc, if that file exists, and it is readable.