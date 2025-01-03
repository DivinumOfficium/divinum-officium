#!/usr/bin/perl
use utf8;

use FindBin qw($Bin);
use lib "$Bin/..";

# Defines ScriptFunc and ScriptShortFunc attributes.
#use horas::Scripting;

#*** translate_cz()
# translates a line from Latin to Czech
# written for Necrologium from Vyšší Brod, CZ (Altovadum)
# will hardly work on anything else...
sub translate_cz : ScriptFunc {

  my $line = shift;

  $line =~ s/\t\t/  /;
  $line =~ s/ \t/  /;
  $line =~ s/\t/ /g;

  $line =~ s/Purissimi Cordis B\.M\.V\./Nejčistšího Srdce Panny Marie/ig;
  $line =~ s/Sancti Joannis Nepomuceni/Svatého Jana Nepomuckého/ig;

  $line =~ s/A\.R\.P\./Veledůstojný Otec/ig;
  $line =~ s/A\.R\.D\./Veledůstojný Pán/ig;
  $line =~ s/A\.R\. et Ven.* P\./Veledůstojný a ctihodný Otec/ig;
  $line =~ s/A\.R\. ac Ven.* P\./Veledůstojný a ctihodný Otec/ig;
  $line =~ s/Venerabilis P\./Veledůstojný Otec/ig;
  $line =~ s/Venerabilis/Ctihodný/g;
  $line =~ s/RR\. ac Eminentissimus Domnus/Nejdůstojnější a Nejjasnější Pán/ig;
  $line =~ s/venerabilis/ctihodný/g;
  $line =~ s/RR\. ?Domnus/Nejdůstojnější Pán/ig;
  $line =~ s/Domni/Pana/ig;
  $line =~ s/RR\./Nejdůstojnější/ig;
  $line =~ s/Reverendissimi Domni|RR\. Domni/Nejdůstojnějšího Pána/ig;

  $line =~ s/professi Altovadensis/vyšebrodského profese/ig;
  $line =~ s/Altovadensis/vyšebrodský/ig;
  $line =~ s/Altovadensi/vyšebrodském/ig;
  $line =~ s/Zarae/ve Žďáru/ig;
  $line =~ s/Zarensis/žďárský/ig;
  $line =~ s/Ossecensis|Ossencensis/osecký/ig;
  $line =~ s/Ossecii|Osecii|in Ossegg/v Oseku/ig;
  $line =~ s/circa Ossecum/v okolí Oseka/ig;
  $line =~ s/Alt-Ossegg/Starý Osek/ig;
  $line =~ s/Lambacensis/lambašský/ig;
  $line =~ s/in Lambach/v Lambachu/ig;
  $line =~ s/in Schlüchtern/v klášteře Schlüchtern/ig;
  $line =~ s/Plagensis/ze Schläglu/ig;
  $line =~ s/Plaga/Schlägl/ig;
  $line =~ s/, Aulae.Regiae|de Aula Regia/, na Zbraslavi/ig;
  $line =~ s/Aulae.Regiae/zbraslavský/ig;
  $line =~ s/in Aula.Regia/na Zbraslavi/ig;
  $line =~ s/Sanctae.Coronae|Sacrae Spinae Coronae/zlatokorunský/ig;
  $line =~ s/in Sancta Corona/ve Zlaté Koruně/ig;
  $line =~ s/\. Neo-Cell(æ|ae)|\. Nov(æ|ae)-Cell(æ|ae)/. V Neuzelle/ig;
  $line =~ s/Neo-Cellae|Neocellensis|Novae-Cellae|Neo-Cellensis/z Neuzelle/ig;
  $line =~ s/Plassensis/plasský/ig;
  $line =~ s/Plassii|Plasii/v Plasích/ig;
  $line =~ s/Portae.Coeli/v Porta Coeli/ig;

  #$line =~ s/Montis Pomarii|ad Montem Pomarium/z kláštera Baumgartenberg/ig;
  $line =~ s/Montis Pomarii|ad Montem Pomarium/z Baumgartenbergu/ig;
  $line =~ s/Wellehradensis/velehradský/ig;
  $line =~ s/. Wellehradii/ Na Velehradě/ig;
  $line =~ s/Wellehradii/na Velehradě/ig;
  $line =~ s/Hilariae/ve Wilheringu/ig;
  $line =~ s/monasterii Sedlicensis|monasterii Sedlecensis/sedleckého kláštera/ig;
  $line =~ s/Sedlicensis|Sedlecensis/sedlecký/ig;
  $line =~ s/in Valle Mariae/v klášteře Marienthal/ig;
  $line =~ s/in Waldsassen/v klášteře Waldsassen/ig;
  $line =~ s/Sionensis/strahovský/ig;
  $line =~ s/Clarae.Vallis/ze Zwettlu/ig;
  $line =~ s/sacrosanctae Crucis/přesvatého Kříže/ig;
  $line =~ s/ad Scottos Vienn(æ|ae)/u Skotů ve Vídni/g;
  $line =~ s/ad Sanctam Crucem/v Heiligenkreuz/g;
  $line =~ s/Ad Sanctam Crucem/V Heiligenkreuz/g;
  $line =~ s/Sanctae Crucis/Heiligenkreuz/ig;
  $line =~ s/Campililii/v klášteře Lilienfeld/ig;
  $line =~ s/Pfortenae/v Pforten/ig;
  $line =~ s/Clarae.Tumbae/kláštera Mogiła/ig;
  $line =~ s/Sedlicii et Skalicii abbas/opat v Sedlci a ve Skalici/ig;
  $line =~ s/Sedlicii|Sedlecii/v Sedlci/ig;
  $line =~ s/Skalicii/ve Skalici/ig;
  $line =~ s/Vetero-Brunae/na Starém Brně/ig;
  $line =~ s/Brunae/v Brně/ig;
  $line =~ s/Runae/v klášteře Rein/ig;
  $line =~ s/Populeti/v klášteře Poblet/ig;
  $line =~ s/de Salem/z kláštera Salem/ig;
  $line =~
    s/Fontis Mariae ad Zaram abbas|Fontis B\.M\.V.\ ad Zaram abbas|Fontis Beatae Mariae Virginis ad Zaram abbas/Opat v klášteře Studnice Panny Marie ve Žďáru/ig;
  $line =~
    s/Fontis Mariae ad Zaram|Fontis B\.M\.V.\ ad Zaram|Fontis Beatae Mariae Virginis ad Zaram/v klášteře Studnice Panny Marie ve Žďáru/ig;
  $line =~ s/Aulae-Regensibus/zbraslavských/ig;
  $line =~ s/Aulae/Síně/ig;
  $line =~ s/Teplensis/tepelský/ig;
  $line =~ s/Grissoviensis/křešovský/ig;
  $line =~ s/Mellicensis/z Melku/ig;
  $line =~ s/Morimondensis/Morimondský/ig;
  $line =~ s/Altquardensis/v klášteře Aduard/ig;
  $line =~ s/de Belzza/z Welsu/ig;

  $line =~ s/in Valle.Virginum|ad Vallem Virginum/v klášteře Pohled/ig;
  $line =~ s/in Valle.Mariae|Mariae.Vallis|Valle.Mariae/v klášteře Marienthal/ig;
  $line =~
    s/Mariae.Stellae|Stellae.Mariae|Mariae.Stelae|Stelae.Mariae|Stela.Mariae|Stella.Mariae|Marie.Stelae/v klášteře Marienstern/ig;
  $line =~ s/universitatis Pragae/pražské university/ig;
  $line =~ s/in Universitate Cracoviensi/na Krakovské Universitě/ig;
  $line =~ s/Pragae/v Praze/ig;
  $line =~ s/universitatis/university/ig;

  $line =~ s/Roame|Romae/v Římě/ig;
  $line =~ s/in Altovado/ve Vyšším Brodě/ig;
  $line =~ s/in oppido Altovadeno/ve městě Vyšší Brod/ig;
  $line =~ s/de oppido Altovadeno|de oppido Altovado/z města Vyšší Brod/ig;
  $line =~ s/Altovado/Vyšší Brod/ig;
  $line =~ s/Altovadi professi/vyšebrodského profese/ig;
  $line =~ s/Altovadi|Altovadii|de Altovado/vyšebrodský/ig;
  $line =~ s/in capella Beatae Mariae Virginis/v kapli Panny Marie/ig;
  $line =~ s/ante capellam/před kaplí/ig;
  $line =~ s/Bechinensis/bechyňský/ig;
  $line =~ s/Capellensis/z Kapliček/ig;
  $line =~ s/Vorder Heuraffl|Heuraffel|Hayraffl|Hayraffa/Přední Výtoň/ig;
  $line =~ s/in Capella/v Kapličkách/g;
  $line =~ s/de Capella/z Kapliček/g;
  $line =~ s/in capella prima/v první kapli/ig;
  $line =~ s/in capella/v kapli/ig;
  $line =~ s/Haericensis|Hořiciensis| de Haeric/z Hořic/ig;
  $line =~ s/Hoericium|Hoeric|Haeric|Hoeritz|Hericz/Hořice/ig;
  $line =~ s/Hoericii|Hœritzii|in H(ae|æ)rzitz/v Hořicích/ig;
  $line =~ s/ad Fonticulum|ad Fontem Salubrem|ad Salubrem Fonticulum|Brünnl/na Dobré Vodě/ig;
  $line =~ s/Oberheid|Mericae Superioris/v Horním Dvořišti/ig;
  $line =~ s/Unterhaydii/v Dolním Dvořišti/ig;
  $line =~ s/Unterheid|Merica Inferioris|Merica inferior/Dolní Dvořiště/ig;
  $line =~ s/Rosenthalii/v Rožmitálu/ig;
  $line =~ s/Rosenthal/Rožmitál/ig;
  $line =~ s/Prien?thalii|in Priethal/v Přídolí/ig;
  $line =~ s/Priethalium|Priethal/Přídolí/ig;
  $line =~ s/Cajoviae|in Cajow/v Kájově/ig;
  $line =~ s/Gratzen/Nové Hrady/ig;
  $line =~ s/praedii Komařiciensis|Komarzitzii|Komarzitii/statku v Komařicích/ig;
  $line =~ s/Stritzitzii/ve Strýčicích/ig;
  $line =~ s/Strziczicium|Stritzitz/Strýčice/ig;
  $line =~ s/Strýčiciensis/strýčcký/ig;
  $line =~ s/Strakonicensis/strakonický/ig;
  $line =~ s/Tarnoviensis/trnavského/ig;
  $line =~ s/Strobniciensis/stropnický/ig;
  $line =~ s/Strobnicii|in Strobnitz|Strobnitzii/ve Stropnici/ig;
  $line =~ s/Strobnicium|Strobnitz|Strobnitzium|Stropnicz/Stropnice/ig;
  $line =~ s/Kalschingensis|Chvalšinensis/chvalšinský/ig;
  $line =~ s/Kalschingae/ve Chvalšinách/ig;
  $line =~ s/Kalsching/Chvalšiny/ig;
  $line =~ s/Driesendorf/Střížov/ig;
  $line =~ s/Boreschovii|Paireschau/v Boršově/ig;
  $line =~ s/Payreschau|Payerschau/Boršov/ig;
  $line =~ s/de Budvicio/z Budějovic/ig;
  $line =~ s/Budvicii/v Budějovicích/ig;
  $line =~ s/episcopi Budvicensis/biskupa budějovického/gi;
  $line =~ s/gymnasii Budvicensis/budějovického gymnázia/ig;
  $line =~ s/dioeceseos Budvicensis/budějovické diecéze/ig;
  $line =~ s/Budvicensis/budějovický/ig;
  $line =~ s/Černicensis/v Černici/ig;
  $line =~ s/in Krems/v Křemži/ig;
  $line =~ s/Potvoroviensi/potvorovské/ig;
  $line =~ s/Malschingae/Malšína/ig;
  $line =~ s/Malsching/Malšín/ig;
  $line =~ s/de Rosenberg|de Rosis|Rosensium/z Rožmberka/ig;
  $line =~ s/Rosenbergicae/rožmberského/ig;
  $line =~ s/Rosenbergae/Rožmberku/ig;
  $line =~ s/Rosenberg/Rožmberk/ig;
  $line =~ s/Rosensis/z Rožmberků/ig;
  $line =~ s/ de Crumna(w|u)| de Crumlov| de Crumpna(w|u)| de Crumlovia/ z Krumlova/ig;
  $line =~ s/Crumlovii/v Krumlově/ig;
  $line =~ s/Crumlovium/do Krumlova/gi;
  $line =~ s/Crumlovia|Crumlov|Crumbnaw|Crumpnaw|Crumpnau/Krumlov/ig;
  $line =~ s/Sobieslavia/Soběslav/ig;
  $line =~ s/Kozojedii|in Kozojed/v Kozojedech/ig;
  $line =~ s/Sanctae Annae/Svaté Anny/ig;
  $line =~ s/ad Sanctum Martinum/u svatého Martina/ig;
  $line =~ s/in monasterio Sanctae Clarae virginis/v klášteře svaté Kláry Panny/ig;
  $line =~ s/in monasterio/v klášteře/ig;
  $line =~ s/in nostra ecclesia/v našem kostele/ig;
  $line =~ s/in ecclesia/v kostele/ig;
  $line =~ s/in instituto philosophico/na filosofickém institutu/ig;
  $line =~
    s/Tento-Richnovii|Teutorychnovii|Teuto-Richnoviensis|Tento-Richnoviensis|Richnoviensis/v Rychnově u Nových Hradů/ig;
  $line =~ s/Tento-Richnov|Tento-Richnovium/Rychnov u Nových Hradů/ig;
  $line =~ s/Plan |Planensis /Planá /ig;
  $line =~ s/Plan\./Planá\./ig;
  $line =~ s/Teinicii/v Týnici/ig;
  $line =~ s/Mariae.Ratschitz|Maria.Ratschitz/Mariánské Radčice/ig;
  $line =~ s/Ratschitzii/v Mariánských Radčicích/ig;
  $line =~ s/Kirchschlag|Kirschlag/Světlík/ig;
  $line =~ s/in Antiqua Bruna|Vetero-Brunae/na Starém Brně/ig;
  $line =~ s/Antiqua Bruna/Staré Brno/ig;
  $line =~ s/Bruna/Brno/ig;
  $line =~ s/Zaroschitzii|Zaroschicii|in Zarošice/v Žarošicích/ig;
  $line =~ s/Zarošicensis|Zaroschicii/žarošický/ig;
  $line =~ s/ad Sanctum Oswaldum/ve Svatém Osvaldu/ig;
  $line =~ s/de Serin/ze Serynu/ig;
  $line =~ s/Lincii/v Linci/ig;
  $line =~ s/Lincensi/lineckém/ig;
  $line =~ s/Slapensis/slapské/ig;
  $line =~ s/Janecii/v Jeníkově/ig;
  $line =~ s/Janek|Janegg/Jeníkov/ig;
  $line =~ s/de Schaumburg/z Schaumburgu/ig;
  $line =~ s/in Monte Aventino/na aventinském pahorku/ig;
  $line =~ s/in Monte/na hoře/ig;
  $line =~ s/Poletitz/Boletice/ig;
  $line =~ s/Boleticii/v Boleticích/ig;
  $line =~ s/Veter.Osseci|in Vetero-Ossegg/ve Starém Oseku/ig;
  $line =~ s/Wissoczan/Vysočany/ig;
  $line =~ s/Ottau|Zathon/Zátoň/ig;
  $line =~ s/Neostadii/v Novém Městě Vídeňském/ig;
  $line =~ s/Lisnitz/Líšnice/ig;
  $line =~ s/Netolitz/Netolice/ig;
  $line =~ s/ in Commoto(v|w)| in Komotau| in Komotau/ v Chomutově/ig;
  $line =~ s/Commoto(v|w)|Komotau|Komotau/Chomutov/ig;
  $line =~ s/ad Sanctum Lapidem/na Svatém Kameni/ig;
  $line =~ s/de Mitrovitz/z Mitrovic/ig;
  $line =~ s/Walschbirken/Vlachovo Březí/ig;
  $line =~ s/Kuttenberg/Kutná Hora/gi;
  $line =~ s/Zebnicz/Žebnice/gi;
  $line =~ s/Winterberg/Vimperk/gi;
  $line =~ s/de Novo Castro/z Jindřichova Hradce/gi;
  $line =~ s/in Castro/na Hradě/gi;
  $line =~ s/Lzin/Lžín/gi;
  $line =~ s/Cerhonic./Cerhonice/gi;
  $line =~ s/Litomerzic/Litoměřice/gi;
  $line =~ s/Bilin/Bílina/gi;
  $line =~ s/Myliczyn/Miličín/gi;
  $line =~ s/Poleschowitz/Polešovice/gi;
  $line =~ s/Ramensis ecclesiae/diecéze Ráma/gi;
  $line =~ s/Dresd(æ|ae)/v Drážďanech/gi;
  $line =~ s/Salisburgi/v Salzburgu/gi;
  $line =~ s/in Dachau/v Dachau/gi;
  $line =~ s/in Mainhardschlag/v Malontech/gi;
  $line =~ s/Hellenopolisensis/v Hellenopolis <i>v Bythinii<\/i>/gi;

  $line =~ s/abbatiae Ossecensis/oseckého opatství/ig;
  $line =~ s/Ordinis Sancti Joannis hospitalis in Jerusalem/hospitálního Řádu svatého Jana v Jerusalémě/ig;
  $line =~ s/huius loci abbatis/Opata tohoto kláštera/ig;
  $line =~ s/huius loci professus/profes tohoto kláštera/ig;
  $line =~ s/huius loci professi/profese tohoto kláštera/ig;
  $line =~ s/cum vitam finire vellet/když se chystal na konec života/ig;
  $line =~ s/honorifice/s poctami/ig;
  $line =~ s/terrae traditus est/byl vydán zemi/ig;
  $line =~ s/celebratis pro eo exequiis/když za něj byly odslouženy pohřební obřady/ig;
  $line =~ s/supremus Regni Bohemiae Purgravius/nejvyšší Purkrabí Království Českého/gi;
  $line =~ s/regni Bohemiae praelatus infulatus/infulované Prelát Království Českého/gi;
  $line =~ s/gubernator domus/správce domu/gi;
  $line =~ s/aurei velleris eques/rytíř zlatého rouna/gi;
  $line =~ s/Imperatorum/Císařů/gi;
  $line =~ s/Imperator/Císař/gi;
  $line =~ s/trium/třem/gi;
  $line =~ s/prope /poblíž /gi;
  $line =~ s/eorumdemque regum Bohemiae/a také králům českým/gi;
  $line =~ s/a consiliis/byl rádcem/gi;
  $line =~ s/de republica Czechica optime meritus/s velkými zásluhami o Český stát/gi;
  $line =~ s/Portatus/Přenesen/gi;
  $line =~ s/Praga /z Prahy /gi;
  $line =~ s/exequia/pohřební obřady/gi;
  $line =~ s/celebrantur/se slavily/gi;
  $line =~ s/ut supra/viz výše/gi;
  $line =~ s/Sepelitur/Pohřben/gi;
  $line =~ s/Illustri Principissa/Nejjasnější kněžnou/gi;
  $line =~ s/in summa basilica/ve velké basilice/gi;
  $line =~ s/pro patria mortuus est/zemřel za vlast/gi;
  $line =~ s/in bello (miserrimo|miserimo)/v hrozné válce/gi;
  $line =~ s/in bello infelicissimo/v nešťastné válce/gi;
  $line =~ s/ad Sanctissimam Trinitatem/u Nejsvětější Trojice/gi;
  $line =~ s/a gestapo incarceratus/byl zajat gestapem/gi;
  $line =~ s/combustus est/byl spálen/ig;

  $line =~ s/Austriae superioris/v Horním Rakousku/ig;
  $line =~ s/Austriam emigravit|in Austria emigravit/emigroval do Rakouska/ig;
  $line =~ s/Austriae|in Austria/v Rakousku/ig;
  $line =~ s/per Bohemiam/pro Čechy/ig;
  $line =~ s/in Lusatia/v Lužici/ig;
  $line =~ s/Lusatiam/Lužici/ig;
  $line =~ s/in Hungaria/v Maďarsku/ig;
  $line =~ s/in Polonia/v Polsku/ig;
  $line =~ s/Hungariae/maďarského/ig;
  $line =~ s/Bohemiae/českého/ig;
  $line =~ s/Moraviam/Moravu/ig;
  $line =~ s/in Moravia/na Moravě/ig;
  $line =~ s/Styriae/ve Štýrsku/ig;
  $line =~ s/Tiroliae/v Tyrolsku/ig;
  $line =~ s/Thesinensis/těšínského/ig;
  $line =~ s/per regnum Saxoni(æ|ae)/v celém Saském Království/ig;

  $line =~ s/abbas(.*)ultimus/poslední Opat$1/ig;
  $line =~ s/abbas/Opat/ig;
  $line =~ s/abbatiae/opatství/ig;
  $line =~ s/abbatissa/abatyše/ig;
  $line =~ s/praepositus (.*) emeritus/emeritní probošt $1/gi;
  $line =~ s/praepositus/probošt/ig;
  $line =~ s/visitator/vizitátor/ig;
  $line =~ s/subprior/podpřevor/ig;
  $line =~ s/prior emeritus/emeritní převor/ig;
  $line =~ s/prior.administrator/převor-administrátor/ig;
  $line =~ s/prior( |,|.)/převor$1/ig;
  $line =~ s/Religiosus|Religiosa|Rel\./Řeholní/gi;
  $line =~ s/Reverendus Frater|Rev\. Fr\./Ctihodný bratr/gi;
  $line =~ s/ Frater | Fr\. / bratr /gi;
  $line =~ s/Reverendus/Důstojný/gi;
  $line =~ s/Conversus/konvrš/gi;
  $line =~ s/confraternitatem fecit/uzavřel konfraternitu/gi;
  $line =~ s/confrater noster/náš spolubratr/gi;
  $line =~ s/confratris nostri/našeho spolubratra/ig;
  $line =~ s/confrater/spolubratr/gi;
  $line =~ s/Virgo/Panna/gi;
  $line =~ s/Perillustris Domina/Přejasná Paní/ig;
  $line =~ s/relicta/vdova/gi;
  $line =~ s/Domina/Paní/gi;
  $line =~ s/Dominus/Pán/gi;
  $line =~ s/Dominorum/Pánů/gi;
  $line =~ s/Dominum/Pána/gi;
  $line =~ s/ducis/vévody/gi;
  $line =~ s/comes /hrabě /gi;
  $line =~ s/comitem/hraběte/gi;
  $line =~ s/magister infirmorum|infirmarius/infirmář/ig;
  $line =~ s/Domini abbatis|Domni abbatis/Pana Opata/gi;
  $line =~ s/abbatis/Opata/gi;
  $line =~ s/Domini /Pána /gi;
  $line =~ s/gubernator/hejtman/gi;
  $line =~ s/conventualis/konventní/gi;
  $line =~ s/stabilitatis/se slibem stability/gi;
  $line =~ s/cum disputationibus/při disputacích/gi;
  $line =~ s/habitis/konaných/gi;
  $line =~ s/mortuus est|mortuus/zemřel/gi;
  $line =~ s/in parochia/ve farnosti/gi;
  $line =~ s/annos natus (\d+)/ve věku $1 let/gi;
  $line =~ s/villa/statek/gi;
  $line =~ s/sedule/pečlivě/gi;
  $line =~ s/annis (\d+)/$1 let/gi;
  $line =~ s/per (\d+) annos/po $1 let/gi;
  $line =~ s/praefuit/spravoval/gi;
  $line =~ s/sitam/umístěnou/gi;
  $line =~ s/e fundamentis|a fundamentis/od základů/gi;
  $line =~ s/aedificavit/vystavěl/gi;
  $line =~ s/donavit/daroval/gi;
  $line =~ s/lignum/dřevo/gi;
  $line =~ s/pretiose/drahocenně/gi;
  $line =~ s/ornatum/zdobené/gi;
  $line =~ s/in capitulo nostro/v naší kapitulní síni/gi;
  $line =~ s/in tumulo/v hrobce/gi;
  $line =~ s/sodalis parthenius/mariánský ctitel/gi;
  $line =~ s/hospis|hospes/host/gi;
  $line =~ s/beneficiatus/obročník/gi;
  $line =~ s/catecheta/katecheta/gi;
  $line =~ s/homo simplex/prostý člověk/gi;
  $line =~ s/delegavit/odkázal/gi;
  $line =~ s/omnes libros suos/všechny své knihy/gi;
  $line =~ s/praemonstratensis/premonstrátského/gi;
  $line =~ s/anno (\w+) resignatus/který odstoupil $1/gi;
  $line =~ s/annos/let/gi;
  $line =~ s/resignatus/, který odstoupil/gi;
  $line =~ s/iterum/poté/gi;
  $line =~ s/(\w+) honoratus/ctěný $1/gi;
  $line =~ s/ levati / zrušeného /gi;
  $line =~ s/ obiit / zesnul /gi;
  $line =~ s/ obiit\./ zesnul./gi;
  $line =~ s/oriundus/, který pochází/gi;
  $line =~ s/historiae ecclesiasticae/církevních dějin/gi;
  $line =~ s/iuris canonici/kanonického práva/gi;
  $line =~ s/concionator Quadragesimae/postní kazatel/gi;
  $line =~ s/concionator/kazatel/gi;
  $line =~ s/reformator disciplin(ae|æ) regularis/reformátor řeholní kázně/gi;

  $line =~ s/Quirini/Quirina/ig;
  $line =~ s/illustrissimum dominum/nejjasnějšího pána/gi;
  $line =~ s/cum monasterio nostro/s naším klášterem/gi;
  $line =~ s/huic monasterio/tomuto klášteru/gi;
  $line =~ s/nostro monasterio|monasterio nostro/našemu klášteru/gi;
  $line =~ s/fidelem curam/věrnou péči/gi;
  $line =~ s/in officio suo/ve svém úřadu/gi;
  $line =~ s/impendit/vynakládal/gi;
  $line =~ s/serenissimi/nejjasnějšího/gi;
  $line =~ s/serenissimus/nejjasnější/g;
  $line =~ s/Serenissimus/Nejjasnější/g;
  $line =~ s/magnifici/vznešeného/gi;
  $line =~ s/magnificus/vznešený/gi;
  $line =~ s/Incl[y|i]tus/Slavný/g;
  $line =~ s/incl[y|i]tus/slavný/g;
  $line =~ s/incl[y|i]ti/slavného/gi;
  $line =~ s/Regis/Krále/ig;
  $line =~ s/protonotarius/protonotář/ig;
  $line =~ s/prothonotarii|protonotarii/protonotáře/ig;
  $line =~ s/presbyteri/kněze/gi;
  $line =~ s/Honorabilis/Ctihodný/gi;
  $line =~ s/Honesta/Ctná/gi;
  $line =~ s/Honestus/Ctný/gi;
  $line =~ s/supremus/nejvyšší/gi;
  $line =~ s/praestans/vynikající/gi;
  $line =~ s/organista/varhaník/gi;
  $line =~ s/decanus personalis/osobní děkan/gi;
  $line =~ s/decanus/děkan/gi;
  $line =~ s/cancellariae et aedificiorum inspector/správce kanceláří a budov/gi;
  $line =~ s/inspector aedificiorum/správce budov/gi;
  $line =~ s/capellae regalis/královské kapely/gi;
  $line =~ s/capellae/kaple/g;
  $line =~ s/canonicus/kanovník/gi;
  $line =~ s/fundatoris/zakladatele/gi;
  $line =~ s/fundator/zakladatel/gi;
  $line =~ s/stabularius/kočí/gi;
  $line =~ s/cliens/panoš/gi;
  $line =~ s/principis|princeps/vládce/gi;
  $line =~ s/scriba/písař/gi;
  $line =~ s/cancelariae/kanceláře/gi;
  $line =~ s/ contra / proti /gi;
  $line =~ s/Rusiam|Russiam/Rusku/gi;
  $line =~ s/rector/rektor/gi;
  $line =~ s/ad Sanctum Bernardum/u svatého Bernarda/gi;
  $line =~ s/missarius/vyslanec/gi;
  $line =~ s/in vigilia/v předvečer/gi;
  $line =~ s/Sanctissimae Trinitatis/Nejsvětější Trojice/gi;
  $line =~ s/ad Sanctum Spiritum/u Svatého Ducha/gi;
  $line =~ s/Bohemus/Čech/gi;

  $line =~ s/parochus (.*) emeritus/emeritní farář $1/gi;
  $line =~ s/parochus emeritus/emeritní farář/gi;
  $line =~ s/parochus/farář/gi;
  $line =~ s/clericus/klerik/gi;
  $line =~ s/novitius|novicius/novic/gi;
  $line =~ s/studens|scholarius/student/gi;
  $line =~ s/archidiaconus/arcijáhen/ig;
  $line =~ s/(\w+) infulatus/infulovaný $1/ig;
  $line =~ s/subdiaconus/podjáhen/gi;
  $line =~ s/diaconus/jáhen/gi;
  $line =~ s/accolitus/akolyta/gi;
  $line =~ s/plebanus/plebán/gi;
  $line =~ s/auxiliator |auxiliarius /pomocný duchovní /gi;
  $line =~ s/capellanus (.*) emeritus/emeritní kaplan $1/gi;
  $line =~
    s/cooperator administratoris|cooperator|cooperatro|capellanus|cooperatus|adjutor parochiae|adjutor parochi/kaplan/gi;
  $line =~ s/presbyteri/kněze/gi;
  $line =~ s/presbyter/kněz/gi;
  $line =~ s/heremita|eremita/poustevník/gi;
  $line =~ s/vir( |\.|\,)/muž$1/gi;

  $line =~ s/archivarius/archivář/ig;
  $line =~ s/praefectus pharmacopae/prefekt lékárny/ig;
  $line =~ s/praefectus culinae abbatialis/prefekt opatské kuchyně/ig;
  $line =~ s/praefectus culinae|culinae praefectus/prefekt kuchyně/ig;
  $line =~ s/culinae(.*)provisor/správce kuchyně$1/ig;
  $line =~ s/culinae(.*)praefectus/prefekt kuchyně$1/ig;
  $line =~ s/culinae/kuchyně/ig;
  $line =~ s/cellae|celae/sklepů/ig;
  $line =~ s/praefectus/prefekt/ig;
  $line =~ s/cellae vinariarum/vinných sklepů/ig;
  $line =~ s/magister conversorum/konvršmistr/ig;
  $line =~ s/magister novitiorum|novitiorum magister/novicmistr/ig;
  $line =~ s/magister/magistr/ig;
  $line =~ s/administrator oeconomiae|oeconomus|oeconomicus|inspector oeconomiae/hospodářský správce/ig;
  $line =~ s/bibliothecarius/knihovník/ig;
  $line =~ s/confessarius/zpovědník/ig;
  $line =~ s/cantor/kantor/ig;
  $line =~ s/regens chori figuralis/dirigent orchestru a sboru/ig;
  $line =~ s/regens chori/regenschori/ig;
  $line =~ s/hiuis/huius/ig;
  $line =~ s/huius loci|huius coenobii/tohoto kláštera/ig;
  $line =~ s/domni abbatis/pana opata/ig;
  $line =~ s/quaesturae provisor/finanční správce/gi;
  $line =~ s/administrator (.*)emeritus/emeritní administrátor $1/gi;
  $line =~ s/administrator|provisor/administrátor/gi;
  $line =~ s/procurator/správce/gi;
  $line =~ s/aurifaber/zlatník/gi;
  $line =~ s/pharmacopoia/lékárník/gi;
  $line =~ s/granarius/správce sýpky/gi;

  #$line =~ s/provisor/správce/gi;
  $line =~ s/gymnasii/gymnázia/gi;
  $line =~ s/Ordinis doctor theologus/řádový doktor teologie/gi;
  $line =~ s/Ordinis cisterciensis|cisterciensis Ordinis/cisterciáckého Řádu/gi;
  $line =~ s/Ordinem Cistercium professus/se stal členem cisterciáckého Řádu/gi;
  $line =~ s/provincialis Ordinis Pr(ae|æ)dicatorum/provinciál Řádu Kazatelů/ig;
  $line =~ s/Ordinis/Řádu/gi;
  $line =~ s/director/ředitel/gi;
  $line =~ s/protector/ochránce/gi;
  $line =~ s/congregationis|congregatio/kongregace/gi;
  $line =~ s/in prioratu/v převorství/gi;
  $line =~ s/Erat /Byl to /g;
  $line =~ s/erat /byl to /g;
  $line =~ s/fuerat/byl/gi;
  $line =~ s/sinistrae/levé/ig;
  $line =~ s/sinistri/levého/ig;
  $line =~ s/dextrae/pravé/ig;
  $line =~ s/dextri/pravého/ig;
  $line =~ s/partis/části/ig;
  $line =~ s/in coemeterio communi/na společném hřbitově/ig;
  $line =~ s/in coemeterio/na hřbitově/ig;
  $line =~ s/inspector silvarum/lesní inspektor/ig;
  $line =~ s/silvarum/lesní/ig;
  $line =~ s/poenitentiarius/penitenciář/ig;

  $line =~ s/Joannis/Jana/ig;
  $line =~ s/Joannes/Jan/ig;
  $line =~ s/Jodoci/Jocha/ig;
  $line =~ s/Augustini/Augustina/ig;
  $line =~ s/Ulrici/Oldřicha/ig;
  $line =~ s/Ulricus/Oldřich/ig;
  $line =~ s/Bartholomaei/Bartoloměje/ig;
  $line =~ s/Henricus/Jindřich/ig;
  $line =~ s/Henrici /Jindřicha /ig;
  $line =~ s/Matthiae /Matyáše /ig;
  $line =~ s/Ungaricae /Uherského /ig;
  $line =~ s/Martini/Martina/ig;
  $line =~ s/Sancti Viti/svatého Víta/ig;
  $line =~ s/Viti /Víta /ig;
  $line =~ s/Edmundi/Edmunda/ig;
  $line =~ s/Procopii/Prokopa/ig;
  $line =~ s/Petri/Petra/ig;
  $line =~ s/Vokonis|Wokonis/Voka/ig;
  $line =~ s/Woko/Vok/ig;
  $line =~ s/Evae|Hevae/Evy/ig;
  $line =~ s/Lucae/Lukáše/ig;
  $line =~ s/Guillelmus/Vilém/ig;
  $line =~ s/Zawissius/Záviš/ig;
  $line =~ s/de Falkenstein/z Falkenštejna/ig;
  $line =~ s/Andreae/Ondřeje/ig;
  $line =~ s/Pauli/Pavla/ig;
  $line =~ s/Jacobi/Jakuba/ig;
  $line =~ s/Lauren[t|c]ius/Vavřinec/ig;
  $line =~ s/Carolus/Karel/ig;
  $line =~ s/Jacobus/Jakub/ig;
  $line =~ s/Wencz?eslaus/Václav/ig;
  $line =~ s/Wencz?eslai/Václava/ig;
  $line =~ s/Antonius/Antonín/ig;
  $line =~ s/Wolff?gangus/Wolfgang/ig;
  $line =~ s/Engelbertus/Engelbert/ig;
  $line =~ s/Petrus/Petr/ig;
  $line =~ s/Nicolaus/Mikuláš/ig;
  $line =~ s/Jodocus/Joch/ig;
  $line =~ s/Martinus/Martin/ig;
  $line =~ s/Robertus/Robert/ig;
  $line =~ s/Gerardus/Gerard/ig;
  $line =~ s/Stanislaus/Stanislav/ig;
  $line =~ s/Sigismundus/Zikmund/ig;
  $line =~ s/Edmundus/Edmund/ig;
  $line =~ s/Georgius/Jiří/ig;
  $line =~ s/Josephus/Josef/ig;
  $line =~ s/Adalbertus|Woytiech/Vojtěch/ig;
  $line =~ s/Vincentius/Vincenc/ig;
  $line =~ s/Benedictus/Benedikt/ig;
  $line =~ s/Ernestus/Ernst/ig;
  $line =~ s/Ladislaus/Ladislav/ig;
  $line =~ s/Augustinus/Augustin/ig;
  $line =~ s/Conradus/Konrád/ig;
  $line =~ s/Franciscus/František/ig;
  $line =~ s/Stephanus/Štěpán/ig;
  $line =~ s/Ignatius/Ignác/ig;
  $line =~ s/Gregorius/Řehoř/ig;
  $line =~ s/Florianus/Florián/ig;
  $line =~ s/Simon/Šimon/ig;
  $line =~ s/Maximilianus/Maximilián/ig;
  $line =~ s/Joachimus/Jáchym/ig;
  $line =~ s/Thomas/Tomáš/ig;
  $line =~ s/Nivardus/Nivard/ig;
  $line =~ s/Camillus/Kamil/ig;
  $line =~ s/Margaretha/Markéta/ig;
  $line =~ s/Matth(æ|ae)us/Matouš/ig;
  $line =~ s/Eugenius/Evžen/ig;
  $line =~ s/Christianus/Christian/ig;
  $line =~ s/Bartholomæus/Bartoloměj/ig;
  $line =~ s/Matthias/Matěj/ig;
  $line =~ s/Albericus/Alberich/ig;
  $line =~ s/Nepomucenus/Nepomuk/ig;
  $line =~ s/Bernardinus/Bernardin/ig;
  $line =~ s/Fiola/Viola/ig;
  $line =~ s/xx/xx/ig;
  $line =~ s/xx/xx/ig;
  $line =~ s/xx/xx/ig;
  $line =~ s/xx/xx/ig;
  $line =~ s/xx/xx/ig;

  $line =~ s/episcopus (.*) in partibus/titulární Biskup $1/ig;
  $line =~ s/episcopus/Biskup/ig;
  $line =~ s/notarius archiepiscopialis/arcibiskupský notář/ig;
  $line =~ s/notarius episcopalis/biskupský notář/ig;
  $line =~ s/proto.notarius apostolicus/apoštolský protonotář/ig;
  $line =~ s/notarius apostolicus/apoštolský notář/ig;
  $line =~ s/vicarius generalis/generální vikář/ig;
  $line =~ s/vicarius apostolicus/apoštolský vikář/ig;
  $line =~ s/ordinis Cisterciensis/cisterciáckého řádu/ig;
  $line =~ s/secretarius/sekretář/ig;
  $line =~ s/notarius/notář/ig;
  $line =~ s/sacellarius/kaplan/ig;
  $line =~ s/cellarius/sklepmistr/ig;
  $line =~ s/cellarii/sklepů/ig;
  $line =~ s/cellerarius/celerář/ig;
  $line =~ s/sacrista|sacristanus/sakristán/ig;
  $line =~ s/consiliar.* constistorialis|consiliarius consistorialis/konsistorní rada/ig;
  $line =~ s/consistorii (.*) consiliarius/konsistorní rada $1/ig;
  $line =~ s/consiliarius (.*) constistorii/konsistorní rada $1/ig;
  $line =~ s/episcopi Brunensis/brněnského biskupa/ig;
  $line =~ s/episcopi( |\.|\,)/biskupa$1/ig;
  $line =~ s/ fratris/ bratra/ig;
  $line =~ s/plebanus/plebán/ig;
  $line =~ s/vicarius parochiae (.*) emeritus/emeritní farní vikář $1/ig;
  $line =~ s/vicarius parochiae/farní vikář/ig;
  $line =~ s/vicarius/vikář/ig;
  $line =~ s/in Collegio archi-episcopialis|in archi-?episcopi?alis collegio/na arcibiskupské koleji/ig;
  $line =~ s/ad Sanctum Adalbertum/Svatého Vojtěcha/ig;
  $line =~ s/benefactor singularis/jedinečný dobrodinec/ig;
  $line =~ s/benefactor noster/náš dobrodinec/ig;
  $line =~ s/benefactor/dobrodinec/ig;
  $line =~ s/benefactrix/dobrodinka/ig;
  $line =~ s/fautor/mecenáš/ig;

  $line =~ s/canoniae/kanonie/ig;
  $line =~ s/vinearum/vinic/ig;
  $line =~ s/parochii|parochiae/farnosti/ig;
  $line =~ s/Reverendi /důstojného /ig;
  $line =~ s/capituli/kapituly/ig;
  $line =~ s/monialium/sester/ig;
  $line =~ s/totius/celého/ig;
  $line =~ s/ultimi/posledního/ig;
  $line =~ s/antiquus/dřívější/ig;

  $line =~ s/ praenobilis/ převznešený/ig;
  $line =~ s/ nobilis/ vznešený/ig;
  $line =~ s/famosus/slavný/ig;
  $line =~ s/exemplaris/příkladný/ig;
  $line =~ s/Generosa/Štědrá/g;
  $line =~ s/generosa/štědrá/g;
  $line =~ s/generosae/štědré/ig;
  $line =~ s/generosi/štědrého/ig;
  $line =~ s/Generosus/Štědrý/g;
  $line =~ s/generosus/štědrý/g;
  $line =~ s/Egregius/Výjimečný/g;
  $line =~ s/egregius/výjimečný/g;
  $line =~ s/generosorum|generosum/štědrých/ig;
  $line =~ s/optimus/nejlepší/ig;
  $line =~ s/virtuosa/ctnostná/ig;
  $line =~ s/virtuosus/ctnostný/ig;
  $line =~ s/illustrissimus/nejjasnější/g;
  $line =~ s/Illustrissimus/Nejjasnější/g;
  $line =~ s/Illustris/Přejasný/g;
  $line =~ s/illustris/přejasný/g;
  $line =~ s/illustrem/přejasného/g;
  $line =~ s/primus/první/ig;
  $line =~ s/secundus/druhý/ig;
  $line =~ s/primi/prvního/ig;
  $line =~ s/secundi/druhého/ig;
  $line =~ s/camerarius/komorník/ig;
  $line =~ s/laudabiliter/chvályhodně/ig;
  $line =~ s/persolvit/vykonával/ig;
  $line =~ s/(\w+) nostri/našeho $1/ig;
  $line =~ s/(\w+) generalis/generální $1/ig;
  $line =~ s/huius monasterii/tohoto kláštera/ig;
  $line =~ s/monasterii/kláštera/ig;
  $line =~ s/officium/úřad/ig;    ######### OFFICIUM #########
  $line =~ s/studii biblici /biblických studií /ig;
  $line =~ s/physicae/fyziky/ig;
  $line =~ s/mathematicae/matematiky/ig;
  $line =~ s/philosophiae professor|professor philosophiae/profesor filosofie/ig;
  $line =~ s/professor (.*)emeritus/emeritní profesor $1/ig;
  $line =~ s/professor/profesor/ig;
  $line =~ s/pictor /malíř /ig;
  $line =~ s/pictor\./malíř\./ig;
  $line =~ s/sutor/švec/ig;
  $line =~ s/sartor /krejčí /ig;
  $line =~ s/sartor\./krejčí\./ig;
  $line =~ s/capitaneus|capitanei/správce/ig;
  $line =~ s/doleatoris/ranhojiče/ig;
  $line =~ s/tumulatus est/je pohřben/ig;
  $line =~ s/ tum / v té době /ig;
  $line =~ s/ tum, / v té době, /ig;
  $line =~ s/doctor decretorum|decretorum doctor/doktor církevního práva/ig;
  $line =~ s/iuris utriusque(.*)doctor/doktor obojího práva$1/ig;
  $line =~ s/philosophiae(.*)doctor/doktor filosofie$1/ig;
  $line =~ s/philosophiae doctor|doctor philosophiae/doktor filosofie/ig;
  $line =~ s/philosophiae/filosofie/ig;
  $line =~ s/sanctae theologiae doctor|doctor sanctae theologiae/doktor posvátné teologie/ig;
  $line =~ s/Sacr(ae|æ) theologi(ae|æ) bacc?alaureus/bakalář posvátné theologie/ig;
  $line =~ s/sanctae theologiae|sacrae theologiae/posvátné teologie/ig;
  $line =~ s/theologi(ae|æ) moralis/morální theologie/ig;
  $line =~ s/theologiae doctor|doctor theologiae/doktor teologie/ig;
  $line =~ s/utriusque iuris|iuris utriusque/obojího práva/ig;
  $line =~ s/doctor/doktor/ig;
  $line =~ s/theologiae bacc?alaureus|bacc?alaureus theologiae/bakalář teologie/ig;
  $line =~ s/theologiae-dogmaticae professor/profesor dogmatické teologie/ig;
  $line =~ s/theologiae|theologia/teologie/ig;
  $line =~ s/pater spiritualis/otec spirituál/ig;
  $line =~ s/per complures annos/po mnoho let/ig;
  $line =~ s/adjutor oeconomiae|adiutor oeconomiae/pomocný správce/ig;
  $line =~ s/in hospitali/ve špitále/ig;
  $line =~ s/procuratrix/správkyně/ig;
  $line =~ s/balneator/lazebník/ig;
  $line =~ s/portarius/fortnýř/ig;
  $line =~ s/domi( |\.|\,)/domu$1/ig;
  $line =~ s/officialis/hodnostář/ig;
  $line =~ s/coad[ij]utor/koadjutor/ig;
  $line =~ s/ecclesiae Wratislaviensis/vratislavské katedrály/ig;
  $line =~ s/ecclesiae/kostela/ig;
  $line =~ s/eandem ecclesiam/tentýž kostel/ig;
  $line =~ s/ecclesiam/kostel/ig;
  $line =~ s/maxime/nejvíce/ig;
  $line =~ s/in extremis/na konci/ig;
  $line =~ s/in nosocomio/v nemocnici/ig;
  $line =~ s/Fratrum misericori|Fratrum misericordiorum/Milosrdných Bratří/ig;
  $line =~ s/utramque/obojí/ig;
  $line =~ s/iudicissa/rychtářka/ig;
  $line =~ s/refectorarius/refektorář/ig;
  $line =~ s/lotionarius/valchář/ig;
  $line =~ s/scriniator/bednář/ig;
  $line =~ s/eiusdem/jeho/ig;
  $line =~ s/pistor/pekař/ig;
  $line =~ s/piscator/rybář/ig;
  $line =~ s/piscatrix/rybářka/ig;
  $line =~ s/poculo lethifero infectus/otráven  jedem v číši/ig;
  $line =~ s/sibi propinato/kterou mu podali/ig;

  $line =~ s/pater eius/jeho otec/ig;
  $line =~ s/pater /otec /ig;
  $line =~ s/patris/otce/ig;
  $line =~ s/filius/syn/ig;
  $line =~ s/Sororum Misericordi(æ|ae)/Milosrdných Sester/ig;
  $line =~ s/sororis/sestry/ig;
  $line =~ s/soror/sestra/ig;
  $line =~ s/filia /dcera /ig;
  $line =~ s/amita /teta /ig;
  $line =~ s/mater eius/jeho matka/ig;
  $line =~ s/mater /matka /ig;
  $line =~ s/matrona /dáma /ig;
  $line =~ s/civissa/občanka/ig;
  $line =~ s/cives |civis /občan /ig;
  $line =~ s/conthoralis/choť/ig;
  $line =~ s/consanguinea/rodná sestra/ig;
  $line =~ s/confratrix nostra/členka naší konfraternity/ig;
  $line =~ s/vidua /vdova /ig;
  $line =~ s/germanus/rodný bratr/ig;
  $line =~ s/parens/rodič/ig;
  $line =~ s/ natus/ narozen/ig;
  $line =~ s/uxor eius/jeho manželka/ig;
  $line =~ s/uxore/manželkou/ig;
  $line =~ s/uxor/manželka/ig;
  $line =~ s/hic professi/zdejšího profese/ig;
  $line =~ s/in oppido/ve městě/ig;
  $line =~ s/in aedibus/v síních/ig;
  $line =~ s/ante altare/před Oltářem/ig;
  $line =~ s/post expulsionem/po vyhnání/ig;
  $line =~ s/a rusticis Bohemis/českými sedláky/ig;
  $line =~ s/occisus est/byl zabit/ig;
  $line =~ s/crudeliter/krutě/ig;
  $line =~ s/cum abbate suo/se svým Opatem/ig;
  $line =~ s/iuniorum/mládeže/ig;
  $line =~ s/iunior/mladší/ig;
  $line =~ s/(\w+) aulicus/dvorní $1/ig;
  $line =~ s/novam/novou/ig;
  $line =~ s/novum/nový/ig;
  $line =~ s/curiam/budovu/ig;
  $line =~ s/generalitiam/generalátu/ig;
  $line =~ s/mire/krásně/ig;
  $line =~ s/decoravit/vyzdobil/ig;
  $line =~ s/indefessa cura/neúnavnou péčí/ig;
  $line =~ s/indefessus/nezdolný/ig;
  $line =~ s/atque/a také/ig;
  $line =~ s/tandem/později/ig;
  $line =~ s/machina dilaceratus/poraněn strojem/ig;

  $line =~ s/vicariatus assistens/sekretář vikariátu (kongregace)/ig;
  $line =~ s/vicariatus/vikariátu (kongregace)/ig;
  $line =~ s/assistens/sekretář/ig;
  $line =~ s/localista/lokální kaplan/ig;

  $line =~ s/eodem anno /Téhož roku /ig;
  $line =~ s/anni eiusdem|eiusdem anni/téhož roku/ig;
  $line =~ s/Anno /Roku /g;
  $line =~ s/anno /roku /g;
  $line =~ s/Die /Dne /g;
  $line =~ s/die /dne /g;
  $line =~ s/quondam|olim/kdysi/ig;
  $line =~ s/hic /zde /ig;
  $line =~ s/dein /poté /ig;
  $line =~ s/sepultus est/je pohřbený/ig;
  $line =~ s/sepultus iacet/leží pohřbený/ig;
  $line =~ s/Sepultus/Pohřbený/g;
  $line =~ s/sepultus/pohřbený/g;
  $line =~ s/sepulta est/je pohřbená/ig;
  $line =~ s/sepulta/pohřbená/ig;
  $line =~ s/mensis/měsíce/ig;
  $line =~ s/vixit/žil/ig;
  $line =~ s/ecclesiae|ecclessiæ/kostely/ig;
  $line =~ s/diocesis/diecéze/ig;
  $line =~ s/diocesis/diecéze/ig;

  $line =~ s/Tertius/Třetí/g;
  $line =~ s/tertius|tertia/třetí/g;
  $line =~ s/tertii/třetího/g;
  $line =~ s/quartus/čtvrtý/g;

  $line =~ s/januarii/ledna/ig;
  $line =~ s/februarii/února/ig;
  $line =~ s/martii/března/ig;
  $line =~ s/aprilis/dubna/ig;
  $line =~ s/maii |maji /května /ig;
  $line =~ s/iunii|junii/června/ig;
  $line =~ s/iulii |julii /července /ig;
  $line =~ s/augusti /srpna /ig;
  $line =~ s/septembris/září/ig;
  $line =~ s/octobris/října/ig;
  $line =~ s/novembris/listopadu/ig;
  $line =~ s/decembris/prosince/ig;

  $line =~ s/pie in Domino obdormierunt/zbožně v Pánu zesnuli/ig;
  $line =~ s/monachus chori/chórový mnich/ig;
  $line =~ s/monachus|monachos/mnich/ig;
  $line =~ s/professus [ij]ubilatus/profes jubilant/ig;
  $line =~ s/sacerdos [ij]ubilatus/kněz jubilant/ig;
  $line =~ s/sacerdos/kněz/gi;
  $line =~ s/professus de/profes z kláštera/ig;
  $line =~ s/professus/profes/ig;
  $line =~ s/professi/profese/ig;
  $line =~ s/ibidem/na témž místě/ig;
  $line =~ s/ibique/a tam/ig;
  $line =~ s/B\.M\.V\.|Beatae Mariae Virginis/Panny Marie/ig;
  $line =~ s/(\w+) sui/svého $1/ig;
  $line =~ s/ et / a /ig;
  $line =~ s/ qui / který /ig;
  $line =~ s/ quae | quæ / která /ig;
  $line =~ s/ nata / rozená /ig;
  $line =~ s/ cum / s /ig;
  $line =~ s/ ubi / kde /ig;
  $line =~ s/ ibi / tam /ig;
  $line =~ s/ er / a /ig;
  $line =~ s/ in | ad / v obci /ig;
  $line =~ s/ ac / a /ig;
  $line =~ s/ apud / u /ig;
  $line =~ s/ de la / de-la /gi;

  #$line =~ s/ de | ex / z obce /gi;
  $line =~ s/ ex / z obce /gi;
  $line =~ s/ de-la / de la /gi;
  $line =~ s/ ad[ij]utor/ pomocný/gsi;
  $line =~ s/(i|j)ubilatus]/slavný/gsi;

  $line =~ s/ (\.|\,|\:)/$1/gi;
  $line =~ s/\,\,/\,/gi;

  #	$line .= "Zkouška.\n" ;

  return $line;
}

