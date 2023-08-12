"""
Various XonSH prompt implementations
"""
from os import path
from sys import stderr
from subprocess import Popen, PIPE, TimeoutExpired

#** Variables **#
__all__ = ['load_prompt']

try:
    xonsh = __xonsh__
except NameError:
    xonsh = None

#** Functions **#

def command(*args, timeout: int = 3, ignore_errors: bool = False, **kwargs) -> str:
    """
    retrieve stdout of the given command
    """
    with Popen(args, stdout=PIPE, stderr=PIPE, **kwargs) as proc:
        try:
            out, _ = proc.communicate(timeout=timeout)
        except TimeoutExpired:
            proc.terminate()
            proc.wait()
        except Exception as e:
            if not ignore_errors:
                raise e
    return out.decode()

def set_env(env: dict, key: str, prompt: object, attr: str):
    """
    only configure environment variable for prompt if attr is not None
    """
    value = getattr(prompt, attr, None)
    if value is not None:
        env[key] = value

def load_prompt(name: str):
    """
    load a configured prompt by a given name
    """
    # attmept to load prompt
    prompt = PROMPTS.get(name)
    if prompt is None:
        print(f'INVALID PROMPT CONFIGURATION: {prompt!r}', file=stderr)
        return
    # configure prompt settings
    env = xonsh.env
    set_env(env, 'PROMPT', prompt, 'left_prompt') 
    set_env(env, 'RIGHT_PROMPT', prompt, 'right_prompt')
    set_env(env, 'BOTTOM_TOOLBAR', prompt, 'bottom_toolbar')

def statuscode() -> int:
    """
    retrieve status code of last completed command
    """
    history = xonsh.history.rtns
    return history[-1] if len(history) else 0

def branch_changed() -> str:
    """
    return `*` if the current git branch has been changed
    """
    cwd = xonsh.env['PWD']
    git = path.join(cwd, '.git')
    if not path.exists(git):
        return ''
    # attempt to run command
    cmd = command('git', 'diff', '--numstat', cwd=cwd, ignore_errors=True) 
    return '*' if cmd else ''

def current_branch_chg() -> str:
    """
    retrieve current branch and apply `*`
    """
    # skip if git is not found
    cwd = xonsh.env['PWD']
    git = path.join(cwd, '.git')
    if not path.exists(git):
        return ''
    # collect current branch and git diff status
    branch  = command('git', 'branch', '--show-current', ignore_errors=True)
    changed = command('git', 'diff', '--numstat', ignore_errors=True)
    return f'{branch.strip()}{"*" if changed else ""}'

#** Init **#
from . import aight

#: record of implemented prompts
PROMPTS = {'aight': aight}

# register additional xonsh prompt-fields
if xonsh is not None:
    # expose and update prompt fields
    PROMPT_FIELDS = xonsh.env['PROMPT_FIELDS']
    PROMPT_FIELDS['branch_chg']      = branch_changed
    PROMPT_FIELDS['curr_branch_chg'] = current_branch_chg

