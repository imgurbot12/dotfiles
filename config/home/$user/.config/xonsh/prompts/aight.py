"""
XonSH implementation of fish `aight` theme
"""
from . import xonsh, statuscode

def left_prompt() -> str:
    """
    generate left portion of command prompt
    """
    sc = statuscode()
    if not sc:
        return '{env_name}$ '
    return '{env_name}{BOLD_RED}${RESET} '

def right_prompt() -> str:
    """
    generate right portion of command prompt
    """
    return '{curr_branch_chg: {#555}({}) }{BOLD_BLUE}[{YELLOW}{short_cwd}{BOLD_BLUE}]{RESET}'
