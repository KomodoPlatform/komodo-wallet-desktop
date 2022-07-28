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
            themes[branch].update({
                f"missing_{theme}": missing,
                f"obsolete_{theme}": selectors.difference(dev_selectors[theme])
            })

            print(f"\n#### {branch} {theme} ####")
            for i in themes[branch][f"obsolete_{theme}"]:
                print(f"Obsolete selector: {i}...")

            for i in themes[branch][f"missing_{theme}"]:

                dev_color = themes['dev'][theme][i]
                for j in themes['dev'][theme]:
                    if dev_color == themes['dev'][theme][j]:
                        if j in themes[branch][theme]:
                            print(f"Missing {i}... Suggest using {themes[branch][theme][j]}")
                            break
                



