alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f --tail 100'
alias dex='f(){ docker exec -it "$1" sh; }; f'
