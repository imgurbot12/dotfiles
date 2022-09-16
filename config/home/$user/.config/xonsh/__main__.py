from shutil import which
from os.path import isdir, exists


from . import prompts
from . import xonsh, HOME, GOROOT, GOPATH, CARGO_ROOT, PYENV_ROOT

#** Functions **#

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

if xonsh is not None:

    # ensure paths are added to xonsh
    addpath(f'{HOME}/bin')
    addpath(f'{HOME}/.local/bin')
    
    # add paths for various languages
    ensurepaths('go',    {'GOROOT': GOROOT, 'GOPATH': GOPATH})
    ensurepaths('cargo', {'CARGO_ROOT': CARGO_ROOT})
    ensurepaths('pyenv', {'PYENV_ROOT': PYENV_ROOT})

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

    # clipboard aliases
    cmdalias('pbcopy',  'xsel',  '-ib')
    cmdalias('pbpaste', 'xsel',  '-ob')
    cmdalias('pbcopy',  'xcopy', '-selection c')
    cmdalias('pbpaste', 'xcopy', '-selection c -o')
