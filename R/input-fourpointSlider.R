





fourPointSliderInput <- function(
    inputId, 
    label, 
    min,
    max,
    step,
    valuelist,
    ylab = NULL,
    height = 300,
    ht.unit = c('px', 'em'),
    vertical = TRUE, 
    width = NULL,
    legend = TRUE,
    bg.lines = TRUE,
    bg.box = TRUE,
    bg.transparent = TRUE,
    col = colorRampPalette(c('#0044b2','#c6d7f2'))
) {
    if(any(
        missing(min), 
        missing(max), 
        missing(step)
    )) stop('Must supply both min and max.') 
    
    if(missing(inputId)) stop('Must supply inputId.')
    if(missing(valuelist)) stop('Must supply valuelist.')
    if(!length(names(valuelist))) stop('valuelist should be a named list.')
    
    groupnames <- lapply(valuelist, names)
    if(!any(unlist(lapply(groupnames, length)))) stop('all values and list elements in valuelist must be named.')
    if(!any(unlist(lapply(groupnames, function(x) {all(x %in% groupnames[[1]]) && all(groupnames[[1]] %in% x)})))) stop('each element of valuelist should be the same length and have the same names.')
    groupnames <- groupnames[[1]]
    valuelist <- sapply(valuelist, function(x) x[groupnames], simplify=FALSE)
    
    if(is.function(col)) col <- col(length(groupnames))
    else col <- col[1:length(groupnames)]
    
    ht.unit <- match.arg(ht.unit)
    if(ht.unit == 'em') height <- 17 * as.numeric(height)
    
    ticklabs <- pretty(min:max)
    mintick <- ticklabs[1]
    ticklabs <- ticklabs[-1]
    ticks <- lapply(rev(ticklabs), function(x) tags$div(class="tick", style=paste0("height: ", height/length(ticklabs), "px;padding-right:10px;text-align:right;"),tags$p(x)))
    ticks <- c(ticks, list(tags$div(style="padding:0px 10px;text-align:right;",tags$p(mintick))))
    tickpct <- 100/length(ticklabs)
    tickpct <- tickpct/2
    
    divClass <- "fourpointslider-input"
    
    widest <- max(unlist(lapply(valuelist, length))) * 3.2
    spanstyle <- paste0("height:",height,"px;width:", widest, "em;min-width:6em;")
    if(bg.lines) {
        if(bg.transparent) spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #00000000 1px, #00000000 ", tickpct, "%);"))
        else spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #fff 1px, #fff ", tickpct, "%);"))
    } else {
        if(bg.transparent) spanstyle <- c(spanstyle, "background:#00000000;")
        else spanstyle <- c(spanstyle, "background:#fff;")
    }
    
    disabled <- FALSE
        
    contents <- lapply(1:length(valuelist)-1, function(x) {
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
        sublist <- valuelist[[y]]
        if(!is.list(sublist)) stop('valuelist must be a list of lists of vectors, or a list of list of lists.')
        
        subspans <- lapply(1:length(sublist), function(z) {
            if(!is.na(sublist[[z]]['disabled'])) disabled <- unlist(sublist[[z]]['disabled']) 
            tags$span(class="fourpointslider-vertical", 
                tags$span(id=paste0(inputId, "highlow", x, "_", z-1), class=paste0("highlow fourpointslider", z-1), style=paste0("height:",height,"px;"), `data-min`=min, `data-max`=max, `data-step`=step, `data-disabled`=disabled, `data-name`=groupnames[z], paste0(unlist(sublist[[z]][c('low','high')]), collapse=',')),
                tags$span(id=paste0(inputId, "ml", x, "_", z-1), class=paste0("ml fourpointslider", z-1), style=paste0("height:",height,"px;"), `data-min`=min, `data-max`=max, `data-step`=step, `data-disabled`=disabled, `data-name`=groupnames[z], unlist(sublist[[z]]['ml']))
            )
        })
        
        tags$span(style=paste0("width:", widest, "em;min-width:6em;"),
            tags$span(class="sliderpod", style=spanstyle, subspans),
            tags$p(class="x-axislabel", names(valuelist)[y]), #padleft
            tags$p(style="text-align:center;", #padleft
#              tags$label(`for`=paste0(inputId, "conf", x), "Conf:"),
              tags$input(style="text-align:center;", type="text", placeholder="Conf: 50-100%")
            )
        )
    })
    
    contents <- c(list(tags$div(class="fourpointslider-vertical-axis", style=paste0("height:",height,"px;"), ticks)), contents)
    
    if(length(ylab)) contents <- c(list(tags$div(class="fourpointslider-vertical-ylab", style=paste0("height:",height,"px;"), tags$p(style=paste0("height:", height, "px;width:", height, "px;"), ylab))), contents)
    
    inlinestyle <- list(tags$style(
        paste0(unlist(lapply(1:length(groupnames), function(x) {
            paste0("#", inputId, ' .highlow.fourpointslider', x-1, ' .ui-slider-range {background: ', col[x], ';}')
        })), collapse='\n')
    ))
    
    contents <- c(inlinestyle, contents)
    
    if(legend) {
        tr <- lapply(1:length(groupnames), function(x) {
            tags$tr(
                tags$td(style=paste0("padding:0em 1em 0em ", 3 * length(c(bg.lines, as.logical(length(ylab))))+1,"em;"), groupnames[x]),
                tags$td(tags$div(style=paste0("padding:8px;height:1em;width:3em;background-color:", col[x], ";")))
            )
        })
        legend <- tags$table(tr)
    } else legend <- NULL
    
    slidertag <- tags$div(id=inputId, 
        type = 'fourpointslider',
        style = if (!is.null(width)) paste0("width: ", shiny::validateCssUnit(width), ";") else '',
        class = divClass,
        legend,
        contents,
        tags$script(type="text/javascript", paste0("fourpointslider( '#", inputId, "' );"))
    )
    
    htmltools::htmlDependencies(slidertag) <- jqueryDep
    htmltools::attachDependencies(slidertag, enqueryDep, append=TRUE)
}



fmtFourPointSlider <- function(x) {
    conf <- lapply(x, function(y) y$conf)
    hlml <- lapply(x, function(y) {
        subl <- lapply(y$data, function(z) as.data.frame(z))
        do.call(rbind.data.frame, subl)
    })
    hlml <- lapply(1:length(x), function(y) {
        dat <- hlml[[y]]
        dat$name <- names(x)[y]
        dat$label <- rownames(dat)
        dat$confidence <- conf[y]
        dat[c(4,5,1:3,6)]
    })
    hlml <- do.call(rbind.data.frame, hlml)
    rownames(hlml) <- 1:nrow(hlml)
    hlml
}




















