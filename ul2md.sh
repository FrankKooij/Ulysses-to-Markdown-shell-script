#!/bin/bash
# This script will traverse through all .ulysses packages in all folders
# transforming all Content.xml to Markdown using XSLT: ulysses2md.xslt,
# and then moving all .md-files to a pure Markdown folder.
# Embedded image files will not be included :(
# (c) (MIT) 201j, @rovest, 2016-08-16 at 08:07 EDT

# cd "%~dp0"

# First remove old Markdown folder:
rm -r "Markdown from Ulysses XML"

# Traverse through all .ulysses packages and run XSLT script on each Content.xml
# Result will be written in parent folder:
find . -iname "*.ulysses" -exec sh -c 'xsltproc ulysses2md.xslt "$0/Content.xml" > "$0.md"' {} \;

# Move all markdown files to new folder in current folder using rsync:
rsync -r -t -v --include '*.ulysses.md' --exclude '*.*' --remove-source-files "." "Markdown from Ulysses XML"

# Rename all *.ulysses.md files to *.md or *.txt:
# find . -iname "*.ulysses.md" -exec bash -c 'mv "$0" "${0%\.ulysses.md}.md"' {} \;
find . -iname "*.ulysses.md" -exec bash -c 'mv "$0" "${0%\.ulysses.md}.txt"' {} \;

echo ===============================================================================================
echo  All Ulysses sheets are now converted to Markdown in folder: '"Markdown from Ulysses XML"'
echo ===============================================================================================
