powershell -command "& { iwr https://github.com/powerline/fonts/archive/master.zip -OutFile ~\fonts.zip }"
Expand-Archive -Path ~\fonts.zip -DestinationPath ~

Set-ExecutionPolicy Bypass
~\fonts-master\install.ps1 deja*
Set-ExecutionPolicy Default

# Check for viewed font:
echo -e "Powerline glyphs:\n\
Code points Glyphe  Description                Old code point
U+E0A0      \xee\x82\xa0       Version control branch     (U+2B60 \xe2\xad\xa0 )\n\
U+E0A1      \xee\x82\xa1       LN (line) symbol           (U+2B61 \xe2\xad\xa1 )\n\
U+E0A2      \xee\x82\xa2       Closed padlock             (U+2B64 \xe2\xad\xa4 )\n\
U+E0B0      \xee\x82\xb0       Rightwards black arrowhead (U+2B80 \xe2\xae\x80 )\n\
U+E0B1      \xee\x82\xb1       Rightwards arrowhead       (U+2B81 \xe2\xae\x81 )\n\
U+E0B2      \xee\x82\xb2       Leftwards black arrowhead  (U+2B82 \xe2\xae\x82 )\n\
U+E0B3      \xee\x82\xb3       Leftwards arrowhead        (U+2B83 \xe2\xae\x83 )\n\
"

# Checking fonts:
~\fonts-master\install.ps1 deja* -WhatIf
What if: Performing the operation "Install Font" on target "ProFont Bold For Powerline.ttf".
What if: Performing the operation "Install Font" on target "ProFont For Powerline.ttf".