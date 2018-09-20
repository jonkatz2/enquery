





threePointSliderInput <- function(
    inputId, 
    label, 
    min,
    max,
    step,
    valuelist,
    ylab = NULL,
    height = 300,
    ht.unit = c('px', 'em'),
    live.numbers = TRUE,
    vertical = TRUE,
    width = NULL,
    bg.lines = TRUE,
    bg.box = TRUE,
    bg.transparent = TRUE,
    col = '#0044b2'
) {
    if(missing(min) || missing(max)) stop('Must supply both min and max.') 
    if(missing(inputId)) stop('Must supply inputId.')
    if(missing(valuelist)) stop('Must supply valuelist.')
    ht.unit <- match.arg(ht.unit)
    if(ht.unit == 'em') height <- 17 * as.numeric(height)
    divClass <- "form-group shiny-input-container threepointslider"
    ticklabs <- pretty(min:max)
    mintick <- ticklabs[1]
    ticklabs <- ticklabs[-1]
    ticks <- lapply(rev(ticklabs), function(x) tags$div(class="tick", style=paste0("height: ", height/length(ticklabs), "px;padding-right:10px;text-align:right;"),tags$p(x)))
    ticks <- c(ticks, list(tags$div(style="padding-right:10px;text-align:right;",tags$p(mintick))))
    tickpct <- 100/length(ticklabs)
    tickpct <- tickpct/2
    
    spanstyle <- paste0("width:", max(6.5, nchar(max(ticklabs))+3), "em;height:",height,"px;margin-top:10px;margin-bottom:20px;")
    if(bg.lines) {
        if(bg.transparent) spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #00000000 1px, #00000000 ", tickpct, "%);"))
        else spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #fff 1px, #fff ", tickpct, "%);"))
    } else {
        if(bg.transparent) spanstyle <- c(spanstyle, "background:#00000000;")
        else spanstyle <- c(spanstyle, "background:#fff;")
    }
    
    
    contents <- lapply((1:length(valuelist))-1, function(x) {
        # x is the js index (from 0); y is the R index (from 1)
        y <- x+1

        if(bg.box) {
            spanstyle <- c(spanstyle, "border-top:1px solid #ddd;border-bottom:1px solid #ddd;")
            if(y == 1) {
                spanstyle <- c(spanstyle, "border-left:1px solid #ddd;")
            } else if(y == length(valuelist)) {
                spanstyle <- c(spanstyle, "border-right:1px solid #ddd;")
            }
        }
        spanstyle <- paste0(spanstyle, collapse='')
        disabled <- FALSE
        if(length(valuelist[[y]]['disabled'])) disabled <- unlist(valuelist[[y]]['disabled']) 
        
        tags$span(
            tags$span(class="threepointslider-vertical", style=spanstyle,
#                if(x==0 && bg.lines) tags$div(class="threepointslider-vertical-axis", ticks) else NULL,
                tags$span(id=paste0(inputId, "highlow", x), class="highlow", style=paste0("height:",height,"px;"), `data-min`=min, `data-max`=max, `data-step`=step, `data-disabled`=disabled, paste0(unlist(valuelist[[y]][c('low','high')]), collapse=',')),
                tags$span(id=paste0(inputId, "ml", x), class="ml", style=paste0("height:",height,"px;"), `data-min`=min, `data-max`=max, `data-step`=step, `data-disabled`=disabled, unlist(valuelist[[y]]['ml']))
            ),
            if(length(names(valuelist))) tags$p(class="x-axislabel", names(valuelist)[y]) else NULL,
            tags$p(
                tags$p(style="padding-left:1em;display:inline;", "H:"),
                tags$p(id=paste0(inputId, "hlabel", x), style="display:inline;", class=paste0("hlabel", x), style="color:#f6931f; font-weight:bold;")
            ),
            tags$p(
                tags$p(style="padding-left:1em;display:inline;", "L:"),
                tags$p(id=paste0(inputId, "llabel", x), style="display:inline;", class=paste0("llabel", x), style="color:#f6931f; font-weight:bold;")
            ),
            tags$p(
                tags$p(style="display:inline;", "ML:"),
                tags$p(id=paste0(inputId, "mllabel", x), style="display:inline;", class=paste0("mllabel", x), style="color:#f6931f; font-weight:bold;")
            )
        )
    })
            
    contents <- c(list(tags$div(class="threepointslider-vertical-axis", ticks)), contents)
    
    if(length(ylab)) contents <- c(list(tags$div(class="threepointslider-vertical-ylab", style=paste0("height:",height,"px;"), tags$p(style=paste0("height:", height, "px;width:", height, "px;"), ylab))), contents)
    
    inlinestyle <- list(tags$style(paste0("#", inputId, ' .highlow .ui-slider-range {background: ', col, ';}')))
    
    contents <- c(inlinestyle, contents)
    
    slidertag <- tags$div(id=inputId, 
        type = 'threepointslider',
        style = paste0("display:inline-flex;", if (!is.null(width)) paste0("width: ", validateCssUnit(width), ";")),
        class = divClass,
        contents,
        tags$script(type="text/javascript", paste0("threepointslider( '#", inputId, "' );"))
    )
    
    htmltools::htmlDependencies(slidertag) <- jqueryDep
    htmltools::attachDependencies(slidertag, enqueryDep, append=TRUE)
}






