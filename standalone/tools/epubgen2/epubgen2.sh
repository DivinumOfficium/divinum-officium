#!/bin/bash
#An alternative EPUB generator.
#
#This script generates the office texts in EPUB format for one or several years.
#Resulting files can easily be converted to MOBI format using kindlegen.
#
#It does not rely on ebook-convert to do the conversions, but the XHTML files
#(necessary for the EPUB format) are generated using customized perl scripts.
#Consequently, the resulting files are considerably smaller and the production
#is faster.
#
#Up-to-date generated files using 1962 rubrics are maintained on:
#http://breviarium.srubarovi.cz
#
#@author Stepan Srubar
#@date   2015-12-15

usage()
{
    cat << EOF

Usage: $0 [OPTIONS]

This script generates the office texts in EPUB format for one or several years.

OPTIONS:
   -h          Show this message

   -y NUMBER   The first year to generate the office for (e.g. 2017).
               Defaults to the current year.

   -t NUMBER   The last year to generate the office for (e.g. 2018).
               Defaults to the current year.

   -p          If specified, generate the officium for a priest
               ("Dominus Vobiscum" instead of "Domine, exaudi orationem meam").

   -v          If specified, generate the Parvum B.M.V. votive office.

   -m          Generate Mass propers in addition to office texts.

   -r RUBRICS  The rubrics to use. Defaults to 1960.
               Supported values are: 1570 1888 1906 DA 1955 1960 Newcal 1617 1930 1963 1951 Altovado Dominican

   -c FILENAME The cover image to use without path. It must be a file in the data
               directory. Defaults to "cover.jpg".

   -o PATH     The output directory. Defaults to "output".

   -l LANG     The language for the right side if required. Defaults to Latin.
                Valid Values: Bohemice Dansk Deutsch English Espanol Francais Italiano Latin Latin-Bea Magyar Polski Polski-Newer Portugues

   -b LANG     The base language in which to display the office. Defaults to Latin.

   -f          If specified, use "fancy" characters: [℟ ℣ +︎ ✠ ✙︎]

EOF

 #generation of a bilingual office is not yet fully implemented, so do not document this option until it is implemented.
 #-l      Also generate a second language (e.g. English, Deutsch, Italiano, Magyar, Polski).
}

#default values for input variables
ALANG=Latin
BLANG=Latin
ALANG_CODE=la
BLANG_CODE=la
YEAR_FROM=$(date +%Y)
YEAR_TO=$YEAR_FROM
PRIEST='' #has to be empty or '&priest=yes'
VOTIVE='' #='C12' for Parvum B.M.V.
MISSA='' #=1 to include Mass propers
CDUR=$(pwd)
EPUBDIR=$CDUR/output #output directory, defaults to "output" subdirectory in the folder this script is in.
COVER_FILENAME=cover.jpg #a jpg file name to serve as cover (it has to exist in SOURCEDATADIR) #ascensio.jpg
RUBRICS_CODE=1960
RUBRICS=Rubrics%201960%20%2D%201960
RUBRICS_NAME=
NOFANCYCHARS=1 #0 or 1; when 1, "fancy" characters such as  ℟ ℣ +︎ ✠ ✙︎ are replaced with R. V. + + +
OPTIONAL_KINDLEGEN_PATH=/usr/local/bin/kindlegen #full path to kindlegen executable, if exists, used to convert the resulting EPUB files to MOBI format as well

#constants
#supported rubrics as in Eofficium.pl
ALL_RUBRICS_CODES=(1570 1888 1906 DA 1955 1960 Newcal 1617 1930 1963 1951 Altovado Dominican)
ALL_RUBRICS=("Tridentine - 1570" "Tridentine - 1888" "Tridentine - 1906" "Divino Afflatu - 1954" "Reduced - 1955" "Rubrics 1960 - 1960" "Rubrics 1960 - 2020 USA" "Monastic - 1617" "Monastic - 1930" "Monastic - 1963" "Ordo Cisterciensis - 1951" "Ordo Cisterciensis - Abbatia B.M.V. de Altovado" "Ordo Praedicatorum - 1962")
ALL_RUBRICS_NAME=(_1570 _1888 _1906 _DA _1955 "" _NC _M1617 _M1930 Monastic _Cist _Altovado _OP)

