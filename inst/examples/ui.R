
library(shiny)
library(enquery)

options(shiny.sanitize.errors = FALSE)

valuelistA <- list(
    `Gate Setting 1`=list(
        `Upper basin`=c(high=300, low=200, ml=250), 
        `Middle basin`=c(high=200, low=100, ml=150), 
        `Lower basin`=c(high=185, low=85, ml=125)
    ),
    `Gate Setting 2`=list(
        `Upper basin`=c(high=200, low=125, ml=150), 
        `Middle basin`=c(high=350, low=50, ml=250), 
        `Lower basin`=c(high=450, low=250, ml=350)
    ),
    `Gate Setting 3`=list(
        `Upper basin`=c(high=500, low=225, ml=450), 
        `Middle basin`=c(high=450, low=250, ml=350), 
        `Lower basin`=c(high=350, low=250, ml=300)
    ),
    `Gate Setting 4`=list(
        `Upper basin`=c(high=200, low=125, ml=150), 
        `Middle basin`=c(high=350, low=50, ml=250), 
        `Lower basin`=c(high=450, low=250, ml=350)
    ),
    `Gate Setting 5`=list(
        `Upper basin`=c(high=100, low=25, ml=85), 
        `Middle basin`=c(high=150, low=50, ml=125), 
        `Lower basin`=c(high=125, low=100, ml=110)
    )
)

valuelistB <- list(
    `Upper basin`=list(
        `Gate Setting 1`=c(high=300, low=200, ml=250, disabled=TRUE), 
        `Gate Setting 2`=c(high=200, low=125, ml=150), 
        `Gate Setting 3`=c(high=500, low=225, ml=450), 
        `Gate Setting 4`=c(high=200, low=125, ml=150), 
        `Gate Setting 5`=c(high=100, low=25, ml=85)
    ), 
    `Middle basin`=list(
        `Gate Setting 1`=c(high=200, low=100, ml=150), 
        `Gate Setting 2`=c(high=350, low=50, ml=250), 
        `Gate Setting 3`=c(high=450, low=250, ml=350), 
        `Gate Setting 4`=c(high=350, low=50, ml=250), 
        `Gate Setting 5`=c(high=150, low=50, ml=125)
    ), 
    `Lower basin`=list(
        `Gate Setting 1`=c(high=185, low=85, ml=125),
        `Gate Setting 2`=c(high=450, low=250, ml=350),
        `Gate Setting 3`=c(high=350, low=250, ml=300),
        `Gate Setting 4`=c(high=450, low=250, ml=350),
        `Gate Setting 5`=c(high=125, low=100, ml=110)
    )
)

valuelistC <- list(
    `Upper basin (disabled)`=list(
        `Gate Setting 1`=c(high=300, low=200, ml=250, disabled=TRUE)
    ), 
    `Middle basin`=list(
        `Gate Setting 1`=c(high=200, low=100, ml=150)
    ), 
    `Lower basin`=list(
        `Gate Setting 1`=c(high=185, low=85, ml=125)
    )
)


valuelistD <- list(slider1=c(high=3, low=2, ml=2.5), `A disabled slider`=c(high=2, low=1, ml=1.5, disabled=TRUE), slider3=c(high=5, low=2, ml=4), slider4=c(high=3, low=2.5, ml=2.75))


ui <- fluidPage(
    singleton(tags$head(
#        tags$link(rel="stylesheet", type="text/css", href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css"),
#        tags$script(src="https://code.jquery.com/jquery-1.12.4.js"),
#        tags$script(src="https://code.jquery.com/ui/1.12.1/jquery-ui.js")
        tags$style('.text-bold {font-weight:bold;}')
    )),
    # Application title
    h2(style='text-align:center;', "Input Sliders For Expert Elicitation"),
    fluidRow(
        column(6, style='min-width:900px;',
            p(class='text-bold', '4-point elicitation with repeating grouped categories: Each element on the x-axis contains any number of sub-elements (provided all elements have the same number of sub-elements).'),
            p(class='text-bold', 'Default colors are a blue gradient. The ML cannot move beyond the H or L and vice-versa.'),
            fourPointSliderInput('byGate', '', min=0, max=500, step=1, height=400, valuelist=valuelistA, ylab='Custom Scale Of Elicitation, values')
        ),
        column(6, style='min-width:900px;',
            wellPanel(style="overflow:hidden;",
                p(class='text-bold', 'Sliders can be disabled programmatically. Customize colors by setting either a custom gradient or discrete values.'),
                fourPointSliderInput('byBasin', '', min=0, max=500, step=1, height=400, valuelist=valuelistB, ylab='Custom Scale Of Elicitation, values', col=colorRampPalette(c('red', 'orange', 'yellow', 'green', 'blue')), bg.transparent=FALSE)
            )
        ),
        column(6, style='min-width:900px;',
            p(class='text-bold', 'Single sliders per group. Turn background lines off for a cleaner look.'),
            fourPointSliderInput('singles', '', min=0, max=500, step=1, height=400, valuelist=valuelistC, ylab='Custom Scale Of Elicitation, values', legend=FALSE, bg.lines=FALSE)
        ),
        column(6, style='min-width:900px;',
            wellPanel(style="overflow:hidden;",
                p(class='text-bold', '3-point elicitation sliders are linked to a numeric display. Backgrounds can be either white or transparent.'),
                threePointSliderInput('threepointers', '', min=0, max=5, step=0.1, valuelist=valuelistD, ylab='A small scale (numbers)')
            )
        ),
        div(style='min-height:200px;')
    )
)

