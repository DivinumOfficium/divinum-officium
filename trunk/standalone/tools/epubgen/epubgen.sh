#!/bin/bash

display_usage() {
    echo "Usage: $0 MONTH YEAR LANG"
    echo "Create a monthly Divinum Officium in EPUB format."
    echo -e "\n\nMandatory arguments:"
    echo -e "  MONTH\t\tThe month in two-digit format"
    echo -e "  YEAR\t\tThe year in four-digit format"
    echo -e "  LANG\t\tThe second language (English, Italiano, Magyar)"
}

if [ $# -ne 3 ]; then
    echo -e "Too few arguments, you must specify three arguments: MONTH, YEAR and LANG.\n"
    display_usage
    exit 1
fi

mformat='^[0-9][0-9]$'
if ! [[ $1 =~ $mformat ]]; then
    echo -e "Invalid month format, the month must be in two-digit format.\n"
    display_usage
    exit 1
fi

MONTH=$1

yformat='^[0-9][0-9][0-9][0-9]$'
if ! [[ $2 =~ $yformat ]]; then
    echo -e "Invalid year format, the year must be in four-digit format.\n"
    display_usage
    exit 1
fi

YEAR=$2

case $3 in
    English)
	BLANG=$3
	;;
    Italiano)
	BLANG=$3
	;;
    Magyar)
	BLANG=$3
	;;
    "")
	echo -e "Language not specified. You must specify a language.\n"
	display_usage
	exit 1
	;;
    *)
	echo -e "Invalid language specified.\n"
	display_usage
	exit 1
	;;
esac

CDUR=$(pwd)
WDIR=$(mktemp -d)
DAYN=$(cal $MONTH $YEAR|egrep -v [a-z]|wc -w)

echo -e "\e[1m:: Starting to generate hours\e[0m"
cd ../../../web/cgi-bin/horas
for DAY in $(seq -w $DAYN); do
    echo -ne "Day $DAY/$DAYN\r"
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayMatutinum&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-1-Matutinum.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayLaudes&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-2-Laudes.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayPrima&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-3-Prima.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayTertia&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-4-Tertia.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=praySexta&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-5-Sexta.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayNona&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-6-Nona.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayVespera&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-7-Vespera.html 2> /dev/null;
    ./Eofficium.pl "date1=$MONTH-$DAY-$YEAR&command=prayCompletorium&version=Rubrics%201960&testmode=regular&lang2=$BLANG&votive=" > $WDIR/$MONTH-$DAY-$YEAR-8-Completorium.html 2> /dev/null;
done
echo ""
echo -e "\e[1m:: Finished the generation of hours\e[0m"

echo -e "\e[1m:: Starting to create index.html\e[0m"
cd $WDIR
exec 6>&1
exec > index.html
printf "<html>\n<head><title>Index Horarum</title></head>\n<body style=\"font-family:'Gentium Book Basic';\">\n<h1>Index Horarum</h1>"
for DAY in $(seq -w $DAYN); do
    printf "$MONTH-$DAY-$YEAR"
    printf "<ul>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-1-Matutinum.html">Matutinum</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-2-Laudes.html">Laudes</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-3-Prima.html">Prima</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-4-Tertia.html">Tertia</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-5-Sexta.html">Sexta</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-6-Nona.html">Nona</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-7-Vespera.html">Vespera</a></li>\n"
    printf "<li><a href="$MONTH-$DAY-$YEAR-8-Completorium.html">Completorium</a></li>\n"
    printf "</ul><br>\n"
done
printf '</body>\n</html>\n'
exec 1>&6 6>&-
echo -e "\e[1m:: Finished the creating of index.html\e[0m"

echo -e "\e[1m:: Starting to create EPUB file\e[0m"
ebook-convert index.html "../Divinum Officium - $BLANG ($YEAR-$MONTH).epub" \
	--disable-font-rescaling \
	--margin-bottom 15 --margin-left 15 --margin-right 15 --margin-top 15 \
	--minimum-line-height 130 --embed-all-fonts --subset-embedded-fonts \
	--chapter / --chapter-mark none --page-breaks-before / \
	--author-sort 'Divinum Officium Project' --authors 'Divinum Officium Project' \
	--language la --publisher 'Divinum Officium Project' \
	--tags "Divine Office, Breviarium, Zsolozsma" \
	--title "Divinum Officium ($YEAR-$MONTH)" --dont-split-on-page-breaks \
	--level1-toc '//h:title' \
	--no-chapters-in-toc --disable-dehyphenate \
	--disable-delete-blank-paragraphs --disable-fix-indents \
	--disable-format-scene-breaks --disable-unwrap-lines \
	--disable-italicize-common-cases --keep-ligatures \
	--disable-markup-chapter-headings --disable-renumber-headings \
	--disable-remove-fake-margins || exit 1
echo -e "\e[1m:: Finished the creating of EPUB file\e[0m"

cd $CDIR
rm -Rf $WDIR
