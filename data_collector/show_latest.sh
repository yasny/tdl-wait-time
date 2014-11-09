#!/bin/bash
echo "### TOKYO DISNEYLAND ###"
ls -1tr tdl/*.dat | tail -n1 | xargs cat | sed "s/,,/,-,/g;s/,-,,/,-,-,/g" | column -s"," -t
echo "### TOKYO DISNEYSEA ###"
ls -1tr tds/*.dat | tail -n1 | xargs cat | sed "s/,,/,-,/g;s/,-,,/,-,-,/g" | column -s"," -t