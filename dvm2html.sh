#!/bin/sh
cat "$1" | sed '/<\?xml version/d' | sed 's/^[\ \t]*//g' | tr -d '\n\r' | sed 's/columns>/tr>\n/g' | sed 's/<column name="/\t<td>/g' | sed 's/\"\/>/<\/td>\n/g' | sed 's/<cell/\t<td/g' | sed 's/<\/cell>/<\/td>\n/g' | sed 's/<dvm.*dvm">/<html><head\/><body><table>\n/g' | sed 's/<\/dvm>/<\/table><\/body><\/html>/g'| sed 's/<rows>//g'| sed 's/<\/rows>//g' | sed 's/row>/tr>\n/g' | sed 's/<description>.*<\/description>//g'