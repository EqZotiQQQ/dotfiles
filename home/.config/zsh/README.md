# Bindings
## 🎹 Keyboard Bindings
```
Ctrl + A / Ctrl + E       -> move to beginning/end of line
Ctrl + U                  -> delete to beginning
Ctrl + K                  -> delete to end
Ctrl + W                  -> delete word backward
Alt + F / Alt + B         -> move forward/backward one word

Word = up to the next separator (/ - . _ space ...), WORDCHARS=''

Ctrl + R                  -> fzf search
Ctrl + L                  -> clear screen
Ctrl + Left / Right       -> backward / forward word
Ctrl + Backspace / Delete -> delete word backward / forward
Ctrl + Shift + Left / Right       -> to start / end of line
Ctrl + Shift + Backspace / Delete -> delete to start / end of line
Shift + Alt + Right       -> forward word
Shift + Alt + Left        -> bacward word
```


# Files
Файлы конфигурации Zsh запускаются в определённом порядке в зависимости от типа сессии: **login shell**, **interactive shell**, **non-interactive shell**, **remote shell** и т.п.

Вот полный список основных конфигурационных файлов и порядок их загрузки:

### 📄 **1. `.zshenv`**
- **Загружается всегда**, при любом запуске Zsh (login, non-login, interactive, non-interactive).
- Обычно используется для установки переменных окружения (например, `PATH`), т.к. он запускается даже в скриптах.
### 📄 **2. `.zprofile`**
- Загружается **только для login shell** (когда ты входишь в систему через tty или ssh, или запускаешь `zsh -l`).
- Аналог `.profile` в bash.
- Используется для инициализации, которая должна происходить один раз при логине, например: запуск `startx`, `ssh-agent` и т.п.
### 📄 **3. `.zshrc`**
- Загружается **только для интерактивных шеллов** (т.е. при открытии терминала).
- Сюда добавляют alias’ы, настройки prompt’а, плагинов и т.д.
### 📄 **4. `.zlogin`**
- Также загружается **только для login shell**, **после** `.zprofile` и `.zshrc`.
- Используется для команд, которые должны выполняться **после** полной инициализации шелла.
### 📄 **5. `.zlogout`**
- Выполняется **при выходе из login shell**.
- Можно использовать для очистки или завершения фоновых процессов.
### 🛑 Не загружаются:
- `.zprofile`, `.zlogin`, `.zlogout` — **не запускаются в non-login shell**.
- `.zshrc` — **не запускается в non-interactive shell** (например, при запуске скриптов).
### 🧠 Пример порядка для разных сценариев:
#### 🔸 Login + interactive shell (`zsh -l` или через tty/ssh):
1. `.zshenv`
2. `.zprofile`
3. `.zshrc`
4. `.zlogin`
#### 🔸 Non-login, interactive shell (например, GUI терминал):
1. `.zshenv`
2. `.zshrc`
#### 🔸 Non-interactive, non-login shell (например, скрипт):
1. `.zshenv`
# Shell types
### 🟢 **Login shell**
**Это оболочка, запускаемая при логине в систему.**  
Обычно первый shell при входе по tty, ssh, или запуске `zsh -l`.
**Признаки:**
- `echo $0` → часто покажет `-zsh` (с минусом).
- Используется при входе в систему (tty/ssh).
**Примеры запуска:**
- вход в систему через консоль/tty
- ssh-доступ
- запуск `zsh -l`
**Загружаются:**
- `.zshenv`
- `.zprofile`
- `.zshrc`
- `.zlogin`
### 🔵 **Interactive shell**
**Это shell, с которым пользователь напрямую взаимодействует.**  
Ты видишь prompt, можешь вводить команды.
**Признаки:**
- `[[ $- == *i* ]]` → true (буква `i` в `$-`)
- `echo $-` → содержит `i`
**Примеры запуска:**
- запуск терминала в GUI
- `zsh` в интерактивном режиме
- login shell тоже interactive
**Загружаются:**
- `.zshenv`
- `.zshrc`
### 🟠 **Non-interactive shell**
**Shell, работающий без прямого взаимодействия с пользователем.**
**Примеры:**
- Скрипт: `zsh script.zsh`
- Команда через cron
- Вызов `zsh -c 'команда'`
**Признаки:**
- `$-` не содержит `i`
**Загружается:**
- Только `.zshenv`
### 🔴 **Remote shell**
**Login shell, запущенный по сети (обычно через SSH).**
**Пример:**
- `ssh user@host`
**По сути это:**
- login shell
- может быть interactive или non-interactive
**Загружаются:**
- `.zshenv`
- `.zprofile`
- `.zshrc` (если interactive)
- `.zlogin`
