#!/usr/bin/env bash
#
# Usage :
# ./corrects_french_typo.sh /path/Sancti/*.txt
#
# If a file must be corrected, the original version is saved
# with the `.old` extension.
#
set -e

for file in $@
do
    old="$file".old
    mv "$file" "$old"
    # the `s# x# x#g;` with x in {: ; ! ?} commands replace normal spaces with non-breakable spaces
    sed -e "s#'#’#g;s# :# :#g;s# ;# ;#g;s# !# !#g;s# ?# ?#g;s#O #Ô #g;s#Epître#Épître#;s#Evangile#Évangile#g;" "$old" > "$file"
    diff "$file" "$old" && rm "$old"
done

exit 0
