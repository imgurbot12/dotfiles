from typing import *
from shutil import which
from getpass import getuser
from os.path import sep, isdir, exists, dirname, basename, expanduser

#** Variables **#
__all__ = [
    'USER',
    'HOME',
    'GOROOT',
    'GOPATH',

    'expanduser',
    'unexpanduser',
]

#** Variables **#

#: configured xonsh prompt
PROMPT = 'aight'

USER = getuser()
HOME = expanduser('~').rstrip(sep)

GOROOT     = '/usr/local/go'
GOPATH     = f'{HOME}/Code/golang'
NVM_ROOT   = f'{HOME}/.nvm'
CARGO_ROOT = f'{HOME}/.cargo'
PYENV_ROOT = f'{HOME}/.pyenv'

#** Functions **#

def unexpanduser(path: str) -> str:
    """
    unexpand the given user path and add a `~` when possible

    :param path: user path being shortened
    :return:     shorted home relative path
    """
    return f'~{path[len(HOME):]}' if path.startswith(HOME) else path

def abrevpath(path: str, length: int = 0) -> str:
    """
    abreviate the given path name if its beyond a given length

    :param cwd:    current working directory
    :param length: length allowed before shortening
    :return:       shortend path
    """
    path = unexpanduser(path)
    if length > 0 and len(path) >= length:
        dir, base = dirname(path), basename(path)
        dir       = sep.join(d[0] if d else '' for d in dir.split(sep))
        path      = f'{dir}{sep}{base}'
    return path

#** XonSH functions **#

def statuscode() -> int:
    """
    retrieve status code of last completed command
    """
    history = xonsh.history.rtns
    return history[-1] if len(history) > 0 else 0

def addpath(path: str, first: bool = False):
    """
    add the given path to xonsh configured PATH env variable
    """
    PATH = xonsh.env['PATH']
    if isdir(path) and exists(path) and path not in PATH:
        PATH.add(path, first=first, replace=True)

def ensurepaths(bin: str, paths: dict):
    """
    condionally add the given paths if they exist and the command cannot be found
    """
    if not which(bin):
        env = xonsh.env
        for name, path in paths.items():
            path = env.setdefault(name, path)
            addpath(f'{path}/bin')

def cmdalias(alias: str, cmd: str, *args: str):
    """
    alias command if command is accessable to shell
    """
    if which(cmd):
        xonsh.aliases[alias] = [cmd, *args]

#** Init **#

try:
    xonsh = __xonsh__
except NameError:
    xonsh = None

# complete xonsh init if available
if xonsh is not None:
    # import and configure prompts
    import prompts

    prompts.load_prompt(PROMPT)

    # ensure paths are added to xonsh
    addpath(f'{HOME}/bin')
    addpath(f'{HOME}/.local/bin')

    # add paths for various languages
    ensurepaths('go',    {'GOROOT': GOROOT, 'GOPATH': GOPATH})
    ensurepaths('cargo', {'CARGO_ROOT', CARGO_ROOT})
    ensurepaths('pyenv', {'PYENV_ROOT', PYENV_ROOT})

    # neovim override alises
    cmdalias('vi',   'nvim')
    cmdalias('vim',  'nvim')
    cmdalias('code', 'neovide')

    # rust override aliases
    cmdalias('ls',   'exa')
    cmdalias('ll',   'exa', '-l')
    cmdalias('la',   'exa', '-la')
    cmdalias('cat',  'bat')
    cmdalias('find', 'fd')
    cmdalias('http', 'xh')

    # clipboard aliases
    cmdalias('pbcopy',  'xsel',  '-ib')
    cmdalias('pbpaste', 'xsel',  '-ob')
    cmdalias('pbcopy',  'xcopy', '-selection c')
    cmdalias('pbpaste', 'xcopy', '-selection c -o')
