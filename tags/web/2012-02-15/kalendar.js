function DivinumOfficiumKalendar(version)
{
    var kal = new XMLHttpRequest()
    var url = 'http://divinumofficium.com/cgi-bin/horas/officium.pl?command=kalendar'
    if ( version )
    {
        url += '&version=' + version
    }
    kal.open('GET', url, false)
    kal.send()
    if ( kal.status == 200 )
    {
        document.write(kal.responseText)
    }
}
