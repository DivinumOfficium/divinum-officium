String.prototype.repeat = function(num){return new Array(num+1).join(this);};
String.prototype.reverse = function(){return this.split('').reverse().join('');};
var regexLatinLongPenult = /([ao]e|au|[aeiouyāēīōūȳăĕĭŏŭäëïöüÿ])(?!([bcdgkpt][rl]|qu|[bcdfghjklmnprstvy])[aeiouyāēīōūȳăĕĭŏŭäëïöüÿ])((?:[bcdfghjklmnprstvy]{2,}|[xz])(?:[ao]e|au|[aeiouyāēīōūȳăĕĭŏŭäëïöüÿ])[bcdfghjklmnprstvxyz]*)$/i;
var linkSelector="";
var linkDownloadSelector="";

var utf8_bom=String.fromCharCode(0xEF)+String.fromCharCode(0xBB)+String.fromCharCode(0xBF);
function encode_utf8( s )
{
  return utf8_bom+unescape( encodeURIComponent( s ) );
}
function decode_utf8( s )
{
  return decodeURIComponent( escape( s ) );
}

var mapBooks = {
  "Act": "Actus Apostolorum",
  "Acts": "Actus Apostolorum",
  "Apoc": "Apocalypsis",
  "Cant": "Canticum Canticorum",
  "Col": "Ad Colossenses",
  "Cor": "Ad Corinthios",
  "Dan": "Daniel",
  "Deut": "Deuteronomium",
  "Eccli": "Ecclesiasticus",
  "Eph": "Ad Ephesios",
  "Ephes": "Ad Ephesios",
  "Esth": "Esther",
  "Exod": "Exodus",
  "Ezech": "Ezechiel",
  "Gal": "Ad Galatas",
  "Gen": "Genesis",
  "Ha": "Habacuc",
  "Heb": "Ad Hebræos",
  "Hebr": "Ad Hebræos",
  "Is": "Isaias",
  "Isa": "Isaias",
  "Isaiae": "Isaias",
  "Jac": "Jacobi",
  "Jas": "Jacobi",
  "Jer": "Jeremias",
  "Joann": "Joannes",
  "Joannes": "Joannes",
  "Joel": "Joel",
  "John": "Joannis",
  "Jonæ": "Jonas",
  "Jud": "Judæ",
  "Judith": "Judith",
  "Lev": "Leviticus",
  "Luc": "Lucas",
  "Mach": "Machabæorum",
  "Malach": 'Malachias',
  "Marc": "Marcus",
  "Matt": "Matthæus",
  "Num": "Numeri",
  "Par": "Paralipomenon",
  "Pet": "Petri",
  "Petri": "Petri",
  "Phil": "Ad Philippenses",
  "Philipp": "Ad Philippenses",
  "Prov": "Proverbia",
  "Ps": "Psalmi",
  "Reg": "Regum",
  "Rom": "Ad Romanos",
  "Sap": "Sapientia",
  "Thess": "Ad Thessalonicenses",
  "Tim": "Ad Timotheum",
  "Tit": 'Ad Titum',
  "Tob": 'Tobiæ',
  "Tobias": 'Tobiæ'
};

if (typeof Object.assign != 'function') {
  // Must be writable: true, enumerable: false, configurable: true
  Object.defineProperty(Object, "assign", {
    value: function assign(target, varArgs) { // .length of function is 2
      'use strict';
      if (target == null) { // TypeError if undefined or null
        throw new TypeError('Cannot convert undefined or null to object');
      }

      var to = Object(target);

      for (var index = 1; index < arguments.length; index++) {
        var nextSource = arguments[index];

        if (nextSource != null) { // Skip over if undefined or null
          for (var nextKey in nextSource) {
            // Avoid bugs when hasOwnProperty is shadowed
            if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
              to[nextKey] = nextSource[nextKey];
            }
          }
        }
      }
      return to;
    },
    writable: true,
    configurable: true
  });
}

function makeExsurgeChantContext() {
  var ctxt = new exsurge.ChantContext(exsurge.TextMeasuringStrategy.Canvas);
  ctxt.condenseLineAmount = 1;
  ctxt.setGlyphScaling(1/16);
  ctxt.setFont("'Crimson Text', serif", 19.2 / 0.9);
  ctxt.spaceBetweenSystems = 0;
  ctxt.textStyles.dropCap.size = 64;
  ctxt.textStyles.annotation.size = 12.8;
  ctxt.minLyricWordSpacing *= 0.7;
  ctxt.accidentalSpaceMultiplier = 1.5;
  
  ctxt.specialCharProperties['font-family'] = "'Versiculum'";
  ctxt.specialCharProperties['font-variant'] = 'normal';
  // ctxt.specialCharProperties['font-size'] = (ctxt.lyricTextSize) + 'px';
  ctxt.specialCharProperties['font-weight'] = '400';
  const defaultSpecialCharText = ctxt.specialCharText;
  ctxt.specialCharText = function(char) { return defaultSpecialCharText(char).toLowerCase(); };
  ctxt.setRubricColor('#d00');
  return ctxt;
}

