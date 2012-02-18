mensis = ['Januarii', 'Februarii', 'Martii', 'Aprilis', 'Maii', 'Iunii', 'Iulii', 'Augusti', 'Septembris', 'Octobris', 'Novembris', 'Decembris']

function DivinumOfficiumKalendar(version, options)
{
    var url = 'http://divinumofficium.com/cgi-bin/horas/officium.pl?command=kalendar'

    options = options || {}
    options.id = options.id || 'kalendar'
    options.link = options.link || 'http://divinumofficium.com'

    var now = new Date()
    var now_date = "" + now.getDate() + "-" + (now.getMonth()+1) + "-" + now.getFullYear()
    var display_date = "" + now.getDate() + "." + mensis[now.getMonth()] + ". a.D. " + now.getFullYear()
    var now_hour = now.getHours()
    var hour
    var suffix = 'Laudes'
    if ( 5 <= now_hour && now_hour < 18 )
    {
        hour = 'in die'
    }
    else if ( 18 <= now_hour && now_hour < 24 )
    {
        hour = 'ad vesperas'
        suffix = 'Vesperas'
    }
    else
    {
        hour = 'in nocte'
    }
    
    document.write('<a href="'+options.link+'" style="text-decoration:none;font-style:italic;text-align:center">')
    document.write(hour + " " + display_date + '<br>')
    document.write('<span id="' + options.id + '"></a>')

    var kal = new XMLHttpRequest()

    var span = document.getElementById(options.id)
    kal.onload = function(e) { span.innerHTML = e.target.responseText }

    url = url+suffix
    url = version ? (url+'&version='+version) : url
    kal.open('GET', url, true)
    kal.send()
}
