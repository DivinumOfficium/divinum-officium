#*** Javascript functions
# the sub is called from htmlhead
sub horasjs {

  my ($output);

  # $caller in principle might not be defined.
  my $caller_flag = $caller || 0;

  if ($officium ne 'Pofficium.pl') {
    $output .= << "PrintTag";

//position
function startup() {
  if (!"$browsertime") {
    var d = new Date();
    var day = d.getDate();
    document.forms[0].browsertime.value = (d.getMonth() + 1) + "-" + day + "-" + d.getFullYear();
    if (!"$date1") {
      var a = (day > $day) ? "-+" : (day < $day) ? "--" : "";
      document.forms[0].date.value = document.forms[0].browsertime.value + a;
      if (a) document.forms[0].submit();
    }
  }
  var i = 1;
  while (i <= $searchvalue) {
    a = document.getElementById('L' + i);
    i++;
    if (a) a.scrollIntoView();
  }
}

//call a setup table
function pset(p) {
  var pc = document.createElement("input");
  pc.setAttribute("type", "hidden");
  pc.setAttribute("name", "pcommand");
  pc.setAttribute("value", "pray" + document.forms[0].command.value);
  document.forms[0].appendChild(pc);
  document.forms[0].command.value = "setup" + p;
  document.forms[0].submit();
}

//call an individual hora
function hset(p, d) {
  clearradio();

  if (p != 'Laudes' && d) {
    document.forms[0].date.value = d;
    document.forms[0].caller.value = 1;
  }
  if ($caller_flag) {document.forms[0].caller.value = 1;}
  document.forms[0].command.value = "pray" + p;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

// call appendix
function appendix(a) {
  document.forms[0].command.value = "Appendix " + a;
  console.log(document.forms[0].command.value);
  document.forms[0].submit();
}

// Jump straight to an hour of the Office for the Dead.
function defunctorum(hour) {
  clearradio();

  document.forms[0].caller.value = 1;
  document.forms[0].votive.value = "C9";
  document.forms[0].command.value = "pray" + hour;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls compare
function callcompare() {
  document.forms[0].action = "Cofficium.pl";
  document.forms[0].target = "_self"
  document.forms[0].submit();
}
PrintTag
  }
  $output .= << "PrintTag";
//to prevent inhearitance of popup
function clearradio() {
  var a= document.forms[0].popup;
  if (a) a.value = 0;
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  return;
}

// set a popup tab
function linkit(name,ind,lang) {
  document.forms[0].popup.value = name;
  document.forms[0].popuplang.value=lang;
  document.forms[0].expandnum.value=ind;
  if (ind == 0) {
     document.forms[0].action = 'popup.pl';
     document.forms[0].target = '_BLANK';
  } else {
     var c = document.forms[0].command.value;
     if (!c.match('pray')) document.forms[0].command.value = "pray" + c;
  }
  document.forms[0].submit();
}

//finishing horas back to main page
function okbutton() {
  document.forms[0].action = "$officium";
  document.forms[0].target = "_self"
  document.forms[0].command.value = '';
  document.forms[0].submit();
}

//restart the programlet if parameter change
function parchange() {
  var c = document.forms[0].command.value;
  if (c && !c.match("change")) {
     clearradio();
  }
  if (c && !c.match("pray")) document.forms[0].command.value = "pray" + c;
  document.forms[0].submit();
}

//calls kalendar
function callkalendar(mode) {
  document.forms[0].action = 'kalendar.pl';
  if (mode == 'kalendar') {
    document.forms[0].kmonth.value = 15;
  }
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

// for Cofficium
function callbrevi(date) {
  document.forms[0].date.value = date;
  document.forms[0].action = 'officium.pl'
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

//calls missa
function callmissa() {
  document.forms[0].action = "../missa/missa.pl";
  if (document.forms[0].command.value != "") {
    document.forms[0].command.value = "praySanctaMissa"
  }
  document.forms[0].target = "_self"
  document.forms[0].submit();
}

function prevnext(ch) {
  var dat = document.forms[0].date.value;
  var adat = dat.split('-');
  var mtab = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
  var m = eval(adat[0]);
  var d = eval(adat[1]);
  var y = eval(adat[2]);
  var c = eval(ch);

  var leapyear = 0;
  if ((y % 4) == 0) leapyear = 1;
  if ((y % 100) == 0) leapyear = 0;
  if ((y % 400) == 0) leapyear = 1;
  if (leapyear) mtab[1] = 29;
  d = d + c;
  if (d < 1) {
    m--;
	if (m < 1) {y--; m = 12;}
	d = mtab[m-1];
  }
  if (d > mtab[m-1]) {
    m++;
	  d = 1;
	  if (m > 12) {y++; m = 1;}
  }
  document.forms[0].date.value = m + "-" + d + "-" + y;
}
PrintTag

  $output;
}

1;
