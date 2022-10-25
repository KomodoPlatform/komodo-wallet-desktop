#!/usr/bin/env python3
import os
import csv

'''
NOTE: This script takes a CSV file as input, then generates a .ts file using the english file as a template.
There may be some postprocessing required to manually fix bad csv input and numerusform values.
'''


def get_lang_dict():
	with open('translations_matrix.csv') as f:
	    csv_reader = csv.reader(f, delimiter=',')
	    lang_dict = {}
	    line_count = 0
	    for row in csv_reader:
	        if line_count == 0:
	            en = row.index("English")
	            es = row.index("Spanish")
	            de = row.index("German")
	            line_count += 1
	        else:
	        	lang_dict.update({
	        		row[en]: {
	        			"es": row[es],
	        			"de": row[de]
	        		}
	        	})
	        line_count += 1
	return lang_dict

def remove_existing_translations():
	with open(f"atomic_defi_en.ts", "r") as f:
		ts_file = f.readlines()

	with open(f"atomic_defi_lang_template.ts", "w") as f:
		lines = []
		ignoring = False
		for l in ts_file:
			if l.find("<translation") > -1 or ignoring:
				ignoring = True
				if l.find("translation>") > -1:
					ignoring = False
			else:
				lines.append(l)
		f.writelines(lines)


def generate_translation(lang='en'):
	lang_dict = get_lang_dict()
	remove_existing_translations()

	with open(f"atomic_defi_lang_template.ts", "r") as f:
		lang_file = f.read()

	multiline = False
	multiline_data = []
	untranslated_count = 0
	for i in lang_dict:
		try:
			# TODO: handle numerusform translations
			if f"<source>{i}</source>" in lang_file:
				lang_file = lang_file.replace(f"<source>{i}</source>", f"<source>{i}</source>\n		<translation>{lang_dict[i][lang]}</translation>")
			if f"<source> {i}</source>" in lang_file:
				lang_file = lang_file.replace(f"<source>{i}</source>", f"<source>{i}</source>\n		<translation> {lang_dict[i][lang]}</translation>")
			elif f"<source>{i}" in lang_file:
				multiline = True
				multiline_data.append(f"<translation>{lang_dict[i][lang]}")
			elif multiline:
				multiline_data.append(f"{lang_dict[i][lang]}")
			elif f"{i}</source>" in lang_file:
				multiline_data.append(f"{lang_dict[i][lang]}<translation>")
				translation = '\n'.join(multiline_data)
				lang_file = lang_file.replace(f"{i}</source>", f"{i}</source>\n		<translation>{translation}</translation>")
				multiline = False
			elif f"<source>{i}</source>" not in lang_file:
				print(f"{i} ---> {lang_dict[i][lang]}")
				print(f">>>>>>>>>>>>>>>>>>>>>>>>>> '<source>{i}</source>' not found!")
				untranslated_count += 1
			else:
				#print(lang_dict[i][lang])
				untranslated_count += 1
				pass
		except Exception as e:
			untranslated_count += 1
			print(f">>>>>>>>>>>>>>>>>>>>>>>>>> 'Error: {e} | source: {i}")
	print(f"{untranslated_count} lines untranslated")

	with open(f"atomic_defi_{lang}.ts", 'w') as f:
	  f.write(lang_file)


if __name__ == '__main__':
	generate_translation('es')

	