if(typeof HTMLTextAreaElement=='function') {
HTMLTextAreaElement.prototype.selectAndScroll = function(start,end,onlyUp) {
  var text = this.value;
  var txtBox = this;
  setTimeout(function(){
    if(text != txtBox.value) return;
    var scrollTop = txtBox.scrollTop;
    var extra = ''
    if(onlyUp) {
      var $txtBox = $(txtBox);
      var lineHeight = parseFloat($txtBox.css('line-height'));
      if(isNaN(lineHeight)) lineHeight = 1.2 * parseFloat($txtBox.css('font-size'));
      var rows = Math.floor($txtBox.height() / lineHeight);
      extra = '\n'.repeat(rows-1);
    }
    txtBox.value = text.slice(0,end) + extra;
    txtBox.scrollTop = txtBox.scrollHeight;

    txtBox.value = text;
    txtBox.setSelectionRange(start,end);
    if(((txtBox.scrollTop - scrollTop) * (onlyUp? -1 : 1)) < 0) txtBox.scrollTop = scrollTop;
  })
};
}
var regexToneModifiers = /(')|(\.{1,2})|(_{1,4}0?)/g
var regexTones = new RegExp("([/ ,;:`]+)|((?:[fF]|[cC][bB]?)[1-4])|(?:(-)?(([A-M])|([a-m]))(([Vv]{1,3})|(s{1,3})|((<)|(>)|(~))|(w)|(o)|(O)|((x)|(y))|(q)|((R)|(r0)|(r(?![1-5])))|(r[1-5])|(\\+))?((?:" + regexToneModifiers.source.replace(/\((?!\?:)/g,"(?:") + ")*)(?:\\[([^\\]]*)(?:]|$))?|(z0))","g");
//                          /([\/ ,;:`]+)|([cfCF][1-4])|(?:(-)?(([A-M])|([a-m]))(([Vv]{1,3})|(s{1,3})|((<)|(>)|(~))|(w)|(o)|(O)|((x)|(y))|(q)|((R)|(r0)|(r(?![1-5])))|(r[1-5]))?((?:(?:')|(?:\.{1,2})|(?:(?:_0?){1,4}))*)|(z0))|\[([^\]]*)(?:\]|$)                                )*)|(z0))|\[([^\]]*)(?:\]|$)
//                          /([\/ ,;:`]+)|([cfCF][1-4])|(?:(-)?(([A-M])|([a-m]))(([Vv]{1,3})|(s{1,3})|((<)|(>)|(~))|(w)|(o)|(O)|((x)|(y))|(q)|((R)|(r0)|(r(?![1-5])))|(r[1-5]))?((?:(?:')|(?:\.{1,2})|(?:(?:_0?){1,4}))*)|(z0))|\[([^\]]*)(?:\]|$)
var regexTonesSpliceIndex=27;
var regexToneModifiersCount = 4;
var rtg = {
  whitespace: 1,
  clef: 2,
  initioDebilis: 3,
  tone: 4,
  toneUpper: 5, // diamond
  toneLower: 6,
  noteType: 7,      // (([Vv]{1,3})|(s{1,3})|((<)|(>)|(~))|(w)|([oO])|([xy])|(q)]|(R|r0|r(?![1-5]))|(r[1-5])|(\+))
  virga: 8,        // [Vv]{1,3}
  stropha: 9,      // s{1,3}
  liquescentia: 10,      // [<>~]
  ascendingLiquescentia: 11,  // <
  descendingLiquescentia: 12,  // >
  diminutiveLiquescentia: 13,  // ~
  quilisma: 14,      // w
  oriscus: 15,      // o
  oriscusReverse: 16,    // O
  accidental: 17,      // [xy]
  flat: 18,        // x
  natural: 19,      // y
  q: 20,        // q
  lineaPunctum: 22,      // R
  lineaPunctumCavum: 23,    // r0
  punctumCavum: 24,      // r
  rNumber: 25,      // r[1-5]
  custos: 26,       // \+
  ictus: 27,        // (')
  dot: 28,          // (\.{1,2})
  episema: 29,      // ((?:_0?)){1,4})
  bracketed: 30,     // [text]
  autoCustos: 31    // z0
};

function setPdfLinkSelector(sel){
  linkSelector=sel;
};
function onDragStart(e){
  console.info(e);
  e.originalEvent.dataTransfer.setData("DownloadURL",this.getAttribute("data-downloadurl"));
};
function setGabcLinkSelector(sel){
  linkDownloadSelector=sel;
  $(sel).bind("dragstart",onDragStart);
};
function updateLinks(text){
  var header=getHeader(text);
  if(header){
    text = text.slice(header.original.length);
  } else {
    header = '%%\n';
  }
  if(linkSelector){
    $(linkSelector).attr("href","http://gregorio.gabrielmass.com/cgi/process.pl?gregtext="
      + window.escape(header+text) + "&gregfontselect=17&gregtextfontselect=12&greginitialselect=43&gregspaceselect=7mm&gregredselect=N&greglinethickselect=10&gregpaperselect=letterpaper&gregfaceselect=libertine&gregcropselect=N");
  }
  try {
    if(linkDownloadSelector){
      var utf8=encode_utf8(header+text);
      var url="data:text/plain;charset=utf8;base64,"+btoa(utf8);
      var filename = header.name||"Untitled";
      if(!filename.match(/\.gabc$/))filename += ".gabc";
      $(linkDownloadSelector).attr("charset","UTF-8")
        .prop("href",url)
        .prop("download",filename)
        .attr("data-downloadurl","text/plain:"+filename+":"+url);
    }
  } catch(e) {
  }
  return [header,text];
}

var rog = {
  syl:3,
  gabc:5,
  whitespace:7
};
var regexTag = /<(\/)?(\w+)>/i;
var regexOuter = /((([^\(\r\n]+)($|\())|\()([^\)]*)($|\))(?:(\s+)|(?=(?:\([^\)]*\))+(\s*))|)/g;
var regexHeaderEnd=/(?:^|\n)%%\s?\n/;
var regexHeaderLine = /^([\w-_.]+):\s*((?:[^;\r\n]|;[ \t])*)(?:;|$)/i;
var regexHeaderComment = /^%.*/;
function GabcHeader(text){
  if(typeof(text)!='string') text='';
  this.comments=[];
  this.cValues={};
  this.original='';
  var match=text.match(regexHeaderEnd);
  if(match){
    var txtHeader = this.original = text.slice(0,match.index+match[0].length);
    var lines = txtHeader.split(/\r?\n/g);
    for(var i=0; i < lines.length; ++i){
      var line=lines[i],
          match = regexHeaderLine.exec(line);
      if(match){
        var key = match[1].replace(/-([a-z])/g,function(a,letter) { return letter.toUpperCase(); });
        if(this[match[1]]) {
          var arrayName=match[1]+'Array';
          if(!this[arrayName]){
            this[arrayName] = [this[match[1]]];
          }
          this[arrayName].push(match[2]);
        } else {
          this[match[1]]=match[2];
        }
        if(key != match[1]) this[key] = this[match[1]];
      } else if((match = regexHeaderComment.exec(line))){
        if(line!='%%'){
          match = regexHeaderLine.exec(line.slice(1));
          if(match){
            var key = match[1].replace(/-([a-z])/g,function(a,letter) { return letter.toUpperCase(); });
            this.cValues[match[1]]=match[2];
            if(key != match[1]) this.cValues[key] = match[2];
          } else {
            this.comments[i]=line;
          }
        }
      }
    }
  }
}
GabcHeader.prototype.toString = function(){
  var result=[];
  for(key in this){
    if(key=='length' || key=='original' || key=='comments' || key=='cValues' || (typeof this[key])!="string")continue;
    var alternateKey = key.replace(/[A-Z]/g,function(letter) { return '-'+letter.toLowerCase(); });
    if(alternateKey != key && alternateKey in this) continue;
    var array = this[key+'Array'];
    if(array) {
      for(var i=0; i < array.length; ++i) {
        result.push(key + ': ' + array[i] + ';');
      }
    } else {
      result.push(key + ': ' + this[key] + ';');
    }
  }
  for(key in this.cValues){
    if(key.length==0 || !this.cValues.hasOwnProperty(key))continue;
    result .push('%'+key + ': ' + this.cValues[key] + ';');
  }
  for(i in this.comments){
    if(!this.comments.hasOwnProperty(i)) continue;
    try{
      result.splice(i,0,this.comments[i]);
    } catch(e){}
  }
  return result.join('\n') + '\n%%\n';
};
function getHeaderLen(text){
  var match=text.match(regexHeaderEnd);
  if(match){
    return match.index+match[0].length;
  } else {
    return 0;
  }
}
function getHeader(text){
  return new GabcHeader(text);
}

function getTagsFrom(txt){
  var tm,r=[];
  while(tm = regexTag.exec(txt)) {
    r.push(tm[2]);
    var lastIndex = tm.index + tm[0].length;
    if(tm.index == 0)
      txt = txt.slice(tm[0].length);
    else txt = txt.slice(0,tm.index) + txt.slice(lastIndex);
  }
  return r;
}

function transposeGabc(gabc,offset,noParens) {
  var replaceLetter = function(letter, clef) {
    if(clef) return letter;
    var newLetter = String.fromCharCode(offset + letter.charCodeAt(0));
    if(!newLetter.match(/[a-m]/i)) throw true;
    return newLetter;
  };
  var regex = /([cf]b?[1-4])|[a-mA-M]/g;
  if(noParens) return gabc.replace(regex, replaceLetter);
  return gabc.replace(/\(([^)]+)\)/g, function(whole,gabc) {
    return '(' + gabc.replace(regex, replaceLetter) + ')';
  });
}

function gabcEditorKeyDown(e) {
  var $this = $(this), txt = $this.val(), selStart = this.selectionStart, selEnd = this.selectionEnd;
  switch(e.which) {
    case 66: //b
      if(e.ctrlKey || e.altKey) {
        e.preventDefault();
        index = txt.indexOf(' ',this.selectionEnd);
        if(index <= 0) index = txt.length;
        $this.val(txt.slice(0,index) + ' ()' + txt.slice(index));
        this.selectionEnd = this.selectionStart = index + 2;
      }
      break;
    case 83: //s
      if(selStart == selEnd && (e.ctrlKey || e.altKey) && txt[selStart-1]!='(' && txt[selStart]!=')') {
        e.preventDefault();
        $this.val(txt.slice(0,selStart) + '()' + txt.slice(selStart));
        this.selectionEnd = this.selectionStart = selStart + 1;
      }
      break;
    case 9: { //tab
      var index, indexEnd, headerIndex;
      e.preventDefault();
      if(e.shiftKey) {
        // go backwards
        index = this.selectionStart;
        headerIndex = txt.lastIndexOf('\n%%\n',index-1);
        index = txt.lastIndexOf(')',index - 1);
        if(index <= headerIndex) index = txt.lastIndexOf(')');
        if(index >= 0) {
          indexEnd = index;
          index = txt.lastIndexOf('(',index);
        }
      } else {
        index = this.selectionEnd;
        var regex = /(\()|(-(?!\())|(\s+(?![:;!.]))|([^)\s]$)/g;
        regex.lastIndex = index;
        var match;
        while((match = regex.exec(txt)) && (match[2]||match[3])) {
          if(match[3] && (match.index==0 || txt[match.index-1]==')')) continue;
          //check if this line is in the header:
          index = match.index;
          var begIndex = txt.lastIndexOf('\n',index-1)+1,
          endIndex = txt.indexOf('\n',index);
          if(endIndex < 0) endIndex = txt.length;
          if(txt[endIndex]=='\r') endIndex--;
          var line = txt.slice(begIndex,endIndex);
          if(line.match(/^(?:\s*(?:%.*|[-\w]+:[^;]+;)\s*|%%)$/)) {
            continue;
          } else {
            break;
          }
        }
        if(match) {
          if(match[1]) {
            index = match.index;
          } else if(match[2]||match[3]||match[4]) {
            if(match[2]||match[4]) index = match.index+1;
            txt = txt.slice(0,index) + '()' + txt.slice(index);
            $this.val(txt);
          } else {
            index = txt.indexOf('(');
          }
        } else {
          index = txt.indexOf('(');
        }
        index = txt.indexOf('(',index);
        
        if(index >= 0) {
          indexEnd = txt.indexOf(')',index);
        }
      }
      if(index >= 0 && indexEnd >= 0) {
        this.selectionStart = index + 1;
        this.selectionEnd = indexEnd;
      }
      break;
    }
    case 57:
      if(e.shiftKey) { //open parenthesis
        var rightSide = this.value.slice(selEnd),
            firstClose = rightSide.indexOf(')'),
            firstOpen = rightSide.indexOf('(');
        if(firstClose < 0 || (firstOpen >= 0 && firstOpen < firstClose)) {
          this.value=this.value.slice(0,this.selectionStart) + '()' + this.value.slice(selEnd);
          this.selectionStart=this.selectionEnd=selStart+1;
          e.preventDefault();
          return;
        }
      }
      break;
    case 48:
      if(e.shiftKey) { //close parenthesis
        if(selStart == selEnd && txt[selStart]==')') {
          e.preventDefault();
          this.selectionStart = this.selectionEnd = selStart + 1;
        }
      }
      break;
    case 8: {
      var selEnd = this.selectionEnd;
      if(selEnd == this.selectionStart && selEnd > 0 && this.value[selEnd]==')' && this.value[selEnd-1]=='(') {
        e.preventDefault();
        this.value=this.value.slice(0,this.selectionStart-1) + this.value.slice(selEnd+1);
        this.selectionStart=this.selectionEnd=selEnd-1;
      }
      break;
    }
    case 38: // up
    case 40: // down
      if(e.altKey) {
        var up = e.which === 38;
        e.preventDefault();
        var allGabc = this.value
            header = getHeader(allGabc),
            selectionStart = this.selectionStart,
            selectionEnd = this.selectionEnd,
            gabc = allGabc = allGabc.slice(header.original.length);
        if(selectionStart != selectionEnd) {
          var startIndex = Math.max(0,selectionStart - header.original.length),
              endIndex = Math.max(0,selectionEnd - header.original.length),
              lastOpenParen = allGabc.lastIndexOf('(',startIndex),
              lastCloseParen = allGabc.lastIndexOf(')',startIndex),
              firstOpenParen = allGabc.indexOf('(',endIndex),
              firstCloseParen = allGabc.indexOf(')',endIndex);
          if(firstOpenParen < 0) firstOpenParen = Infinity;
          if(firstCloseParen < 0) firstCloseParen = Infinity;
          gabc = gabc.slice(startIndex, endIndex);
          if(lastOpenParen > lastCloseParen) gabc = '(' + gabc;
          if(firstCloseParen < firstOpenParen) gabc += ')';
        }
        var offset = up? 1 : -1;
        try {
          gabc = transposeGabc(gabc, offset)
        } catch(e) {
          return;
        }
        if(selectionStart == selectionEnd) {
          this.value = header.original + gabc;
        } else {
          if(lastOpenParen > lastCloseParen) gabc = gabc.slice(1);
          if(firstCloseParen < firstOpenParen) gabc = gabc.slice(0,-1);
          this.value = header.original + allGabc.slice(0,startIndex) + gabc + allGabc.slice(endIndex);
        }
        this.setSelectionRange(selectionStart, selectionEnd);
      }
      break;
  }
}

function makeInternationalTextBoxKeyDown(convertFlexa){
  var lastKey = 0;
  var dictionaries=
      {"'":
        {"false":
          {'a':'á',
           'e':'é',
           'i':'í',
           'o':'ó',
           'u':'ú',
           'y':'ý',
           'A':'Á',
           'E':'É',
           'I':'Í',
           'O':'Ó',
           'U':'Ú',
           'Y':'Ý',
           'æ':"ǽ",
           'œ':"œ́",
           'Æ':"Ǽ",
           'Œ':"Œ́"
           },
        "true":
          {'a':'ä',
           'e':'ë',
           'i':'ï',
           'o':'ö',
           'u':'ü',
           'y':'ÿ',
           'A':'Ä',
           'E':'Ë',
           'I':'Ï',
           'O':'Ö',
           'U':'Ü',
           'æ':"aë",
           'œ':"oë",
           'Æ':"Aë",
           'Œ':"Oë"
          }
        },
        "e":
        {"false":
          {'a':'æ',
           'o':'œ',
           'A':'Æ',
           'O':'Œ'
          },
        "true":
          {'a':'æ',
           'o':'œ',
           'A':'Æ',
           'O':'Œ'
          }
        },
        "Backspace":
        {"false":
          {
            '†':"+",
            'æ':"ae",
            'œ':"oe",
            'Æ':"Ae",
            'Œ':"Oe",
            'á':'a',
            'é':'e',
            'í':'i',
            'ó':'o',
            'ú':'u',
            'ý':'y',
            'Á':'A',
            'É':'E',
            'Í':'I',
            'Ó':'O',
            'Ú':'U',
            'Ý':'Y',
            'ä':'a',
            'ë':'e',
            'ï':'i',
            'ö':'o',
            'ü':'u',
            'ÿ':'y',
            'Ä':'A',
            'Ë':'E',
            'Ï':'I',
            'Ö':'O',
            'Ü':'U',
            'Ǽ':"Aé",
            'ǽ':"aé",
            'Œ́':'Oé',
            'œ́':'oé'
          },
        "true":
          {
          }
        }
      };
      var removeAccent = {
        'á':'a',
        'é':'e',
        'í':'i',
        'ó':'o',
        'ú':'u',
        'ý':'y',
        'Á':'A',
        'É':'E',
        'Í':'I',
        'Ó':'O',
        'Ú':'U',
        'Ý':'Y',
        'Ǽ':"Æ",
        'ǽ':"æ",
        "áu": "au",
        "oé": "oe",
        "aé": "ae"
      };
      var accentSyllable = function(syllables,which) {
        word = '';
        for(var i = 0; i<syllables.length; ++i) {
          if(which == i) {
            word = syllables[i].replace(/((?:[gq]u|i|[^aeiouyáéíóúýæœ])*)([ao][eé]|[aá]u|[aeiouyáéíóúýǽæœ])(?=[^aeiouyáéëíóúýǽæœ]|$)/, function(match,first,vowel){
              if(vowel.length == 2) {
                if(vowel[1] == 'u') {
                  return first + 'áu';
                } else {
                  first += vowel[0];
                  vowel = vowel[1];
                }
              }
              return first + (dictionaries["'"]['false'][vowel] || vowel);
            }) + word;
          } else {
            word = syllables[i].replace(/((?:[gq]u|i|[^aeiouyáéíóúýæœ])*)(ae|au|oe|[aeiouyáéíóúýǽæœ])(?=[^aeiouyáéëíóúýǽæœ]|$)/, function(match,first,vowel){
              return first + (removeAccent[vowel] || vowel);
            }) + word;
          }
        }
        return word;
      }
  return function(e){
    if(e.altKey || e.metaKey || e.ctrlKey) return;
    if(typeof(getHeaderLen)=='function' && getHeaderLen(this.value)>0) {
      // Only process as international textbox if the cursor is not within parentheses:
      var lastOpenParen = this.value.lastIndexOf('(',this.selectionStart-1);
      var lastCloseParen = this.value.lastIndexOf(')',this.selectionStart-1);
      if(lastCloseParen < lastOpenParen) return;
    }
    if(convertFlexa && e.which == 187 && e.shiftKey) { //if + was entered
      var selStart=this.selectionStart;
      var len=1;
      this.value=this.value.slice(0,selStart) + '†' + this.value.slice(this.selectionEnd);
      this.selectionStart=this.selectionEnd=selStart+len;
      e.preventDefault();
      return;
    }
    var isEnglish=$("#cbEnglish")[0] && cbEnglish.checked;
    if(e.which == 49 || e.which == 50 || (e.which == 51 && isEnglish)) {
      if(e.shiftKey) return;
      // swap e.which (49;50;51 => 2;1;0)
      var which = 2 - (e.which - 49),
          start = this.selectionStart,
          end = this.selectionEnd,
          wordStart = this.value.lastIndexOf(' ',start) + 1,
          wordEnd = this.value.indexOf(' ',end);
          if(wordEnd < 0) wordEnd = this.value.length;
      if(isEnglish) {
        var phrase = this.value.slice(wordStart,end).replace(/\*/g,''),
            syllables = Syl.syllabify(phrase),
            which = syllables.length - 1 - which;
        if(which < 0) return;
        var syl = syllables[which];
        phrase = phrase.slice(0,syl.index) + syl.sylnospace + '*' + phrase.slice(phrase.indexOf(syl.sylnospace,syl.index) + syl.sylnospace.length);
        this.value = this.value.slice(0, wordStart) + phrase + this.value.slice(end);
        // check if this phrase has multiple accents:
        var lines = splitSentences(this.value.slice(wordStart));
        if(lines && lines[0] && lines[0].accents > 1 && lines[0][1].length - phrase.length < 4) {
          line = lines[0];
          which = syllables.length - 1 - which;
          phrase = this.value.slice(0,end);
          syllables = Syl.syllabify(phrase);
          syllables = syllables.slice(0, syllables.length - 1 - which);
          var lastSyl = syllables.slice(-1)[0];
          var last3syl = syllables.slice(-3);
          end = last3syl[0].index;
          phrase = this.value.slice(end, lastSyl.index + lastSyl.sylnospace.length);
          if(phrase.indexOf('*')<0) {
            var accentSyl = lastSyl.word.length==1? lastSyl : last3syl[1];
            accentSyl.separator = '*';
            var index = accentSyl.index - end + accentSyl.sylnospace.length;
            phrase = phrase.slice(0,index) + '*' + phrase.slice(index);
            this.value = this.value.slice(0, end) + phrase + this.value.slice(end + phrase.length - 1);
          }
          this.selectAndScroll(last3syl[0].index, end + phrase.indexOf(lastSyl.sylnospace,lastSyl.index-end) + lastSyl.sylnospace.length + (lastSyl.separator && lastSyl.separator.length || 0), e.shiftKey);
          
        } else {
          this.selectAndScroll(start, wordStart + phrase.length, e.shiftKey);
        }
        e.preventDefault();
        return;
      } else {
        // TODO: expand selection to entire word if it isn't currently on a whole word
        var word = this.value.slice(start,end);
        var syllables = word.match(regexLatin);
        if(!syllables) return;
        if(syllables.length>2) {
          syllables = syllables.reverse();
          word = accentSyllable(syllables,which);
          this.value = this.value.slice(0,start) + word + this.value.slice(end);
          this.selectAndScroll(start,end, e.shiftKey);
          e.preventDefault();
        }
      }
    }
    if(e.which==9 || (!isEnglish && !e.shiftKey && (e.which == 49 || e.which == 50))) {
      if(isEnglish) {
        var selectionEnd = this.selectionEnd;
        while(/\s/.test(this.value[selectionEnd])) {
          ++selectionEnd;
        }
        if(this.selectionEnd == this.selectionStart) {
          selectionEnd = 0;
          this.scrollTop = 0;
        }
        var part, lines, line;
        if(e.shiftKey) {
          part = this.value.slice(0,this.selectionStart);
          lines = splitSentences(part);
          if(lines.length<2) return;
          line = lines.slice(-2)[0];
          if(line) selectionEnd = part.lastIndexOf(line[1]); 
        } else {
          part = this.value.slice(selectionEnd);
          lines = splitSentences(part);
          line = lines[0];
          var convertedWhitespace = this.value.slice(0,selectionEnd).replace(/\s/g,' ');
          while(line && (line[1].length < 4 || Syl.syllabify(line[1]).length < 3)) {
            if(selectionEnd > 0) {
              selectionEnd = Math.max(0, convertedWhitespace.lastIndexOf(' '));
              convertedWhitespace = convertedWhitespace.slice(0, selectionEnd);
              part = this.value.slice(selectionEnd);
              lines = splitSentences(part);
              line = lines[0];
            } else {
              line = lines[1];
              break;
            }
          }
          if(line) selectionEnd += part.indexOf(line[1]);
        }
        if(!line) return;
        line = line[1];
        var syllables = Syl.syllabify(line);
        if(syllables.length<3) return;
        var lastSyl = syllables.slice(-1)[0];
        var last3syl = syllables.slice(-3);
        if(line.indexOf('*',last3syl[0].index)<0) {
          var accentSyl = lastSyl.word.length==1? lastSyl : last3syl[1];
          accentSyl.separator = '*';
          var index = accentSyl.index + accentSyl.sylnospace.length;
          line = line.slice(0,index) + '*' + line.slice(index);
          this.value = this.value.slice(0, selectionEnd) + line + this.value.slice(selectionEnd + line.length - 1);
        }
        this.selectAndScroll(selectionEnd + syllables.slice(-3)[0].index, selectionEnd + line.indexOf(lastSyl.sylnospace,lastSyl.index) + lastSyl.sylnospace.length + (lastSyl.separator && lastSyl.separator.length || 0), e.shiftKey);
        e.preventDefault();
        return;
      }
      // else Latin:
      var index = e.shiftKey? this.selectionStart : this.selectionEnd;
      if(e.which == 9 && this.selectionEnd == this.selectionStart) index = e.shiftKey? this.value.length : 0;
      var subIndex;
      while(true) {
        var slice = e.shiftKey? this.value.slice(0,index).reverse() : this.value.slice(index),
            match = slice.match(/[a-zæœ]{3,}(?=$|[\s,.;!\?])/i),
            word = match && match[0] || '';
        if(e.shiftKey) word = word.reverse();
        if(e.shiftKey) index -= match.index + word.length;
          else index += match.index;
        var syllables = word.match(regexLatin);
        if(!syllables || syllables.length <= 2) {
          if(!e.shiftKey) index += word.length;
          continue;
        }
        var longPenult = word.match(regexLatinLongPenult);
        if(longPenult) {
          this.value = this.value.slice(0,index) + accentSyllable(syllables.reverse(),1) + this.value.slice((index += word.length));
          this.selectAndScroll(index - word.length, index, e.shiftKey);
          continue;
        }
        this.selectAndScroll(index, index + word.length, e.shiftKey);
        e.preventDefault();
        break;
      }
    }
    var dictionary=dictionaries[e.key];
    if(dictionary && this.selectionStart==this.selectionEnd && this.selectionStart>0){
      var previousChar=this.value[this.selectionStart-1];
      var r=dictionary[e.shiftKey][previousChar];
      if(r){
        var selEnd=this.selectionEnd;
        var len=r.length - 1;
        this.value=this.value.slice(0,--this.selectionStart) + r + this.value.slice(selEnd);
        this.selectionStart=this.selectionEnd=selEnd+len;
        e.preventDefault();
        return;
      }
    }
  }
};
var internationalTextBoxKeyDown = makeInternationalTextBoxKeyDown(true);
function calculateDefaultStartPitch(startPitch, lowPitch, highPitch) {
  return new exsurge.Pitch(startPitch + ((4 * 12 + 7) - Math.floor((lowPitch + highPitch) / 2)));
}
var Tone;
if(typeof window=='object') (function(window) {
  var synth;
  if(Tone) {
    synth = new Tone.Synth({
      "oscillator" : {
          type: "custom",
          partials: [0.3,0.03,0.05]
        },
        "envelope" : {
          "attack" : 0.05,
          "decay" : 0.3,
          "sustain" : 0.4,
          "release" : 0.8,
        }
    }).toMaster();
    Tone.Transport.bpm.value = 165;
    window.setTempo = function(newTempo) { Tone.Transport.bpm.value = newTempo || 165; }
    window.setRelativeTempo = function(delta) {
      var state = Tone.Transport.state;
      Tone.Transport.stop();
      var val = Tone.Transport.bpm.value = Math.round(Math.max(0, Tone.Transport.bpm.value + delta)) || 165;
      if(state === 'started') {
        Tone.Transport.clear(timeoutNextNote);
        Tone.Transport.start();
        timeoutNextNote = Tone.Transport.scheduleOnce(playNextNote, '+8n');
      }
      return val;
    }
    window.setIsUsingSolesmesLengths = function(val) {
      localStorage.isUsingSolesmesLengths = val;
    }
    window.getIsUsingSolesmesLengths = function() {
      return (localStorage.isUsingSolesmesLengths !== 'false');
    }
    window.toggleIsUsingSolesmesLengths = function() {
      return (localStorage.isUsingSolesmesLengths = !getIsUsingSolesmesLengths());
    }
    window.playScore = function(score, firstPitch, startNote){
      Tone.Transport.clear(timeoutNextNote);
      Tone.Transport.start();
      if($('#mediaControls').length == 0) {
        $(document.body).append("<div id='mediaControls'>\
  <div>\
    <div class='parent-use-solesmes-lengths'>\
      <button title='Use Solesmes length for salicus' class='btn btn-sm btn-info btn-use-solesmes-lengths'><span class='glyphicon glyphicon-" + (getIsUsingSolesmesLengths()? 'check' : 'unchecked') + "'></span> <img src='salicus.svg' style='height: 16px'></button>\
    </div>\
    <div class='btn-group'>\
      <button class='btn btn-sm btn-primary play-pause'><span class='glyphicon glyphicon-pause'></span></button>\
      <button class='btn btn-sm btn-primary step-forward'><span class='glyphicon glyphicon-step-forward'></span></button>\
      <button class='btn btn-sm btn-default with-next tempo-minus' style='padding-right:10px'><span class='glyphicon glyphicon-minus'></span></button>\
      <div class='btn btn-sm btn-default with-next' style='padding-left:2px;padding-right:2px'>\
        <span id='tempo-number'>165</span> BPM</div>\
      <button class='btn btn-sm btn-default tempo-plus' style='padding-left:10px'><span class='glyphicon glyphicon-plus'></span></button>\
      <button class='btn btn-sm btn-danger stop'><span class='glyphicon glyphicon-stop'></span></button>\
    </div>\
  </div>\
</div>");

      }
      $('#mediaControls').removeClass('offscreen');
      if(syllable) {
        syllable.classList.remove('active');
        syllable = null;
      }
      var originalSvg = score.svg;
      var dropCap = !startNote && $('text', originalSvg)[0];
      if(dropCap)
        dropCap.classList.add('active');
      var noteId = 0;
      var notes = [].concat.apply([],score.notations.map(function(notation) { return notation.notes || notation; })).filter(function(notation) { return !notation.isAccidental; });
      if(startNote) noteId = Math.max(0, notes.indexOf(startNote));
      if(!firstPitch) firstPitch = score.defaultStartPitch;
      if(!firstPitch) {
        var startPitch = notes[0].pitch.toInt(),
            pitches = notes.filter(function(note){return note.pitch;}).map(function(note) { return note.pitch && note.pitch.toInt(); }),
            lowPitch = Math.min.apply(null, pitches),
            highPitch = Math.max.apply(null, pitches);
        firstPitch = score.defaultStartPitch = calculateDefaultStartPitch(startPitch, lowPitch, highPitch);
      }
      if(firstPitch.toInt) firstPitch = firstPitch.toInt();
      transpose = firstPitch - notes[0].pitch.toInt();
      _isPlaying = true;

      function getArePitchesEqual () {
        var pitches = arguments[0] && Array.isArray(arguments[0]) ? arguments[0] : arguments;
        if(pitches.length <= 1) return true;
        var pitch = pitches[0];
        for (var i=0; i < pitches.length; i++) {
          if(pitches[i].step !== pitch.step || pitches[i].octave !== pitch.octave) {
            return false;
          }
        }
        return true
      }

      function getIsLastNoteInNeume (note) {
        return note === note.neume.notes[note.neume.notes.length-1];
      }
      function getIsFirstNoteInNeume (note) {
        return note === note.neume.notes[0];
      }

      function getNoteIdForNote (notes, note) {
        return notes.findIndex(function (n) { return n === note; });
      }
      function getIsSalicus (notes, noteId) {
        var note = notes[noteId];
        var nextNote = notes[noteId + 1];
        if(nextNote && nextNote.constructor != exsurge.Note) nextNote = null;
        var prevNote = notes[noteId - 1];
        if(prevNote && prevNote.constructor != exsurge.Note) prevNote = null;
        
        if (
          note.ictus && prevNote && 
          (note.pitch.toInt() - prevNote.pitch.toInt() == 7) && 
          (nextNote.pitch.toInt() - note.pitch.toInt() == 1)
        ) {
          return true;
        } else if (
          getIsUsingSolesmesLengths() &&
          note.ictus && note.ictus.glyphCode === "VerticalEpisemaBelow" &&
          (note.glyphVisualizer.glyphCode === "PodatusLower" || note.glyphVisualizer.glyphCode === "BeginningAscLiquescent") && 
          (note.pitch.toInt() - prevNote.pitch.toInt() > 0) && 
          (nextNote.pitch.toInt() - note.pitch.toInt() > 0)
        ) {
          return true;
        }

        return false;
      }

      function getNoteDuration (notes, noteId) {
        var duration = 1;
        var note = notes[noteId];
        var nextNote = notes[noteId + 1];
        if(nextNote && nextNote.constructor != exsurge.Note) nextNote = null;
        var prevNote = notes[noteId - 1];
        if(prevNote && prevNote.constructor != exsurge.Note) prevNote = null;
        
        if(note.morae.length) {
          duration = 2;
        } else if(nextNote && (nextNote.morae.length > 1 || nextNote.shape == exsurge.NoteShape.Quilisma || getIsSalicus(notes, noteId))) {
          duration = 1.8;
        } else if(note.episemata.length) {
          var episemataCount = 1;
          if(prevNote && prevNote.episemata.length) ++ episemataCount;
          if(nextNote && nextNote.episemata.length) ++ episemataCount;
          duration += 0.9 / episemataCount;
        }

        return duration;
      }

      function getIsApostropha (note) {
        var neume = note.neume;
        return neume.isNeume && 
               neume.notes.length > 1 &&
               getArePitchesEqual(neume.notes.map(function (n) { return n.pitch; }));
      }

      function getPressus (notes, noteId) {
        var pressus;
        var note = notes[noteId];
        var nextNote = notes[noteId + 1];
        if(nextNote && nextNote.constructor != exsurge.Note) nextNote = null;
        var prevNote = notes[noteId - 1];
        if(prevNote && prevNote.constructor != exsurge.Note) prevNote = null;
        var noteBeforePrev = notes[noteId - 2];
        if(noteBeforePrev && noteBeforePrev.constructor != exsurge.Note) noteBeforePrev = null;

        if (
          nextNote && nextNote.morae.length === 0 && note.morae.length === 0 && 
          getIsLastNoteInNeume(note) && getIsFirstNoteInNeume(nextNote) && 
          getArePitchesEqual(note.pitch, nextNote.pitch) &&
          (!prevNote || !getPressus(notes, noteId - 1)) &&
          !getIsApostropha(note) && !getIsApostropha(nextNote) &&
          nextNote.neume.lyrics.length === 0
        ) {
          pressus = [note, nextNote];
        } else if (
          prevNote && prevNote.morae.length === 0 && note.morae.length === 0 &&
          getIsLastNoteInNeume(prevNote) && getIsFirstNoteInNeume(note) &&
          getArePitchesEqual(prevNote.pitch, note.pitch) &&
          (!noteBeforePrev || !getPressus(notes, noteId - 2)) &&
          !getIsApostropha(prevNote) && !getIsApostropha(note) &&
          note.neume.lyrics.length === 0
        ) {
          pressus = [prevNote, note];
        }

        return pressus;
      }

      function playNextNote (time){
        var note = notes[noteId];
        if(noteElem) noteElem.classList.remove('active','porrectus-left','porrectus-right');
        if(originalSvg != score.svg || note == null) {
          if(syllable) syllable.classList.remove('active');
          _isPlaying = false;
        }
        if(!_isPlaying) {
          if(dropCap) dropCap.classList.remove('active');
          $('#mediaControls').addClass('offscreen');
          return;
        }
        var duration = 1;
        if(note.constructor != exsurge.Note) {
          while(note.constructor != exsurge.Note && (!note.isDivider || note.constructor === exsurge.QuarterBar)) {
            if(!(note = notes[++noteId])) return;
          }
          if(note.isDivider) {
            if(syllable) syllable.classList.remove('active');
            if(note.constructor === exsurge.FullBar || note.constructor === exsurge.DoubleBar) {
              duration = 2;
            } // otherwise (for half bar) duration is default of 1.
          }
        }
        noteElem = note.svgNode;
        if(noteElem) {
          var href = noteElem.attributes.getNamedItem('href').value;
          if(href == '#None') {
            noteElem = noteElem.previousSibling;
            noteElem.classList.remove('porrectus-left');
            noteElem.classList.add('porrectus-right');
          } else if(/^#Porrectus/.test(href)) {
            noteElem.classList.add('porrectus-left');
          }
          noteElem.classList.add('active');
          var tmpSyllable = $(noteElem).parent().parent().find('text')[0];
          if(tmpSyllable && tmpSyllable != syllable) {
            if(dropCap && syllable) dropCap.classList.remove('active');
            if(syllable) syllable.classList.remove('active');
            syllable = tmpSyllable;
            if(syllable) syllable.classList.add('active');
          }
        }
        if(note.constructor === exsurge.Note) {
          duration = getNoteDuration(notes, noteId);
          var isUsingSolesmesLengths = getIsUsingSolesmesLengths();
          var isApostropha = getIsApostropha(note);
          var pressus = getPressus(notes, noteId);
          var noteName = tones.getNoteName(note.pitch, transpose);
          if (isApostropha || pressus) {
            var totalDuration = 0;
            if (isApostropha && note.neume.notes[0] === note) {
              note.neume.notes.forEach(function (note) {
                totalDuration += getNoteDuration(notes, getNoteIdForNote(notes, note));
              });
            } else if (pressus && pressus[0] === note) {
              totalDuration += getNoteDuration(notes, noteId);
              totalDuration += getNoteDuration(notes, noteId+1);
            }

            if(totalDuration > 0) synth.triggerAttackRelease(noteName, new Tone.Time("4n").toSeconds()*totalDuration, time);
          } else {
            synth.triggerAttackRelease(noteName, new Tone.Time("4n").toSeconds()*duration, time);
          }
        }
        ++noteId;
        if(noteId >= notes.length) _isPlaying = false;
        if(Tone.Transport.state != 'started') return;
        timeoutNextNote = Tone.Transport.scheduleOnce(playNextNote, '+' + (new Tone.Time("4n").toSeconds()*duration));
      };
      timeoutNextNote = Tone.Transport.scheduleOnce(playNextNote);
      window.playNextNote = playNextNote;
      window.playPauseScore = function() {
        if(timeoutNextNote) {
          Tone.Transport.clear(timeoutNextNote);
          Tone.Transport.pause();
          timeoutNextNote = null;
        } else {
          Tone.Transport.start();
          playNextNote();
          return true;
        }
      }
      window.highlightCurrentlyPlayingNote = function() {
        if(noteElem) {
          noteElem.classList.add('active');
        }
        if(syllable) {
          syllable.classList.add('active');
        }
      }
    };
    window.stopScore = function(){
      Tone.Transport.stop();
      _isPlaying=false;
      $('#mediaControls').addClass('offscreen');
    }
  } else {
    Tone = {};
    window.setTempo = window.setRelativeTempo = window.playScore = window.stopScore = function(){};
  }
  var timeoutNextNote, transpose = 0;
  var _isPlaying=false;
  var noteElem, syllable;
  window.isPlayingChant = function() {
    return _isPlaying;
  }
  window.removeChantContextMenus = function() {
    $('svg.ChantScore use[source-index].active,svg.ChantScore text[source-index].active').each(function(){ this.classList.remove('active','porrectus-left','porrectus-right'); });
    $('.chant-context').remove();
    $('.btn-group.open').removeClass('open');
    if(_isPlaying) window.highlightCurrentlyPlayingNote && window.highlightCurrentlyPlayingNote();
  }
  var _getNoteProperties = function(note) {
    var neume = note.neume;
    var notations = neume.mapping.notations;
    var notes = notations.reduce(function(result, notation) {
      if(notation.notes) return result.concat(notation.notes);
      return result.concat(null);
    }, []);
    var noteIndex = notes.indexOf(note);
    var previousNote = notes[noteIndex-1];
    var nextNote = notes[noteIndex+1];
    var hasPreviousNote = !!previousNote;
    var hasNextNote = !!nextNote;
    if(previousNote && neume.hasLyrics() && previousNote.neume.lyrics[0] !== neume.lyrics[0]) previousNote = null;
    if(nextNote && nextNote.neume.hasLyrics() && nextNote.neume.lyrics[0] !== neume.lyrics[0]) nextNote = null;
    var result = {note: note, notes: notes, noteIndex: noteIndex};
    result.isRepeatedNote = (nextNote && nextNote.staffPosition === note.staffPosition) || (previousNote && previousNote.staffPosition === note.staffPosition);
    result.hasMorae = note.morae.length > 0 || (nextNote && nextNote.morae.length > 1);
    result.hasEpisemata = note.episemata.length > 0;
    result.isTorculus = neume.constructor === exsurge.Torculus;
    result.isPesSubpunctis = neume.constructor === exsurge.PesSubpunctis && neume.notes.indexOf(note) < 3;
    result.isQuilisma = note.shape === exsurge.NoteShape.Quilisma;
    result.isLastOfNeume = neume.trailingSpace && neume.notes.slice(-1)[0] == note;
    if(result.isTorculus) {
      result.torculusNotes = neume.notes;
    } else if(result.isPesSubpunctis) {
      result.torculusNotes = neume.notes.slice(0,3);
    }
    result.acceptsBarBefore = !hasPreviousNote;
    result.acceptsBarAfter = !hasNextNote;
    result.acceptsMora = !result.hasMorae && !result.hasEpisemata && !result.isQuilisma && !result.isRepeatedNote && neume.notes.slice(-1)[0] == note;
    result.acceptsEpisema = !result.hasMorae && !result.hasEpisemata && !result.isQuilisma && !result.isRepeatedNote;
    if(result.acceptsBarBefore || result.acceptsBarAfter) {
      var score = neume.score;
      notations = score.notations;
      noteIndex = notations.indexOf(neume);
      result.prevNotation = notations[noteIndex-1];
      if(result.prevNotation && result.prevNotation.accidentalType) result.prevNotation = notations[noteIndex-2];
      result.nextNotation = notations[noteIndex+1];
      if(!result.prevNotation) result.acceptsBarBefore = false;
      if(result.prevNotation && result.prevNotation.isDivider) {
        if(result.prevNotation.constructor == exsurge.QuarterBar || result.prevNotation.constructor == exsurge.Virgula || result.prevNotation.constructor == exsurge.HalfBar) result.hasBarBefore = true;
        else result.acceptsBarBefore = false;
      }
      if(result.nextNotation && result.nextNotation.isDivider) {
        if(result.nextNotation.constructor == exsurge.QuarterBar || result.nextNotation.constructor == exsurge.Virgula || result.nextNotation.constructor == exsurge.HalfBar) result.hasBarAfter = true;
        else result.acceptsBarAfter = result.acceptsBarAfter = false;
      }
    }
    // TODO: allow adding bar after any dotted note:
    // if(!result.acceptsBarAfter && result.hasMorae) result.acceptsBarAfter;
    return result;
  }
  // go through <use>s in $notation, and move on to siblings of $notation if they do not have lyrics.
  // start at the selected <use> if any
  var findNextInterestingNote = function($notation, $selected) {
    var $originalNotation = $notation,
        $current;
    // check to make sure $selected is from the same syllable:
    if($selected && $selected.length) {
      var selectedNotation = $selected[0].source && $selected[0].source.neume || $selected[0].source,
          notations = selectedNotation.score.notations,
          index = notations.indexOf(selectedNotation);
      while(index > 0 && !selectedNotation.hasLyrics()) {
        selectedNotation = notations[--index];
      }
      if(!selectedNotation || selectedNotation.lyrics[0] != $notation[0].source.lyrics[0]) $selected = null;
    }
    if($selected && $selected.length) {
      $current = $selected.nextAll('use').first();
      $notation = $selected.parent().parent();
    }
    var startingNotation = $notation[0];
    while($notation[0]===startingNotation || !$notation[0].source.hasLyrics()) {
      var $current = $current? $current : $notation.find('use').first();
      while($current.length) {
        var note = $current[0].source;
        if(note && note.neume) {
          var properties = _getNoteProperties(note);
          if(properties.isRepeatedNote || properties.hasEpisemata || properties.hasMorae || properties.acceptsBarBefore || properties.acceptsBarAfter) {
            $current[0].classList.add('active');
            properties.$note = $current;
            properties.$neume = $notation;
            return properties;
          }
        }
        $current = $current.nextAll('use').first();
      }
      $current = null;
      var temp = $notation.next();
      if(temp.length === 0) {
        temp = $notation.parent().next().find('g').first();
      }
      $notation = temp;
      if($notation.length == 0) break;
    }
    if($selected && $selected.length) return findNextInterestingNote($originalNotation);
    return null;
  }
  window.showToolbarForNote = function(element, editorialChange, base) {
    var $elem = $(element),
        $neume = $elem.parent(),
        $svg = $elem.parents('svg'),
        $selected = $svg.find('use[source-index].active'),
        source = element.source,
        isText = false,
        note,
        noteIndex,
        neume,
        notations,
        noteProperties,
        acceptsBarBefore;
        
    switch(element.nodeName) {
      case 'use':
        note = source.neume && source;
        neume = note? note.neume : source;
        notations = neume.mapping.notations;
        if(note) {
          noteProperties = _getNoteProperties(note);
        } else {
          noteIndex = notations.indexOf(neume);
          noteProperties = { acceptsBarAfter: noteIndex === notations.length - 1 };
        }
        acceptsBarBefore = noteIndex === 0;
        break;
      case 'text':
        isText = true;
        $neume = $elem;
        noteProperties = findNextInterestingNote($neume.parent(), $selected) || {};
        if(noteProperties.acceptsBarAfter) {
          neume = noteProperties.note.neume;
        } else {
          neume = $neume.parent().find('use').prop('source');
          if(!noteProperties.note) noteProperties.note = neume;
          neume = neume && neume.neume;
        }
        break;
    }
    var $toolbar = noteProperties.toolbar = $('<div>').addClass('chant-context btn-group-vertical');
    addPitchButtonsToToolbar($toolbar, noteProperties, $svg.prop('source'), [editorialChange, base]);
    
    if(editorialChange && base) {
      base.noteProperties = noteProperties;
      if(noteProperties.hasMorae)
        $toolbar.prepend($('<button>').addClass('btn btn-danger').text('Remove •').click($.extend({action:'removeMora'}, base), editorialChange));
      else if(noteProperties.acceptsMora) {
        $toolbar.prepend($('<button>').addClass('btn btn-success').text('Add •').click($.extend({action:'addMora'}, base), editorialChange));
      }
      if(noteProperties.acceptsEpisema) {
        $toolbar.prepend($('<button>').addClass('btn btn-success').text('Add Episema').click($.extend({action:'addEpisema'}, base), editorialChange));
      }
      if(noteProperties.acceptsBarBefore) {
        if(noteProperties.hasBarBefore) $toolbar.prepend($('<button>').addClass('btn btn-success').html('<span class="glyphicon glyphicon-arrow-left"></span> Add carryover').click($.extend({action:'addCarryOverBefore', barBefore: noteProperties.hasBarBefore && noteProperties.prevNotation}, base), editorialChange));
        $toolbar.prepend($('<button>').addClass('btn btn-'+(noteProperties.hasBarBefore?'danger':'success')).html('<span class="glyphicon glyphicon-arrow-left"></span> ' + (noteProperties.hasBarBefore? 'Remove' : ' Add') + ' Bar').click($.extend({action:'toggleBarBefore', barBefore: noteProperties.hasBarBefore && noteProperties.prevNotation}, base), editorialChange));
      }
      if(noteProperties.acceptsBarAfter || (noteProperties.hasMorae && noteProperties.isLastOfNeume)) {
        if(noteProperties.hasBarAfter) $toolbar.prepend($('<button>').addClass('btn btn-success').html('Add carryover <span class="glyphicon glyphicon-arrow-right"></span>').click($.extend({action:'addCarryOverAfter', barAfter: noteProperties.hasBarAfter && noteProperties.nextNotation}, base), editorialChange));
        $toolbar.prepend($('<button>').addClass('btn btn-'+(noteProperties.hasBarAfter?'danger':'success')).html((noteProperties.hasBarAfter? 'Remove' : ' Add') + ' Bar <span class="glyphicon glyphicon-arrow-right"></span>').click($.extend({action:'toggleBarAfter', after: noteProperties.acceptsBarAfter? 'neume' : 'note', barAfter: noteProperties.hasBarAfter && noteProperties.nextNotation}, base), editorialChange));
      }
      if(noteProperties.isQuilisma) {
        $toolbar.prepend($('<button>').addClass('btn btn-danger').text('Remove Quilisma').click($.extend({action:'removeQuilisma'}, base), editorialChange));
      }
      if(noteProperties.isRepeatedNote)
        $toolbar.prepend($('<button>').addClass('btn btn-danger').text('Remove Punctum').click($.extend({action:'removePunctum'}, base), editorialChange));
      if(noteProperties.hasEpisemata) {
        if(noteProperties.isTorculus || noteProperties.isPesSubpunctis) {
          $toolbar.prepend($('<button>').addClass('btn btn-primary').html('12<span class="ol">3</span>').click($.extend({action:'torculus3'}, base), editorialChange));
          $toolbar.prepend($('<button>').addClass('btn btn-primary').html('1<span class="ol">2</span>3').click($.extend({action:'torculus2'}, base), editorialChange));
          $toolbar.prepend($('<button>').addClass('btn btn-primary').html('<span class="ol">1</span>23').click($.extend({action:'torculus1'}, base), editorialChange));
          if(noteProperties.isTorculus) {
            $toolbar.prepend($('<button>').addClass('btn btn-primary').html('<span class="ol">12</span>3').click($.extend({action:'torculus12'}, base), editorialChange));
          }
        }
        $toolbar.prepend($('<button>').addClass('btn btn-danger').text('Remove Episema').click($.extend({action:'removeEpisema'}, base), editorialChange));
      }
    }
      
    element.classList.add('active');
    $toolbar.appendTo(document.body);
    var $neume = (noteProperties.$neume || $neume.parent()),
        staffTop = $neume.parent().offset().top,
        neumeTop = $neume.offset().top - 4,
        toolbarWidth = $toolbar.outerWidth(),
        left = $neume.offset().left + ( $neume.width() - toolbarWidth) / 2,
        bodyWidth = $(document.body).outerWidth(),
        top = Math.min(staffTop, neumeTop) - $toolbar.outerHeight(),
        scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    if(left < 8) left = 8;
    if(left + toolbarWidth > bodyWidth - 8) left = bodyWidth - 8 - toolbarWidth;
    if(scrollTop > top) {
      var staffBottom = staffTop + $neume.parent()[0].getBoundingClientRect().height,
          neumeBottom = neumeTop + 8 + $neume[0].getBoundingClientRect().height;
      top = Math.max(staffBottom, neumeBottom);
    }
    $toolbar.offset({
      top: top,
      left: left
    });
  }
  var mapStrings = window.mapStrings = function(before, after, beforeStart, afterStart) {
    beforeStart = beforeStart || 0;
    afterStart = afterStart || 0;
    var oldIndexMap = {}, i;
    for (i = 0; i < before.length; i++) {
        oldIndexMap[before[i]] = oldIndexMap[before[i]] || [];
        oldIndexMap[before[i]].push(i);
    }
    var overlap = [], startOld, startNew, subLength, inew;
    startOld = startNew = subLength = 0;

    for (inew = 0; inew < after.length; inew++) {
        var _overlap                = [];
        oldIndexMap[after[inew]]    = oldIndexMap[after[inew]] || [];
        for (i = 0; i < oldIndexMap[after[inew]].length; i++) {
            var iold        = oldIndexMap[after[inew]][i];
            // now we are considering all values of val such that
            // `before[iold] == after[inew]`
            _overlap[iold]  = ((iold && overlap[iold-1]) || 0) + 1;
            if (_overlap[iold] > subLength) {
                // this is the largest substring seen so far, so store its
                // indices
                subLength   = _overlap[iold];
                startOld    = iold - subLength + 1;
                startNew    = inew - subLength + 1;
            }
        }
        overlap = _overlap;
    }

    if (subLength === 0) {
        // If no common substring is found, we return an insert and delete...
        var result = [];
        before.length && result.push(['-', before]);
        after.length  && result.push(['+', after]);
        return [];
    }

    // ...otherwise, the common substring is unchanged and we recursively
    // diff the text before and after that substring
    return [].concat(
        mapStrings(before.slice(0, startOld), after.slice(0, startNew), beforeStart, afterStart),
        [[beforeStart + startOld, afterStart + startNew, subLength]],
        mapStrings(before.slice(startOld + subLength), after.slice(startNew + subLength), beforeStart+startOld+subLength, afterStart+startNew+subLength)
    );
  }

  window.mapString = function(map, index) {
    // maps a[index] to index of b
    for(var i=0; i<map.length; ++i) {
      if(index >= map[i][0] && (i === map.length - 1 || index < map[i+1][0])) {
        return map[i][1] + index - map[i][0];
      }
    }
  }

  // returns a function that will map indices in string a to indices in string b
  window.makeExsurgeToGabcMapper = function(a,b) {
    var map;
    return function(index) {
      if(!map) map = mapStrings(a, b);
      return mapString(map, index);
    }
  }
})(window);
if(typeof exports=='object') {
  exports.Header = GabcHeader;
  exports.getHeader = getHeader;
}
if(typeof $=='function') $(function($) {
  /**
   * @param {String} s the string to search
   * @param {Number} startIndex The index at which to start searching for a vowel in the string
   * @retuns a custom class with three properties: {found: (true/false) startIndex: (start index in s of vowel segment) length ()}
   */
  function findEnglishVowelSegment(s, startIndex) {

    var i, end, index;
    var regexLetter = /[a-zäëïöüÿáéíóúýàèìòùỳāēīōūȳăĕĭŏŭæœ]+/i;
    var match = regexLetter.exec(s.slice(startIndex));
    if(match)
      return { found: true, startIndex: startIndex + match.index, length: match[0].length };

    // no vowels sets found after startIndex!
    return { found: false, startIndex: -1, length: -1 };
  }
  window.exsurgeEnglish = {findVowelSegment: findEnglishVowelSegment};
  window.registerChantClicks = function($svgContainer, selectSourceIndex) {
    $svgContainer.on('click', 'use[source-index],text[source-index]:not(.dropCap)', function(e) {
      selectSourceIndex(this.source.sourceIndex, $svgContainer, e);
    });
  }

  window.setActiveChantElement = function(elem) {
    var href = elem.href && elem.href.baseVal;
    if(href === '#None') {
      var previous = elem.previousSibling;
      if(/^#Porrectus/.test(previous.href.baseVal)) {
        previous.classList.add('active','porrectus-right');
      }
    } else if(/^#Porrectus/.test(href)) {
      elem.classList.add('active','porrectus-left');
    } else {
      elem.classList.add('active');
    }
  }
  window.unsetActiveChantElement = function(elem) {
    var href = elem.href && elem.href.baseVal;
    if(href === '#None') {
      var previous = elem.previousSibling;
      if(/^#Porrectus/.test(previous.href.baseVal)) {
        elem = previous;
      }
    }
    elem.classList.remove('active','porrectus-left','porrectus-right');
  }
  window.findChantElementNear = function(svg,pageX,pageY) {
    var $svg = $(svg),
        x = pageX - $svg.offset().left,
        $lines = $svg.find('g.chantLine'),
        score = svg.source,
        lines = score.lines;
    for(var i=$lines.length - 1; i >= 0; --i) {
      var top = $($lines[i]).offset().top;
      if(top < pageY) {
        var line = lines[i];
        var y = pageY - top + line.notationBounds.y;
        break;
      }
    }
    if(!line) return null;
    if(i == 0 && score.dropCap && x < line.notationBounds.x) {
      return $svg.find('.dropCap')[0];
    }
    for(i = line.notationsStartIndex + line.numNotationsOnLine - 1; i >= line.notationsStartIndex; --i) {
      var notation = score.notations[i];
      var prevNotation = score.notations[i-1];
      var notationX = notation.bounds.x;
      if(notation.hasLyrics()) notationX += notation.lyrics[0].bounds.x;
      if(prevNotation) notationX = Math.max(prevNotation.bounds.right(), notationX);
      if(notationX < x) {
        x -= notation.bounds.x;
        break;
      }
    }
    if(notation.notes) {
      for(i = notation.notes.length - 1; i >= 0; --i) {
        var note = notation.notes[i];
        if(i == 0 || note.bounds.x < x) {
          var href = note.svgNode.href.baseVal;
          var match;
          if((match = href.match(/^#(?:Podatus(Upper|Lower)|Terminating(Asc|Des)Liquescent|)$/))) {
            // if the note is podatus upper or lower, we need to consider the vertical coordinate
            var notes = [note];
            if(match[1]=='Lower') {
              // PodatusLower
              notes.push(notation.notes[i + 1]);
            } else if(match[2]=='Des') {
              // DesLiquescent
              notes.push(notation.notes[i - 1]);
            } else {
              // PodatusUpper or AscLiquescent
              notes.unshift(notation.notes[i - 1]);
            }
            // find y midpoint between bottom of top and top of bottom, and pick bottom if y is below that and top otherwise.
            var midY = (notes[1].bounds.bottom() + notes[0].bounds.y) / 2;
            note = (y > midY)? notes[0] : notes[1];
          } else if(/^#Porrectus/.test(href)) {
            // find x midpoint, and pick note based on that
            var notes = [note, notation.notes[i + 1]];
            var midX = note.bounds.x + (note.bounds.width / 2);
            note = (x <= midX)? notes[0] : notes[1];
          }
          return note.svgNode;
        }
      }
    } else if(notation.hasLyrics()) {
      return $svg.find('[source-index=' + notation.lyrics[0].sourceIndex + ']')[0];
    }
    return null;
  }
  var gregobaseUrlPrefix = 'http://gregobase.selapa.net/chant.php?id=';
  var gregorianBooksUrlPrefix = 'http://www.gregorianbooks.com/';
  var stopTone;
  var mouseUpTone = function() {
    stopTone && stopTone();
    stopTone = null;
  };
  var pitchInterval = [
    'P1',
    'm2',
    'M2',
    'm3',
    'M3',
    'P4',
    'A4',
    'P5',
    'm6',
    'M6',
    'm7',
    'M7'
  ];
  var solFegeNames = [
    'Do',
    'Di',
    'Re',
    'Me',
    'Mi',
    'Fa',
    'Fi',
    'Sol',
    'Si',
    'La',
    'Te',
    'Ti'
  ]
  window.addPitchButtonsToToolbar = function($toolbar, noteProperties, score, showToolbarForNoteArgs) {
    var isFirstPitch = !noteProperties;
    var lowPitch = 100000, highPitch = 0;
    var startPitch = null;
    var thisPitch = null;
    score.notations.forEach(function(notation) {
      if(notation.notes) notation.notes.forEach(function(note) {
        var pitch = note.pitch.toInt()
        if(startPitch == null) {
          startPitch = pitch;
          if(!isFirstPitch && noteProperties.note === note) isFirstPitch = true;
          if(isFirstPitch) thisPitch = startPitch;
        } else if(noteProperties && noteProperties.note === note) {
          thisPitch = note.pitch.toInt();
        }
        lowPitch = Math.min(lowPitch, pitch);
        highPitch = Math.max(highPitch, pitch);
      });
    });
    // default to putting the middle pitch at G above middle C
    score.defaultStartPitch = score.defaultStartPitch || calculateDefaultStartPitch(startPitch, lowPitch, highPitch);

    function changePitch(offset) {
      if(offset) score.defaultStartPitch = new exsurge.Pitch(score.defaultStartPitch.toInt() + offset);
      var lowestPitch = new exsurge.Pitch(score.defaultStartPitch.toInt() - startPitch + lowPitch);
      var highestPitch = new exsurge.Pitch(score.defaultStartPitch.toInt() - startPitch + highPitch);
      var pitch = new exsurge.Pitch(score.defaultStartPitch.toInt() - startPitch + thisPitch);
      var thisPitchName = tones.noteName[pitch.step];
      if(offset == 1) thisPitchName = thisPitchName.slice(0,2);
      else if(offset == -1) thisPitchName = thisPitchName.slice(-2);
      $toolbar.find('.this-pitch').html(thisPitchName + '<sub>' + pitch.octave + '</sub>');
      $toolbar.find('.lowest-pitch').html(tones.noteName[lowestPitch.step].slice(0,2) + '<sub>' + lowestPitch.octave + '</sub>');
      $toolbar.find('.highest-pitch').html(tones.noteName[highestPitch.step].slice(0,2) + '<sub>' + highestPitch.octave + '</sub>');
      $toolbar.find('.do-pitch').text(tones.noteName[(score.defaultStartPitch.step - startPitch + 120) % 12]);
    }
    function moveToNote(offset) {
      var notes = [].concat.apply([],score.notations.map(function(notation) { return notation.notes || null; })).filter(function(notation) { return notation && !notation.isAccidental; });
      var note = notes[notes.indexOf(noteProperties.note) + offset];
      removeChantContextMenus();
      showToolbarForNote.apply(undefined, [note.svgNode].concat(showToolbarForNoteArgs));
    }
    var playButtonGroup = $('<div>').addClass('btn-group');
    playButtonGroup.append($('<button class="btn btn-default active flex-0"><span class="glyphicon glyphicon-step-backward"></span></button>').click(function(e) {
      e.stopPropagation();
      moveToNote(-1);
    }));
    var playButton = $('<button>').addClass('btn btn-primary').html('<span class="glyphicon glyphicon-play"></span> Play' + (isFirstPitch? '' : ' Chant from here')).click(function(e) {
      e.stopPropagation();
      mouseUpTone();
      playScore(score, score.defaultStartPitch, noteProperties && noteProperties.note);
      removeChantContextMenus();
    });
    playButtonGroup.append(playButton);
    playButtonGroup.append($('<button class="btn btn-default active flex-0"><span class="glyphicon glyphicon-step-forward"></span></button>').click(function(e) {
      e.stopPropagation();
      moveToNote(1);
    }));
    $toolbar.append(showToolbarForNoteArgs? playButtonGroup : playButton);
    if(isFirstPitch) {
      $toolbar.append($('<button>').addClass('btn btn-default active disabled').html('<div>Range: <span class="lowest-solfege"></span> to <span class="highest-solfege"></span> (' + getPitchRange(highPitch - lowPitch) + ')</div>'));
      $toolbar.find('.lowest-solfege').html(solFegeNames[lowPitch % 12].slice(0,2) + '<sub>' + Math.floor(lowPitch / 12) + '</sub>');
      $toolbar.find('.highest-solfege').html(solFegeNames[highPitch % 12].slice(0,2) + '<sub>' + Math.floor(highPitch / 12) + '</sub>');
    }
    var pitchButtonGroup = $('<div>').addClass('btn-group');
    pitchButtonGroup.append($('<button class="btn btn-success flex-0"><span class="glyphicon glyphicon-arrow-up"></span></button>').click(function(e) {
      e.stopPropagation();
      mouseUpTone();
      changePitch(1);
    }));
    var mouseDownTone = function() {
      if(!stopTone) stopTone = tones.play(new exsurge.Pitch(score.defaultStartPitch.toInt() - startPitch + thisPitch), {start: true, release: 300});
    };
    pitchButtonGroup.append($('<button>').addClass('btn btn-info').html('<div>' + (isFirstPitch? 'Starting ' : '') + 'Pitch: <span class="this-pitch"></span></div>' +
        (isFirstPitch? '<div>Range: <span class="lowest-pitch"></span> to <span class="highest-pitch"></span></div>' : '')).click(function(e) {
      e.stopPropagation();
      mouseUpTone();
    }).on('mousedown touchstart',mouseDownTone).on('mouseup touchcancel touchend',mouseUpTone));
    pitchButtonGroup.append($('<button class="btn btn-success flex-0"><span class="glyphicon glyphicon-arrow-down"></span></button>').click(function(e) {
      e.stopPropagation();
      mouseUpTone();
      changePitch(-1);
    }));
    $toolbar.append(pitchButtonGroup);
    if(isFirstPitch) {
      $toolbar.append($('<button>').addClass('btn btn-default active disabled').html('<div>Do = <span class="do-pitch"></span></div>'));
    }

    // update the spans with pitch info:
    changePitch(0);
  }
  function getPitchRange(semitones) {
    semitones = Math.abs(semitones);
    var octaves = Math.floor(semitones / 12);
    semitones %= 12;
    var result = pitchInterval[semitones];
    if(!octaves) return result;
    var number = parseInt(result[1]) + 8*octaves - 1;
    return result[0] + number;
  }
  $(document).on('click', function() {
    removeChantContextMenus();
    mouseUpTone();
  }).on('click', '#mediaControls .btn-use-solesmes-lengths', function(e) {
    e.stopPropagation();
    var useSolesmesLengths = toggleIsUsingSolesmesLengths();
    $(this).find('.glyphicon').
      removeClass('glyphicon-check glyphicon-unchecked').
      addClass('glyphicon-' + (useSolesmesLengths? 'check' : 'unchecked'));
  }).on('click', '#mediaControls .btn.play-pause', function(e) {
    e.stopPropagation();
    var playing = playPauseScore();
    $(this).find('.glyphicon').removeClass('glyphicon-play glyphicon-pause').addClass('glyphicon-' + (playing? 'pause' : 'play'));
  }).on('click', '#mediaControls .btn.step-forward', function(e) {
    e.stopPropagation();
    Tone.Transport.pause();
    playNextNote();
    $('#mediaControls .btn.play-pause .glyphicon').removeClass('glyphicon-play glyphicon-pause').addClass('glyphicon-play');
  }).on('click', '#mediaControls .btn.tempo-minus, #mediaControls .btn.tempo-plus', function(e) {
    e.stopPropagation();
    var tempo = setRelativeTempo(5 * ($(this).hasClass('tempo-plus')? 1 : -1));
    $('#tempo-number').text(tempo);
  }).on('click', '#mediaControls .btn.stop', function(e) {
    stopScore();
  }).on('click', 'svg text.dropCap', function(e) {
    e.stopPropagation();
    removeChantContextMenus();
    var $this = $(this);
    var $div = $this.parents('div').first();
    var gregoBaseId = $div.attr('gregobase-id');
    var gregorianBooksId = $div.attr('gregorianBooksId');
    
    var $toolbar = $('<div>').addClass('chant-context btn-group-vertical');
    if(gregoBaseId) {
      $toolbar.append($('<a>').attr('target','_blak').attr('href',gregobaseUrlPrefix + gregoBaseId).addClass('btn btn-success').html('<span class="glyphicon glyphicon-share-alt"></span> GregoBase'));
    }
    if(gregorianBooksId) {
      $toolbar.append($('<a>').attr('target','_blak').attr('href',gregorianBooksUrlPrefix + gregorianBooksId).addClass('btn btn-success').html('<span class="glyphicon glyphicon-share-alt"></span> Gregorian Books'));
    }
    addPitchButtonsToToolbar($toolbar, null, $this.parents('svg').prop('source'));
    $toolbar.appendTo(document.body);
    var staffTop = $this.parent().offset().top,
        toolbarWidth = $toolbar.outerWidth(),
        left = $this.offset().left + ( $this.width() - toolbarWidth) / 2,
        top = staffTop - $toolbar.outerHeight(),
        bodyWidth = $(document.body).outerWidth(),
        scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    if(left < 8) left = 8;
    if(left + toolbarWidth > bodyWidth - 8) left = bodyWidth - 8 - toolbarWidth;
    if(scrollTop > top) top = staffTop + $this.parent()[0].getBoundingClientRect().height;
    $toolbar.offset({
      top: top,
      left: left
    });
  });
});


function getReading(source, returnText) {
  var edition = 'vulgate';
  var language = 'la';
  if(typeof(source) == 'object') {
    edition = source.edition || edition;
    language = source.language || language;
    source = source.ref;
  }
  var match = /\s*(?:(\d)\s+)?((?:[A-ZÆŒ][a-zæœ]+(?:\s(?=[A-ZÆŒ])|))+)(.*)/.exec(source),
      bookNumber = match[1],
      book = match[2],
      numbers = match[3];
  if(book in mapBooks) {
    book = mapBooks[book];
  }
  var bookName = book;
  if(bookNumber) {
    book += ' ' + bookNumber;
    bookName += ' ' + bookNumber;
  }
  var result = $.Deferred();
  $.get(edition+'/'+book).then(function(book) {
    var match = /(\d+)\s*(?:[,:]\s*(\d+)\s*(?:-(\d+))?\s*)?/.exec(numbers);
    var chapter = match[1],
        verse = match[2],
        endVerse = match[3];
    numbers = numbers.slice(match.index+match[0].length);
    var match = null;
    var regex = /,\s*(\d+)\s*(?:-(\d+))?\s*|;\s*(\d+)\s*[,:]\s*(\d+)\s*(?:-(\d+))?\s*/g;
    var text = '';
    var h = Hypher.languages[language];
    if(!h) h = {hyphenateText: function(t) { return t; } };

    do {
      if(match) {
        if(match[1]) {
          verse = match[1];
          endVerse = match[2];
        } else {
          chapter = match[3];
          verse = match[4];
          endVerse = match[5];
        }
      }
      var wholeChapter = !verse;
      if(wholeChapter) verse = 1;
      var beginning = (chapter == 1 && verse == 1)? '' : '\n';
      beginIndex = book.indexOf(beginning + chapter + '\t' + verse + '\t');
      if(beginIndex < 0) {
        text += 'Verse ' + chapter + ': ' + verse + ' was not found.\n';
        continue;
      }
      if(beginning) beginIndex++;
      var temp = book.slice(beginIndex);
      var endIndex = 0;
      if(wholeChapter) {
        endIndex = temp.indexOf('\n' + (chapter- -1) + '\t1\t');
        if(endIndex < 0) endIndex = temp.length-1;
      } else if(endVerse) {
        endIndex = temp.indexOf('\n' + chapter + '\t' + endVerse + '\t') + 1;
      }
      endIndex = temp.indexOf('\n',endIndex);
      if(endIndex < 0) endIndex = temp.length;
      text += temp.slice(0,endIndex) + '\n';
    } while(match = regex.exec(numbers));
    text = text.trim();
    if(returnText) {
      result.resolve(text.replace(/(^|\n)\d+\t\d+\t([^\n]+)/g,'$1$2'));
      return;
    }
    text = text.split('\n').reduce(function(result, line) {
      if(line) {
        var match = line.match(/(\d+)\t(\d+)\t(.*)/);
        return result.add($('<span>').attr('chapter',match[1]).attr('verse',match[2]).text(h.hyphenateText(match[3], 3)+'\n'));
      }
      return result;
    }, $());
    result.resolve(text);
  });
  return result;
}