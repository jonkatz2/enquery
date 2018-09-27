
library(shiny)
library(enquery)

options(shiny.sanitize.errors = FALSE)

valuelistA <- list(
    `Gate Setting 1`=list(
        `Lower basin`=c(high=185, low=85, ml=125)
    ),
    `Gate Setting 2`=list( 
        `Lower basin`=c(high=450, low=250, ml=350)
    ),
    `Gate Setting 3`=list(
        `Lower basin`=c(high=350, low=250, ml=300)
    ),
    `Gate Setting 4`=list( 
        `Lower basin`=c(high=450, low=250, ml=350)
    ),
    `Gate Setting 5`=list( 
        `Lower basin`=c(high=125, low=100, ml=110)
    )
)


valuelistB <- list(
    `Gate Setting 1`=list(
        `Lower basin`=c(high=185, low=85, ml=125, disabled=TRUE),
        `Middle basin`=c(high=200, low=100, ml=150)
    ),
    `Gate Setting 2`=list(
        `Lower basin`=c(high=450, low=250, ml=350, disabled=TRUE),
        `Middle basin`=c(high=350, low=50, ml=375)
    ),
    `Gate Setting 3`=list(
        `Lower basin`=c(high=350, low=250, ml=300, disabled=TRUE),
        `Middle basin`=c(high=450, low=250, ml=350) 
    ),
    `Gate Setting 4`=list( 
        `Lower basin`=c(high=450, low=250, ml=350, disabled=TRUE),
        `Middle basin`=c(high=350, low=50, ml=250)
    ),
    `Gate Setting 5`=list(
        `Lower basin`=c(high=125, low=100, ml=110, disabled=TRUE),
        `Middle basin`=c(high=150, low=50, ml=125)
    )
)

valuelistC <- list(
    `Gate Setting 1`=list(
        `Lower basin`=c(high=185, low=85, ml=125, disabled=TRUE),
        `Middle basin`=c(high=200, low=100, ml=150, disabled=TRUE), 
        `Upper basin`=c(high=300, low=200, ml=250)
    ),
    `Gate Setting 2`=list(
        `Lower basin`=c(high=450, low=250, ml=350, disabled=TRUE),
        `Middle basin`=c(high=350, low=50, ml=375, disabled=TRUE), 
        `Upper basin`=c(high=200, low=125, ml=150)
    ),
    `Gate Setting 3`=list(
        `Lower basin`=c(high=350, low=250, ml=300, disabled=TRUE),
        `Middle basin`=c(high=450, low=250, ml=350, disabled=TRUE), 
        `Upper basin`=c(high=500, low=225, ml=450)
    ),
    `Gate Setting 4`=list(
        `Upper basin`=c(high=200, low=125, ml=150), 
        `Middle basin`=c(high=350, low=50, ml=250, disabled=TRUE), 
        `Lower basin`=c(high=450, low=250, ml=350, disabled=TRUE)
    ),
    `Gate Setting 5`=list(
        `Lower basin`=c(high=125, low=100, ml=110, disabled=TRUE),
        `Middle basin`=c(high=150, low=50, ml=125, disabled=TRUE), 
        `Upper basin`=c(high=100, low=25, ml=85) 
    )
)


ui <- fluidPage(
    singleton(tags$head(
        tags$style('.text-bold {font-weight:bold;}')
    )),
    h2(style='text-align:center;', "Free-draw a Trend For Expert Elicitation"),
    div(style="clear:both;float:left;width:50%;",
        p(class='text-bold', style="width:500px;text-align:center;margin:auto;", 'Click and drag to draw the trend you expect to see. Use the "clear" button to re-draw as many times as you need.'),
        actionButton('setval', 'restore value'),
        div(style="clear:both;", drawLineInput("myInput", xlim=c(0,25.1), ylim=c(0, 50), xlab="Year", ylab="Accretion rate (mm/year)", px.wide=600, px.high=400))
    ),
    div(style="float:right;width:50%;padding:1em;",
        p(class='text-bold', style="width:500px;text-align:center;margin:auto;", 'The server sees the x and y data from which point data can be extracted by interpolation, or trends can be modeled'),
        div(style="padding-top:45px;", tags$style("#drawoutput{margin:auto;}"), plotOutput('drawoutput', width='700px', height='550px'))
    ),
    # Application title
    h2(style='clear:both;text-align:center;', "Input Sliders For Expert Elicitation"),
    div(style='clear:both;',
        p(class='text-bold', '4-point elicitation with distinct steps to focus first on range, then on most-likely, and finally on confidence.'),
        multiPointSliderInput('lower', '', min=0, max=500, step=1, height=400, valuelist=valuelistA, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(rev(c('#0044b2','#c6d7f2'))))
    ),
    div(style='clear:both;',
        p(class='text-bold', 'These sliders are linked in the server. The above sliders appear in the input below as disabled reference values.'),
        multiPointSliderInput('middle', '', min=0, max=500, step=1, height=400, valuelist=valuelistB, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(rev(c('#0044b2','#c6d7f2'))))
    ),
    div(style='clear:both;',
        p(class='text-bold', 'Single sliders per group. Turn background lines off for a cleaner look.'),
        multiPointSliderInput('upper', '', min=0, max=500, step=1, height=400, valuelist=valuelistC, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(rev(c('#0044b2','#c6d7f2'))))
    ),
    ####
    div(style='clear:both;',
        p(class='text-bold', '3-point elicitation with repeating grouped categories: Each element on the x-axis contains any number of sub-elements (provided all elements have the same number of sub-elements).'),
        p(class='text-bold', 'Default colors are a blue gradient. The ML cannot move beyond the H or L and vice-versa.'),
        multiPointSliderInput('lower3', '', min=0, max=500, step=1, height=400, valuelist=valuelistA, confidence=FALSE, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(rev(c('#0044b2','#c6d7f2'))))
    ),
    div(style='clear:both;',
        p(class='text-bold', 'Sliders can be disabled programmatically. Customize colors by setting either a custom gradient or discrete values.'),
        multiPointSliderInput('middle3', '', min=0, max=500, step=1, height=400, valuelist=valuelistB, confidence=FALSE, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(rev(c('#0044b2','#c6d7f2'))))
    ),
    div(style='clear:both;',
        p(class='text-bold', 'Single sliders per group. Turn background lines off for a cleaner look.'),
        multiPointSliderInput('upper3', '', min=0, max=500, step=1, height=400, valuelist=valuelistC, confidence=FALSE, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(rev(c('#0044b2','#c6d7f2'))))
    ),
    div(style='text-align:center;min-height:200px;', actionLink('stop', 'server'))
)

