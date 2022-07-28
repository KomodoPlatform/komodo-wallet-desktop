#!/usr/bin/env python3
import json
import requests

branches = ['dev', 'smartdex', 'GleecDEX', 'shibadex']

themes = {}
for branch in branches:
    themes.update({branch: {}})
    for theme in ['light', 'dark']:
        url = f"https://raw.githubusercontent.com/KomodoPlatform/atomicDEX-Desktop/{branch}/assets/themes/Default%20-%20{theme.title()}/colors.json"
        themes[branch].update({
            theme: requests.get(url).json()
        })

dev_selectors = {
    'light': set(themes['dev']['light'].keys()),
    'dark': set(themes['dev']['dark'].keys())
}

for branch in branches:
    if branch != "dev":
        for theme in ['light', 'dark']:
            selectors = set(themes[branch][theme].keys())
            missing = dev_selectors[theme].difference(selectors)
            obsolete = selectors.difference(dev_selectors[theme])
            print(f"#### {branch} {theme} ####")
            print(f"Missing: {missing}")
            print(f"Obsolete: {obsolete}")
