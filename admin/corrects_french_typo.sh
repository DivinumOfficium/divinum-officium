#!/usr/bin/env bash
# usage:
# ./corrects_french_typo.sh Sancti/01-15.txt
set -e

file="$1"
mv "$file" "$file".old

# the `s# x# x#g;` with x in {: ; ! ?} commands replace normal spaces with non-breakable spaces
sed -e "s#'#’#g;s# :# :#g;s# ;# ;#g;s# !# !#g;s# ?# ?#g;s#O #Ô #g;s#Epître#Épître#;s#Evangile#Évangile#g;" "$file".old > "$file"

exit 0;
