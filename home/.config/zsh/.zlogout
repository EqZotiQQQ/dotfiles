#!/bin/zsh

# Очистка временных файлов
rm -f /tmp/my-session-*

# Убить ssh-agent
[ -n "$SSH_AGENT_PID" ] && eval "$(ssh-agent -k)" > /dev/null

# Очистка экрана (опционально)
# clear

# Логирование сессии
echo "$(date): logout from $(tty)" >> "$HOME/.session_log"
