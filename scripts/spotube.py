#!/usr/bin/env python3
"""
Spotube Login Management Script
"""
import os
import json
import random
from typing import List, Optional, Tuple

from playwright.sync_api import Cookie, Page, sync_playwright

#** Variables **#

#: cache directory for program
CACHE_DIR = os.path.expanduser('~/.cache/spotube/')

#: cache for spotify login cookies
COOKIES_CACHE = os.path.join(CACHE_DIR, 'cookies.json')

#** Functions **#

def is_logged_in(page: Page) -> bool:
    """
    check if already logged-in

    :page page: playwright webpage object
    :return:    true (if already logged in)
    """
    login = page.get_by_test_id('login-button')
    return login.is_hidden()

def login(page: Page):
    """
    complete login process (if not already logged-in)

    :param page:  playwright webpage object
    :param creds: credentials to use when logging-in
    """
    # click button and login otherwise
    login = page.get_by_test_id('login-button')
    delay = random.uniform(0.5, 1.7)
    print(f'playwright: clicking login button. waiting {delay:02f} seconds')
    login.click(delay=delay)
    page.wait_for_url('https://accounts.spotify.com/**')
    # complete login
    print('playwright: please login to spotify')
    print('playwright: waiting for login completion')
    page.wait_for_url('https://open.spotify.com/**', timeout=600 * 1000)

def get_cookies(page: Page) -> Optional[Tuple[str, str]]:
    """
    retrieve session cookies for spotube

    :param page: playwright webpage object
    :return:     (sp_dc, sp_key) (if present)
    """
    cookies = page.context.cookies()
    if not isinstance(cookies, dict):
        cookies = {cookie['name']:cookie for cookie in cookies}
    if 'sp_dc' in cookies:
        dc  = cookies['sp_dc']['value']
        key = cookies['sp_key']['value']
        return (dc, key)

def load_cookies(page: Page) -> Optional[List[Cookie]]:
    """
    retrieve cookies from cache when available
    """
    if not os.path.exists(COOKIES_CACHE):
        return
    print('playwright: loading cached cookies')
    with open(COOKIES_CACHE, 'r') as f:
        cookies = json.load(f)
        page.context.add_cookies(cookies)

def save_cookies(page: Page):
    """
    save cookies to cache for later retrieval
    """
    print('playwright: saving cookies to cache')
    cookies = page.context.cookies()
    os.makedirs(CACHE_DIR, exist_ok=True)
    with open(COOKIES_CACHE, 'w') as f:
        json.dump(cookies, f)

#** Init **#

with sync_playwright() as p:
    # launch headless browser and load cookies from cache
    browser  = p.webkit.launch(headless=True)
    page     = browser.new_page()
    load_cookies(page)
    print('playwright: loading spotify')
    page.goto('https://open.spotify.com')
    # visit spotify and login (if not already)
    if not is_logged_in(page):
        print('playwright: not logged-in. opening login page')
        # close headless browser and open normal one
        browser.close()
        browser = p.webkit.launch(headless=False)
        page    = browser.new_page()
        page.goto('https://open.spotify.com')
        login(page) 
    else:
        print('playwright: already logged-in')
    # retrieve updated cookies from web-page
    data = get_cookies(page)
    if data is not None:
        print('======================')
        print('sp-dc: ', data[0])
        print('sp-key:', data[1])
        print('======================')
    else:
        print('ERROR: failed to find cookies!')
    # save cookies on completion and close browser
    save_cookies(page)
    browser.close()
