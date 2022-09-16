from getpass import getuser
from os.path import sep, expanduser, dirname, basename

#** Variables **#
__all__ = []

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

#** Init **#

try:
    xonsh = __xonsh__
except NameError:
    xonsh = None