# *** regula_emaus ($lang)
# returns the text of the Regula for the day
# This is the version of Czech Benedictines,
# which is being used also in Altovadum (O.Cist.)
sub regula_emaus : ScriptFunc {

  my $lang = shift;
  my @a;
  my $t = setfont($largefont, translate("Regula", $lang)) . "\n_\n";
  my $d = $day;
  my $l = leapyear($year);
  my $reading = 0;
  my $tomorrow = $d + 1;
  my $sequentia = 0;
  my $titulus;

  # remove leading zeros
  $month =~ s/^0+//g;
  $day =~ s/^0+//g;
  $d =~ s/^0+//g;

  if ($month == 2 && $day >= 24 && !$l) { $d++; }

  #  $fname = sprintf("%02i-%02i", $month, $d);

  $fname = checkfile($lang, 'Regula/Regula_OSB_Emaus.txt');

  if ($day == 23 && $month == 2 && $l == 0) {
    my $plus = $day + 1;
    $reading = 0;

    if (@a = do_read($fname)) {
      foreach $line (@a) {
        if ($line =~ /\<b\>Caput /i || $line =~ /\<b\>Incipit /i) {
          $titulus = $line;

          #$t .= "Titulus = \"$titulus\" \n_\n" ;
        }

        if ($line =~ /. $d\.$month\. ./i || $reading >= 1) {
          $reading++;
          next if ($reading == 1);

          if ($reading == 2) {
            if ($titulus =~ /Incipit/i) {
              my $title_in = translate("Lectio prologus", $lang);
              $titulus =~ s/Incipit Prologus/$title_in/i;
            } else {
              my $title_in = translate("Lectio regulae", $lang);
              $titulus =~ s/Caput/ $title_in /;
            }
            $t .= "$titulus. ";
          }

          if ($line =~ /\<b\>Caput /i || $line =~ /\<b\>Incipit /i) { $sequentia = 1; $t .= "\n_\n"; next; }

          if ($sequentia == 0) {
            $t .= " <i>" . translate('Sequentia', $lang) . ".</i> \n_\n";
            $sequentia = 1;
          }
          if ($reading == 3 && $sequentia == 0) { $t .= "\n_\n"; }

          $line =~ s/^\s+//;
          $line =~ s/\s+$//;

          if ($reading >= 1 && $line !~ /^$/) {

            #$line =~ s/^.*?\#//;
            #$line =~ s/^(\s*)$/_$1/;
            $line =~ s/oe/œ/g;
            $line =~ s/ae/æ/g;
            $line =~ s/Ae/Æ/g;
            $line =~ s/cæl/cœl/g;
            if ($line =~ /^\#\[ 25/i && $reading > 1) { $reading = 0; }
            $t .= "-- $line\n" unless ($reading == 0 || $reading == 1 || $line =~ /^\#\[/i);
          }
        }
      }
    }
  } else {
    $reading = 0;

    if (@a = do_read($fname)) {
      foreach $line (@a) {
        if ($line =~ /\<b\>Caput /i || $line =~ /\<b\>Incipit /i) {
          $titulus = $line;

          #$t .= "Titulus = \"$titulus\" \n_\n" ;
        }

        if ($line =~ /. $d\.$month\. ./i || $reading >= 1) {
          $reading++;
          next if ($reading == 1);

          if ($reading == 2) {
            if ($titulus =~ /Incipit/i) {
              my $title_in = translate("Lectio prologus", $lang);
              $titulus =~ s/Incipit Prologus/$title_in/i;
            } else {
              my $title_in = translate("Lectio regulae", $lang);
              $titulus =~ s/Caput/ $title_in /;
            }
            $t .= "$titulus. ";
          }

          if ($line =~ /\<b\>Caput /i || $line =~ /\<b\>Incipit /i) { $sequentia = 1; $t .= "\n_\n"; next; }

          if ($sequentia == 0) {
            $t .= " <i>" . translate('Sequentia', $lang) . ".</i> \n_\n";
            $sequentia = 1;
          }
          if ($reading == 3 && $sequentia == 0) { $t .= "\n_\n"; }

          $line =~ s/^\s+//;
          $line =~ s/\s+$//;

          if ($reading >= 1 && $line !~ /^$/) {

            #$line =~ s/^.*?\#//;
            #$line =~ s/^(\s*)$/_$1/;
            $line =~ s/oe/œ/g;
            $line =~ s/ae/æ/g;
            $line =~ s/Ae/Æ/g;
            $line =~ s/cæl/cœl/g;
            if ($line =~ /^\#\[/i && $reading > 1) { $reading = 0; }
            $t .= "-- $line\n" unless ($reading == 0 || $reading == 1);
          }
        }
      }
    }
  }

  #$t .= "Regula de Emaus. Date $d. $month. $year. Leap year: $l \n_\n";
  $t .= "\n_\n" . '$Tu autem';
  return $t;
}

#*** necrologium ($lang)
#returns the text of the Necrologium for the day
sub necrologium : ScriptFunc {

  my $lang = shift;
  my @a;
  my $t = setfont($largefont, translate("Necrologium", $lang)) . "\n";
  my $d = $day;
  my $l = leapyear($year);
  my $reading = 0;
  my $tomorrow = $d + 1;

  $tomorrow++ if $day == 28 && $month == 2 && $l == 0;    # On Feb 28 in a non-leap year, also read 29
                                                          #my $mensis;
  my @mensis = (
    'zero-ius', 'Januarius', 'Februarius', 'Martius', 'Aprilis', 'Majus', 'Junius', 'Julius',
    'Augustus', 'September', 'October', 'November', 'December',
  );

  $fname = checkfile($lang, "Necrologium/@mensis[$month].txt");
  if ($lang =~ /Bohemice|Cesky/i) { $fname = checkfile("Latin", "Necrologium/@mensis[$month].txt"); }

  # remove leading zeros
  $month =~ s/^0+//;
  $day =~ s/^0+//;
  $d =~ s/^0+//;

  # This reads the current part of the Necrologium by "greping" the day part in the text.
  # The month part is solved before in the filename.

  if (@a = do_read($fname)) {
    foreach $line (@a) {
      if ($line =~ /Die $d\./i || $reading >= 1) {
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        if ($line !~ /^$/) {
          $line =~ s/^.*?\#//;
          $line =~ s/^(\s*)$/_$1/;
          if ($line =~ /Die $tomorrow\./i) { last; }
          if ($lang =~ /Bohemice|Cesky/i) { $line = translate_cz("$line"); }
          $line =~ s/oe/œ/g;
          $line =~ s/ae/æ/g;
          $line =~ s/Ae/Æ/g;
          $line =~ s/Tento/Teuto/g;
          $line =~ s/•/r. /;

          if (!$reading) {
            $t = "v. $line" . "\n_\n";
          } elsif ($line =~ /Die|Dne/i) {
            $t .= "\n_\nv. $line" . "\n_\n";
          } else {
            $t .= "$line\n";
          }
        }
        $reading++;
      }
    }
  }

  $t .= '$Quorum animae' . "\n";    #_\n
  return $t;
}

#*** martyrologium_cz($lang)
#returns the text of the Czech martyrologium for the day
sub martyrologium_cz : ScriptFunc {

  my $lang = shift;
  my @a;
  my $t = setfont($largefont, translate("Necrologium", $lang)) . "\n";
  my $d = $day;
  my $l = leapyear($year);
  my $reading = 0;
  my $tomorrow = $d + 1;
  my $t = setfont($largefont, "Martyrologium ") . setfont($smallblack, "(anticip.)") . "\n_\n";
  my @mensis = (
    'zero-ius', 'ledna', 'února', 'března', 'dubna', 'května', 'června', 'července',
    'srpna', 'září', 'října', 'listopadu', 'prosince',
  );

  my $fname = nextday($month, $day, $year);

  # _t = tomorrow
  $month_t = $fname;
  $month_t =~ s/-.*//;
  $day_t = $fname;
  $day_t =~ s/.*?-//;
  $d = $day_t;

  # remove leading zeros.
  $month_t =~ s/^0+//;
  $day_t =~ s/^0+//;
  $d =~ s/^0+//;

  $fname = checkfile($lang, "Psalterium/Martyrologium.txt");

  # This reads the current part of the Necrologium by "greping" the day part in the text.
  # The month part is solved before in the filename.

  $t .= "v. M<b>artyrologium na den $d. @mensis[$month_t], Léta Páně $year.</b>" . "\n_\n";

  if ($day_t == 24 && $month_t == 2 && $l == 1) {
    $t .=
      "r. Památka velkého počtu svatých mučedníků a vyznavačů, taktéž svatých panen, jejichž přímluvu s v modlitbách vyprošujeme. †\n";
    $t .= '$Deo gratias' . "\n_\n";
    return $t;
  }

  # and if it IS a leap year...
  if ($day_t > 24 && $month_t == 2 && $l == 1) {
    my $minus = $day;
    $reading = 0;

    if (@a = do_read($fname)) {
      foreach $line (@a) {
        if ($line =~ /^$minus.* @mensis[$month]/i || $reading >= 1) {
          $reading++;
          $line =~ s/^\s+//;
          $line =~ s/\s+$//;

          if ($reading >= 1 && $line !~ /^$/) {
            $line =~ s/^.*?\#//;
            $line =~ s/^(\s*)$/_$1/;
            $line =~ s/oe/œ/g;
            $line =~ s/ae/æ/g;
            $line =~ s/Ae/Æ/g;
            if ($line =~ /A jinde/i) { $reading = 0; }
            $t .= "r. $line\n" unless ($reading == 0 || $reading == 1);
          }
        }
      }
    }
  } else {
    $reading = 0;

    if (@a = do_read($fname)) {
      foreach $line (@a) {
        if ($line =~ /^$d\..* @mensis[$month_t]/i || $reading >= 1) {
          $reading++;
          $line =~ s/^\s+//;
          $line =~ s/\s+$//;

          if ($reading >= 1 && $line !~ /^$/) {
            $line =~ s/^.*?\#//;
            $line =~ s/^(\s*)$/_$1/;
            $line =~ s/oe/œ/g;
            $line =~ s/ae/æ/g;
            $line =~ s/Ae/Æ/g;
            if ($line =~ /A jinde/i) { $reading = 0; }
            $t .= "r. $line\n" unless ($reading == 0 || $reading == 1);
          }
        }
      }
    }
  }

  $t .= '$Conclmart Cist' . "\n_\n";
  return $t;
}

1;
