# Introduction #

There are several desirable large-scale projects that would be nice to pursue, although given our limited resources it might be worth giving some thought as to their relative priorities. This page details such things.

# The projects #

## Calendar calculation ##

This project has [its own page](CalendarCalculation.md). There are (at least) two main benefits: (a) the pre-calculated transferral/Scripture/etc. tables from LK only go up to 2015, and so _something_ will need done before then; and (b) it will allow us to arrange commemorations correctly.

As of April 2014, the acutal calendar resolution logic is essentially done. The remaining parts are commemoration logic and (and this is tricky) fast resolution of the transfer of offices and their parts.

## The standalone version ##

LK maintained this separately from the web version, as far as I can see, and we haven't touched it. I believe Joseph Caudle was looking into this once upon a time. In the long term I think the best solution in the long term is to adapt the web version for standalone operation, but this will require discussion.

## CSS, compliant HTML; visual design ##

The HTML that the program produces is not standards-compliant. This in itself isn't a drastic problem, but compliant HTML with CSS would have some advantages, such as the potential for better support for mobile devices. It would also be a prerequisite for some desirable visual features such as the alignment of psalms per verse.

## Merging of officium, Pofficium, missa etc. ##

There's a lot of scope for refactoring these disparate programs. This would help keep things maintainable. It should probably take place as part of a broader reorganising of the code into modules.