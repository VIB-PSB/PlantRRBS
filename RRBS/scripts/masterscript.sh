#!/bin/bash
# run this using "sh masterscript.sh"

# copy this file to the Chrxx folder, and change the variable chr to that chromosome
chr=Chr09

R_OPTS=--no-save --no-restore --no-init-file --no-site-file # vanilla, but with --environ

R ${R_OPTS} -e "library(knitr);chromosome <- ${chr};knit2html('RRBS.Rmd')"

R ${R_OPTS} -e 'library(markdown);markdownToHTML("RRBS.md", "RRBS.html")'
