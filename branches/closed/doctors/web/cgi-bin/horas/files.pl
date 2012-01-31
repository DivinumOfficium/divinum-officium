#*** used files not shown as databases

#*** horas.ini (in cgi-bin-horas)
# loaded as initial preparation
# fills the value of variables
$htmlurl='../../www/horas';;  #URL reference to the www folder
$datafolder="$Bin/../../www/horas";;  #file reference to the www folder
$link='blue';;  #link color
$visitedlink='blue';; #visited link is the same
$dialogbackground='#eeeeee';; #dialog box background
$dialogfont='maroon';; #dialog font color
$border='1';;  #border for the cells of the printed office
$cookieexpire='+1y';;  #exoiration parameter for cookies
$savefiles='1';; #0=don't use edit for show files, 1-use edit (localhost only)

#*** horas.dialog  (in www/horas folder)
# script for dialogs and internal names

#parameters and screen fonts, size
[parameters]
Priest~>$priest~>Checkbutton;;
Building script~>$building~>Checkbutton;;
Language1~>$lang1~>Optionmenu~>languages;;
Language2~>$lang2~>Optionmenu~>languages;;
White background~>$whitebground~>Checkbutton;;
Text font~>$blackfont~>Entry~>12;;
Small black font~>$smallblack~>Entry~>12;;
Red font~>$redfont~>Entry~>12;;
Initiale font~>$initiale~>Entry~>12;;
Large font~>$largefont~>Entry~>12;;
Small font~>$smallfont~>Entry~>12;;
Title font~>$titlefont~>Entry~>12;;
Screen height~>$screenheight~>Entry~>12;;

#defaults for the widgets, unused
[general]
Only~>$only~>Checkbutton;;
Expand~>$expand~>Optionmenu~>{all,psalms,none,skeleton};;
Bilingual~>$bilingual~>Checkbutton;;

#for possible other languages
[languages]
Latin,English

#list of latin names as used
[horas]
Ante,Matutinum,Laudes,Prima,Tertia,Sexta,Nona,Vesperae,Completorium,Post

#folders for show flies = edit.pl
[folders]
Ordinarium,Psalterium,Tempora,Sancti,Commune,psalms,Rubrics,program

#name of communes
[communes]
C1,Commune Apostolorum, 
C1a,Commune Evangelistarum,
C2,Commune Unius Martyris,
C3,Commune Plurimorum Martyrum,
C4,Commune Confessoris Pontificis,
C4a,Commune Doctorum Pontificium,
C5,Commune Confessoris non Pontificis,
C6,Commune Virginum,
C7,Commune non Virginum,
C9,Commune Beatae Mariae Virginis,
C10,Beata Maria Virginis in Sabbato

#ranks for sancti
[Rank Sancti]
1=Simplex
2=Semiduplex
3=Duplex
4=Duplex majus
5=Duplex II Classis
6=Duplex I Classis

#ranks for tempora
[Rank Tempora]
1=Feria privilegiata
4=Dominica ordinaria
5=II class (Dominica Feast
6=I class (Dominica, Feria, Feast)

#*** horas setup (in www/horas folder)
#default values used by webdia and dialogcommon programs
#parameters default, used by setup.pl, for the user cookie is set
[parameters]
$priest='0';;
$building='0';;
$lang1='Latin';;
$lang2='English';;
$whitebground='0';;
$blackfont='black';;
$smallblack='-1 black';;
$redfont=' italic red';;
$initiale='+2 bold italic red';;
$largefont='+1 bold italic red';;
$smallfont='1 red';;
$titlefont='+1 red';;
$screenheight='1024';;
$check='bbttbcccccccn';;

#widget default, for the user cookie is set
[general]
$only='0';;
$expand='psalms';;
$check='bo';;