# Languages
ALL_LANGUAGES_CODES=(cs da de en es fr it la la-bea hu nl pl pt pl-new)
ALL_LANGUAGES_NAMES=(Czech Danish German English Spanish French Italian Latin Latin-Bea Hungarian Dutch Polish Portuguese Polish-Newer)

YEAR_RE='^[0-9]+$'

#parse parameters
while getopts "hy:t:pvmr:c:o:l:b:f" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         y)
             YEAR_FROM=$OPTARG
             #make sure the value is a year number
             if ! [[ $YEAR_FROM =~ $YEAR_RE ]] ; then
               echo "Invalid year number." >&2; exit 1
             fi

             ;;
         t)
             YEAR_TO=$OPTARG
             #make sure the value is a year number
             if ! [[ $YEAR_TO =~ $YEAR_RE ]] ; then
               echo "Invalid year number." >&2; exit 1
             fi
             ;;
         p)
             PRIEST='&priest=yes'
             ;;
         v)
             VOTIVE='C12'
             ;;
         m)
             MISSA=1
             ;;
         r)
             RUBRICS_CODE=$OPTARG
             #make sure the value is one of the expected values
             for i in $(seq 0 ${#ALL_RUBRICS_CODES[@]}); do
                if [[ ${ALL_RUBRICS_CODES[$i]} == $RUBRICS_CODE ]]; then
                  RUBRICS=${ALL_RUBRICS[$i]}
                  RUBRICS_NAME=${ALL_RUBRICS_NAME[$i]}
                  continue 2
                fi
             done
             echo "Invalid version." >&2; exit 1
             ;;
         c)
             COVER_FILENAME=$OPTARG
             #value is validated later
             ;;
         o)
             EPUBDIR=$OPTARG
             #value is validated later
             ;;
         l)
             # l for "Language" to be translated to
             for i in $(seq 0 ${#ALL_LANGUAGES_NAMES[@]}); do
                if [[ ${ALL_LANGUAGES_NAMES[$i]} == $OPTARG ]]; then
                  BLANG=${ALL_LANGUAGES_NAMES[$i]}
                  BLANG_CODE=${ALL_LANGUAGES_CODES[$i]}
                  continue 2
                fi
             done
             echo "Invalid target language." >&2; exit 1
             ;;
         b)
             # b for "Base" language (Latin is the default)
             for i in $(seq 0 ${#ALL_LANGUAGES_NAMES[@]}); do
               if [[ ${ALL_LANGUAGES_NAMES[$i]} == $OPTARG ]]; then
                 ALANG=${ALL_LANGUAGES_NAMES[$i]}
                 ALANG_CODE=${ALL_LANGUAGES_CODES[$i]}
                 continue 2
               fi
             done
             echo "Invalid base language." >&2; exit 1
             ;;
         f)
             NOFANCYCHARS=0
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

MONTHNAMES=(Ianuarius Februarius Martius Aprilis Maius Iunius Iulius Augustus September October November December)
if [[ $MISSA ]]; then
	HORA_INDEX_LAST=8
	HORAS_FILENAMES=(1-Matutinum 2-Laudes 3-Prima 4-Tertia 5-Sexta 6-Nona 7-Vespera 8-Completorium 9-Missa)
	HORAS_NAMES=(Matutinum Laudes Prima Tertia Sexta Nona Vespera Completorium Missa)
	HORAS_NAMES_SHORT=(M L P T S N V C ☧)
else
	HORA_INDEX_LAST=7
	HORAS_FILENAMES=(1-Matutinum 2-Laudes 3-Prima 4-Tertia 5-Sexta 6-Nona 7-Vespera 8-Completorium)
	HORAS_NAMES=(Matutinum Laudes Prima Tertia Sexta Nona Vespera Completorium)
	HORAS_NAMES_SHORT=(M L P T S N V C)
fi

#other paths and file names, not specified by parameters
WDIR=$(mktemp -d) #temporary working directory
SOURCEDATADIR=$CDUR/data #dir that contains s.css, and cover image as specified below
EOFFICCIUMCMD=$CDUR/EofficiumXhtml.pl #the command to launch the genarator
EMISSACMD=$CDUR/../../../web/cgi-bin/missa/Emissa.pl #the command to launch the missa genarator

#verify the existence of cover file (even if it is the default value)
if [[ ! -e $SOURCEDATADIR/$COVER_FILENAME ]]
then
	echo "Cover image not found in: $SOURCEDATADIR/$COVER_FILENAME" >&2; exit 1
fi

#check if output directory exists and attempt to create it if it does not
if [[ ! -d $EPUBDIR ]]
then
	mkdir $EPUBDIR
	if [[ ! -d $EPUBDIR ]]
	then
		echo "Output path does not exist or is not a directory (and could not be created): $EPUBDIR" >&2; exit 1
	fi
fi

#handle the case when "from" year is greater than "to" year
#(happens when the script is invoked only with the -y parameter without -t)
if ! [[ $YEAR_FROM -lt $YEAR_TO ]] ; then
YEAR_TO=$YEAR_FROM
fi

#################################################################################################################
#  auxiliary functions (iteration and formating)
#################################################################################################################

#This convenience function uses the following variables
#$DAY, $MONTH, $YEAR, $H, $RUBRICS_NAME
#to set the  $FILENAME, $DATE and $ITEM_ID variables.
formatFilename() {
	FILENAME=$MONTH-$DAY-$YEAR-${HORAS_FILENAMES[${H}]}.html

	TOC_FILENAME_YEAR="toc$YEAR$RUBRICS_NAME.html"
	TOC_FILENAME_MONTH="toc$YEAR-$MONTH$RUBRICS_NAME.html"

	#format as expected by script
	DATE_SCRIPT=$MONTH-$DAY-$YEAR

	#used in OPF on two places
	ITEM_ID="h$MONTH$DAY$H"
}


foreachMonthInRange() {
	#might fail if $1 is a complex command, in that case it has to be replaced with nested loops
	foreachYear "foreachMonthInYear $1"
}

foreachYear() {
	for YEAR in $(seq $YEAR_FROM $YEAR_TO); do
		formatFilename
		$1
	done
}

#This method calls $1 (the parameter given to this method - a command) for every month in the year that is set in $YEAR variable.
foreachMonthInYear() {
	MONTH_NUM_INDEX=-1 #note we cannot count using MONTH, because it is zero padded (and bash consides it an octal literal)
	for MONTH in $(seq -w 12); do
		MONTH_NUM_INDEX=1+$MONTH_NUM_INDEX

		formatFilename #needed to set the TOC filename
		$1
	done
}

foreachHourInDay() {
	for H in $(seq 0 $HORA_INDEX_LAST); do
		formatFilename
		$1
	done
}

foreachDayInMonth() {
	DAYN=$(cal $MONTH $YEAR|grep -E -v [a-z]|wc -w)
	for DAY in $(seq -w $DAYN); do
		formatFilename
		$1
	done
}

foreachDayInYear() {
	MONTH_NUM_INDEX=-1 #note we cannot count using MONTH, because it is zero padded (and bash consides it an octal literal)
	for MONTH in $(seq -w 12); do
		MONTH_NUM_INDEX=1+$MONTH_NUM_INDEX

		DAYN=$(cal $MONTH $YEAR|grep -E -v [a-z]|wc -w)
		for DAY in $(seq -w $DAYN); do
				formatFilename
				$1
		done
	done
}

foreachHourInYear() {
	MONTH_NUM_INDEX=-1 #note we cannot count using MONTH, because it is zero padded (and bash consides it an octal literal)
	for MONTH in $(seq -w 12); do
		MONTH_NUM_INDEX=1+$MONTH_NUM_INDEX

		DAYN=$(cal $MONTH $YEAR|grep -E -v [a-z]|wc -w)
		for DAY in $(seq -w $DAYN); do
			for H in $(seq 0 $HORA_INDEX_LAST); do
				formatFilename
				$1
			done
		done
	done
}

foreachHourInMonth() {
	foreachDayInMonth "foreachHourInDay $1"
}

#This method calls $1 for every hour in a month (the $MONTH and $YEAR variables have to be set).
#($DAY, $H $FILENAME, $DATE are set accordingly at every invocation.)
foreachHourInRange() {

	#with too nested iteration the quoting causes chaos
	#foreachYear "foreachMonthInYear \"foreachDayInMonth foreachHourInDay $1\""
	#so using this instead

	for YEAR in $(seq $YEAR_FROM $YEAR_TO); do
		MONTH_NUM_INDEX=-1 #note we cannot count using MONTH, because it is zero padded (and bash consides it an octal literal)
		for MONTH in $(seq -w 12); do
			MONTH_NUM_INDEX=1+$MONTH_NUM_INDEX
			DAYN=$(cal $MONTH $YEAR|grep -E -v [a-z]|wc -w)
			for DAY in $(seq -w $DAYN); do
				for H in $(seq 0 $HORA_INDEX_LAST); do
					formatFilename
					$1 &
				done
				wait
			done
		done
	done

}

#################################################################################################################
#  Generation of the hours
#################################################################################################################

generateHour() {
	echo -ne "Generating $FILENAME                \r" # with spaces to clean the line
	if [[ ${H} -eq 8 && $MISSA ]]; then
		$EMISSACMD "date=$DATE_SCRIPT&command=&version=$RUBRICS&lang1=$ALANG&lang2=$BLANG&nofancychars=$NOFANCYCHARS" > $WDIR/$FILENAME
	else
		$EOFFICCIUMCMD "date1=$DATE_SCRIPT&command=pray${HORAS_NAMES[${H}]}&version=$RUBRICS&testmode=regular&lang1=$ALANG&lang2=$BLANG&votive=$VOTIVE$PRIEST&linkmissa=$MISSA&nofancychars=$NOFANCYCHARS" > $WDIR/$FILENAME
	fi
}

generateHours() {
	echo -e "\033[1m:: Starting to generate hours\033[0m"
	foreachHourInRange generateHour
	echo ""
	echo -e "\033[1m:: Finished the generation of hours\033[0m"
}


#################################################################################################################
#  TOC creation
#################################################################################################################


printTOCEntry() {
		printf "<td><a href=\"$FILENAME\">${HORAS_NAMES_SHORT[${H}]}</a></td>\n"
}

printTOCDay() {
		printf "<tr><td>$DAY</td>\n"
		foreachHourInDay printTOCEntry
		printf "</tr>\n"
}

outputMonthTOC() {
	printf "<a name=\"m$MONTH\"><h1>${MONTHNAMES[$MONTH_NUM_INDEX]}</h1></a><table>\n"
	foreachDayInMonth printTOCDay
	printf '</table>\n'

}

printTOC_Header() {
  lang_codes=""
  if [[ "$ALANG" != "Latin" ]] || [[ "$ALANG" != "$BLANG" ]]; then
    lang_codes=" (${ALANG_CODE}"
    if [[ "$BLANG" != "$ALANG" ]]; then
      lang_codes="$lang_codes-${BLANG_CODE})"
    else
      lang_codes="$lang_codes)"
    fi
  fi

	printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"la\">
<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>Breviarium $YEAR-$MONTH$RUBRICS_NAME$lang_codes</title></head><body><div>"
}
printTOC_Footer() {
	printf '</div></body></html>\n'
}


outputMonthToFile() {
	cd $WDIR
	exec 6>&1
	exec > $TOC_FILENAME_MONTH
	printTOC_Header
	outputMonthTOC
	printTOC_Footer
	exec 1>&6 6>&-
}


outputYearToFile() {
	cd $WDIR
	exec 6>&1
	exec > $TOC_FILENAME_YEAR
	printTOC_Header

	#months links
	for M in $(seq -w 1 12); do
		printf "<a href=\"#m$M\">$M</a> "
	done

  foreachMonthInYear outputMonthTOC
  printTOC_Footer
  exec 1>&6 6>&-
}


generateTOCs() {
	echo -e "\033[1m:: Starting to create TOCs\033[0m"

	#generate OPF per month
	foreachMonthInRange outputMonthToFile

	#generate OPF per year
	foreachYear outputYearToFile

	echo -e "\033[1m:: Finished the creating of TOCs\033[0m"
}

#################################################################################################################
#  OPF creation
#################################################################################################################
outputOPFEntry() {
	printf "<item id=\"$ITEM_ID\" media-type=\"application/xhtml+xml\" href=\"$FILENAME\"></item>\n"
}

outputOPFSpineEntry() {
	printf "<itemref idref=\"$ITEM_ID\"/>"
}


outputMonthOPF() {
	foreachHourInMonth outputOPFEntry
}

outputMonthOPFSpine() {
	foreachHourInMonth outputOPFSpineEntry
}

#Expects the second part of the title as a parameter.
printOPF_Header() {
  lang_disp=""
  if [[ "$ALANG" != "Latin" ]] || [[ "$ALANG" != "$BLANG}" ]]; then
    lang_disp=" ($ALANG"
    if [[ "$BLANG" != "$ALANG" ]]; then
      lang_disp="$lang_disp-$BLANG)"
    else
      lang_disp="$lang_disp)"
    fi
  fi

printf '<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="uuid_id" version="2.0">
  <metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
<meta name="cover" content="cover"/><dc:date>'
date +"%Y-%m-%dT%H:%M:%S:%z"
printf "</dc:date><dc:title>Breviarium $1$lang_disp</dc:title>
<dc:creator>Divinum Officium</dc:creator>
<dc:publisher></dc:publisher>
<dc:subject></dc:subject>
<dc:description></dc:description>
<dc:created>"
date +"%Y-%m-%dT%H:%M:%S:%z"
printf "</dc:created>
<dc:language>$ALANG_CODE</dc:language>"
if [[ "$ALANG" != "$BLANG" ]]; then
  printf "
<dc:language>$BLANG_CODE</dc:language>"
fi
printf "
<dc:identifier id=\"uuid_id\" opf:scheme=\"uuid\">f85e2f34-fa9b-4211-ad58-2c74dc43861f</dc:identifier>
</metadata>
<manifest>
<item id=\"toc\" media-type=\"application/xhtml+xml\" href=\"$TOC_FILENAME\" />
<item id=\"css\" href=\"s.css\" media-type=\"text/css\" />
<item id=\"cover\" href=\"$COVER_FILENAME\"  media-type=\"image/jpeg\" />
<item href=\"titlepage.xhtml\" id=\"titlepage\" media-type=\"application/xhtml+xml\" />
<item href=\"about.xhtml\" id=\"aboutpage\" media-type=\"application/xhtml+xml\" />
"
}

printOPF_Middle() {
	printf "
	<item id=\"ncx\" href=\"toc.ncx\" media-type=\"application/x-dtbncx+xml\" />
	</manifest>
<spine toc=\"ncx\">
	<itemref idref=\"titlepage\"/>
    <itemref idref=\"toc\"/>"
}

printOPF_Footer() {
	printf "
	<itemref idref=\"aboutpage\"/>
</spine>
<guide>
	<reference type=\"title-page\" title=\"Title Page\" href=\"titlepage.xhtml\" />
    <reference type=\"toc\" title=\"Table of Contents\" href=\"$TOC_FILENAME\" />
</guide>
</package>"
}

outputMonthToFileOPF() {
	cd $WDIR
	exec 6>&1
	exec > "breviarium$YEAR-$MONTH$RUBRICS_NAME.opf"
	TOC_FILENAME=$TOC_FILENAME_MONTH

  printOPF_Header "$YEAR-$MONTH$RUBRICS_NAME"
  outputMonthOPF
  printOPF_Middle
  outputMonthOPFSpine
  printOPF_Footer

  exec 1>&6 6>&-
}

outputYearToFileOPF() {
	cd $WDIR
	exec 6>&1
  exec > "breviarium$YEAR$RUBRICS_NAME.opf"

  TOC_FILENAME=$TOC_FILENAME_YEAR
  printOPF_Header "$YEAR$RUBRICS_NAME"
  foreachMonthInYear outputMonthOPF
  printOPF_Middle
  foreachMonthInYear outputMonthOPFSpine
  printOPF_Footer
  exec 1>&6 6>&-
}

generateOPF() {
	echo -e "\033[1m:: Starting to create OPFs\033[0m"

	#generate OPF per month
	foreachMonthInRange outputMonthToFileOPF

	#generate OPF per year
	foreachYear outputYearToFileOPF

	echo -e "\033[1m:: Finished the creating of OPFs\033[0m"
}

#Expects OPF_FILENAME to be set.
initEPUB() {

	#make sure directory "META-INF" exists
	if [ ! -d "$WDIR/META-INF" ]
	then
		mkdir "$WDIR/META-INF"
	fi

	#copy the needed files into the work directory
	cp $SOURCEDATADIR/s.css $SOURCEDATADIR/$COVER_FILENAME $SOURCEDATADIR/about.xhtml $WDIR
	cp $WDIR/$OPF_FILENAME $WDIR/content.opf

	#mimetype
	echo 'application/epub+zip' > "$WDIR/mimetype"

	#container.xml

	cat  >"$WDIR/META-INF/container.xml" <<CONTAINER
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles>
<rootfile full-path="content.opf" media-type="application/oebps-package+xml"/>
</rootfiles>
</container>
CONTAINER

	#toc.ncx
	cat >"$WDIR/toc.ncx" <<CONTAINER
<?xml version='1.0' encoding='utf-8'?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="la">
  <head>
    <meta content="f85e2f34-fa9b-4211-ad58-2c74dc43861f" name="dtb:uid"/>
    <meta content="2" name="dtb:depth"/>
    <meta content="0" name="dtb:totalPageCount"/>
    <meta content="0" name="dtb:maxPageNumber"/>
  </head>
  <docTitle>
    <text>$TITLE</text>
  </docTitle>
  <navMap>
	<navPoint id="navPoint-1" playOrder="1">
	<navLabel>
	<text>Title</text>
	</navLabel>
	<content src="titlepage.xhtml"/>
	</navPoint>
	<navPoint id="navPoint-2" playOrder="2">
	<navLabel>
	<text>TOC</text>
	</navLabel>
	<content src="$TOC_FILENAME"/>
	</navPoint>

CONTAINER
	#will be finished later

	#titlepage.xhtml
cat >"$WDIR/titlepage.xhtml" <<CONTAINER
<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="calibre:cover" content="true"/>
        <title>Cover</title>
        <style type="text/css" title="override_css">
            @page {padding: 0pt; margin:0pt}
            body { text-align: center; padding:0pt; margin: 0pt; }
        </style>
    </head>
    <body>
        <div>
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" height="100%" viewBox="0 0 590 750" preserveAspectRatio="none">
                <image width="590" height="750" xlink:href="$COVER_FILENAME"/>
            </svg>
        </div>
    </body>
</html>
CONTAINER
}

outputTOCNCXEntry() {
	PLAYORDER_NUM=$(( PLAYORDER_NUM+1 ))
	cat >>"$WDIR/toc.ncx" <<CONTAINER
	<navPoint id="navPoint-$(( PLAYORDER_NUM ))" playOrder="$(( PLAYORDER_NUM ))">
	<navLabel>
	<text>$MONTH - $DAY</text>
	</navLabel>
	<content src="$FILENAME" />
	</navPoint>
CONTAINER
}

initEPUB_End() {
	PLAYORDER_NUM=$(( PLAYORDER_NUM+1 ))
	cat >>"$WDIR/toc.ncx" <<CONTAINER
	<navPoint id="navPoint-$(( PLAYORDER_NUM ))" playOrder="$(( PLAYORDER_NUM ))">
	<navLabel>
	<text>About</text>
	</navLabel>
	<content src="about.xhtml" />
	</navPoint>
  </navMap>
</ncx>
CONTAINER

}

epubCleanup() {
	rm "$WDIR/META-INF/container.xml"
	rmdir "$WDIR/META-INF"
}

packEPUB() {
	cd "$WDIR"
	#remove potentially existing epub
	:>$EPUB_FILENAME
	rm $EPUB_FILENAME

  #mimetype goes first, uncompressed
  zip -q -X0 "$EPUB_FILENAME" "mimetype"

  #then all other files
  zip -q -Xur9D "$EPUB_FILENAME" META-INF/container.xml toc.ncx "$TOC_FILENAME" titlepage.xhtml about.xhtml content.opf s.css "$COVER_FILENAME" -@ <filelist
}


makeEPUBfilelistEntry() {
	echo "$FILENAME" >> "$WDIR/filelist"
}

makeEPUBfilelistMonth() {
	:> "$WDIR/filelist"
	foreachHourInMonth makeEPUBfilelistEntry
}

makeEPUBfilelistYear() {
	:> "$WDIR/filelist"
	foreachHourInYear makeEPUBfilelistEntry
}

createEPUBMonth() {
	OPF_FILENAME="breviarium$YEAR-$MONTH$RUBRICS_NAME.opf"
	EPUB_FILENAME="$EPUBDIR/breviarium$YEAR-$MONTH$RUBRICS_NAME.epub"
	TOC_FILENAME=$TOC_FILENAME_MONTH
	TITLE="Divinum Officium$RUBRICS_NAME - $YEAR-$MONTH"

	initEPUB
	PLAYORDER_NUM=2
	H=0
	foreachDayInMonth outputTOCNCXEntry
	initEPUB_End 1>&2 "${EPUB_FILENAME}.log"

	makeEPUBfilelistMonth 1>&2 "${EPUB_FILENAME}.log"
	packEPUB 1>&2 "${EPUB_FILENAME}.log"
	#epubCleanup
}

createEPUBYear() {
  lang_name=""
  if [[ "$ALANG" != "Latin" ]] || [[ "$ALANG" != "$BLANG" ]]; then
    lang_name=" ($ALANG"
    if [[ "$BLANG" != "$ALANG" ]]; then
      lang_name="$lang_codes-$BLANG)"
    else
      lang_name="$lang_codes)"
    fi
  fi
	OPF_FILENAME="breviarium$YEAR$RUBRICS_NAME.opf"
	EPUB_FILENAME="$EPUBDIR/breviarium$YEAR$RUBRICS_NAME.epub"
	TOC_FILENAME=$TOC_FILENAME_YEAR
	TITLE="Divinum Officium$RUBRICS_NAME - $YEAR - $lang_name"

	initEPUB
	PLAYORDER_NUM=0
	H=0
	foreachDayInYear outputTOCNCXEntry
	initEPUB_End 1>&2 "${EPUB_FILENAME}.log"

	makeEPUBfilelistYear 1>&2 "${EPUB_FILENAME}.log"
	packEPUB 1>&2 "${EPUB_FILENAME}.log"
	epubCleanup
}

createEPUBs() {
	echo -e "\033[1m:: Starting to create EPUBs for each month\033[0m"
	foreachMonthInRange createEPUBMonth
	echo -e "\033[1m:: Starting to create EPUBs for each year\033[0m"
	foreachYear createEPUBYear
	echo -e "\033[1m:: Finished the creation of EPUBs\033[0m"
}


#################################################################################################################
#  MOBI format
#################################################################################################################

convertMOBIMonth() {
	EPUB_FILENAME="$EPUBDIR/breviarium$YEAR-$MONTH$RUBRICS_NAME.epub"
	echo -ne "Converting $EPUB_FILENAME                \r" >> "${EPUBDIR}/kindlegen.log"
	$OPTIONAL_KINDLEGEN_PATH $EPUB_FILENAME &>> "${EPUBDIR}/kindlegen.log"
	echo -ne "Finished Converting $EPUB_FILENAME                \r" >> "${EPUBDIR}/kindlegen.log"
  echo -ne "--------------------------------------------------\r" >> "${EPUBDIR}/kindlegen.log"
}

convertMOBIYear() {
	EPUB_FILENAME="$EPUBDIR/breviarium$YEAR$RUBRICS_NAME.epub"
	echo -ne "Converting $EPUB_FILENAME                \r" >> "${EPUBDIR}/kindlegen.log"
	$OPTIONAL_KINDLEGEN_PATH $EPUB_FILENAME &>> "${EPUBDIR}/kindlegen.log"
	echo -ne "Finished Converting $EPUB_FILENAME                \r" >> "${EPUBDIR}/kindlegen.log"
	echo -ne "--------------------------------------------------\r" >> "${EPUBDIR}/kindlegen.log"
}

createMOBIs() {
	if [[ ! -e "$OPTIONAL_KINDLEGEN_PATH" ]]
	then
		echo "\033[1m:: KindleGen not found in ${OPTIONAL_KINDLEGEN_PATH}, skipping the conversion to of MOBI format. \033[0m"
	else
	  # clean up log file to start fresh...
    :> "${EPUBDIR}/kindlegen.log"
		echo -e "\033[1m:: Starting the conversion to MOBI format for each month\033[0m"
		foreachMonthInRange convertMOBIMonth
		echo -e "\033[1m:: Starting the conversion to MOBI format for each year\033[0m"
		foreachYear convertMOBIYear
		echo -e "\033[1m:: Finished the conversion to MOBI format\033[0m"
	fi
}

#################################################################################################################
#  launch
#################################################################################################################
generateHours #generate the main HTML files
generateTOCs #generate Table Of Content main HTML pages (used by both EPUB and MOBI formats)
generateOPF  #generate OPF files (descriptors needed both for the EPUB and for the kindlegen to generate MOBI)
createEPUBs
createMOBIs
