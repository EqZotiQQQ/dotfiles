.zprofile and .zlogin
They set the environment for login shells. .zprofile conceptually the same as .bashprofile. 

.zshrc
Set the environment for interactive shells. Loads after .zprofile. Default place to set parameters for $PATH and $PROMPT.

.zshenv (optional)
Read first and read every time. Default place where to set environment variables.

.zlogout (optional)
Executes when you log out of a session.

Execution order:
.zshenv -> .zprofile -> .zshrc -> .zlogin -> .zlogout


manual for plugins:
https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/