#!/bin/zsh

# Приветствие / MOTD
echo "$(date '+%A, %d %B')"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

# Напоминалки
# if command -v todo.sh &>/dev/null; then
#     todo.sh ls
# fi

# fortune / cowsay / fastfetch — если нравится
command -v fastfetch &>/dev/null && fastfetch
