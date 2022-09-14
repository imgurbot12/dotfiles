import os
import shutil
from typing import Optional

#** Variables **#

USER = os.environ.get('USER')
if USER is None:
    $USER = USER = os.environ['USER'] = $(whoami).strip()

HOME = os.environ.get('HOME')
if HOME is None:
    HOME  = $(getent passwd andrew | cut -d: -f6).strip().rstrip('/')
    $HOME = os.environ['HOME'] = HOME

GOROOT     = '/usr/local/go'
GOPATH     = f'{HOME}/Desktop/code/golang'
CARGO_PATH = f'{HOME}/.cargo'
PONY_PATH  = f'{HOME}/.local/share/ponyup'
PYENV_PATH = f'{HOME}/.pyenv'
NVM_PATH   = f'{HOME}/.nvm'

#** Functions **#

def last_status() -> Optional[int]:
    """
    retrieve status code of last completed command
    """
    history = list(__xonsh__.history.rtns)
    return history[-1] if history else 0

def shorten_path(cwd: str, length: int = 0) -> str:
    """
    shorten path if beyond a given length
    """
    cwd = f'~{cwd[len(HOME):]}' if cwd.startswith(HOME) else cwd
    if len(cwd) >= 15:
        dir, base = cwd.rsplit('/', 1)
        dir       = '/'.join(d[0] if d else '' for d in dir.split('/'))
        return f'{dir}/{base}'
    return cwd

def left_prompt() -> str:
    if last_status() != 0:
        return '{env_name}{BOLD_INTENSE_RED}${RESET} '
    return '{env_name}$ '

def right_prompt() -> str:
    cwd = shorten_path(__xonsh__.shell.shell.precwd or $(pwd), 15)
    return '{curr_branch: {#555}({}) }{BOLD_BLUE}[{YELLOW}' + cwd + '{BOLD_BLUE}]{RESET}'

def add_path(path: str):
    """
    add the given path to xonsh $PATH
    """
    if os.path.isdir(path) and os.path.exists(path):
        PATH = $PATH
        $PATH.append(path) if isinstance(PATH, list) else $PATH.add(path)

def ensure_path(bin: str, *paths: str):
    """
    conditionally add the given paths to the session if the binary is missing

    :param bin:   binary to check if exists
    :param paths: list of paths to add to xonsh
    """
    if not shutil.which(bin):
        for path in paths:
            add_path(path)

def alias_cmd(alias: str, cmd: str, args: str = ''):
    """
    alias command if command is accessable to shell

    :param alias: alias name to generate
    :param cmd:   command to alias
    :param args:  arguments to include with command
    """
    if shutil.which(cmd):
        aliases[alias] = f'{cmd} {args}'

#** Init **#

# load xontrib modules
xontrib load fish_completer

# custom prompt
$PROMPT       = left_prompt
$RIGHT_PROMPT = right_prompt

# builtin paths
add_path(f'{HOME}/bin')
add_path(f'{HOME}/.local/bin')

# add paths for various languages
ensure_path('go',    f'{GOROOT}/bin', f'{GOPATH}/bin')
ensure_path('cargo', f'{CARGO_PATH}/bin')
ensure_path('ponyc', f'{PONY_PATH}/bin')
ensure_path('pyenv', f'{PYENV_PATH}/bin')

# neovim override aliases
alias_cmd('vi', 'nvim')
alias_cmd('vim', 'nvim')
alias_cmd('code', 'neovide')

# rust override aliases
alias_cmd('ls', 'exa')
alias_cmd('ll', 'exa', '-l')
alias_cmd('la', 'exa', '-la')
alias_cmd('cat', 'bat')
alias_cmd('find', 'fd')

# clipboard aliases
alias_cmd('pbcopy',  'xsel',  '-ib')
alias_cmd('pbcopy',  'xclip', '-selection c')
alias_cmd('pbpaste', 'xsel',  '-ob')
alias_cmd('pbpaste', 'xclip', '-selection c -o')

