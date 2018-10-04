





multiPointSliderInput <- function(
    inputId, 
    label, 
    min,
    max,
    step,
    valuelist,
    ylab = NULL,
    confidence = TRUE,
    live.numbers = TRUE,
    vertical = TRUE, 
    width = NULL,
    legend = TRUE,
    bg.lines = TRUE,
    bg.box = TRUE,
    bg.transparent = TRUE,
    height = 300,
    ht.unit = c('px', 'em'),
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
    grouplabels <- names(valuelist)
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
    
    divClass <- "multipointslider-input"
    # width based on how many sliders are in a .sliderpod
    widest <- max(unlist(lapply(valuelist, length))) * 3.8
    spanstyle <- paste0("height:",height,"px;width:", widest, "em;min-width:6em;")
    # show/hide lines, background transparency
    if(bg.lines) {
        if(bg.transparent) spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #00000000 1px, #00000000 ", tickpct, "%);"))
        else spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #fff 1px, #fff ", tickpct, "%);"))
    } else {
        if(bg.transparent) spanstyle <- c(spanstyle, "background:#00000000;")
        else spanstyle <- c(spanstyle, "background:#fff;")
    }
    
    # list of sliders  
    disabled <- reference <- FALSE  
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
        # each set of sliders is in a .multipointslider-vertical span 
        subspans <- lapply(1:length(sublist), function(z) {
            livenumber <- "0"
            if(z == length(sublist) && live.numbers) livenumber <- "1"
            
            if(!is.na(sublist[[z]]['disabled'])) disabled <- unlist(sublist[[z]]['disabled']) 
            if(!is.na(sublist[[z]]['reference'])) reference <- unlist(sublist[[z]]['reference'])
            tags$span(class="multipointslider-vertical", 
                tags$span(id=paste0(inputId, "highlow", x, "_", z-1), class=paste0("highlow multipointslider", z-1), style=paste0("height:",height,"px;"), `data-min`=min, `data-max`=max, `data-step`=step, `data-disabled`=disabled, `data-reference`=reference, `data-label`=grouplabels[y], `data-name`=groupnames[z], `data-frozen`="false", `data-live`=livenumber, paste0(unlist(sublist[[z]][c('low','high')]), collapse=',')),
                tags$span(id=paste0(inputId, "ml", x, "_", z-1), class=paste0("ml multipointslider", z-1, " vis-hide"), style=paste0("height:",height,"px;"), `data-min`=min, `data-max`=max, `data-step`=step, `data-disabled`=disabled, `data-reference`=reference, `data-name`=groupnames[z], `data-live`=livenumber, unlist(sublist[[z]]['ml']))
            )
        })
        # The live number display only updates from the right-most slider of each sliderpod
        if(live.numbers) {
            live.number.display <- div(
                tags$div(
                    tags$p(class="live-display-label", style="padding-left:1em;display:inline;", "H:"),
                    tags$p(id=paste0(inputId, "highlow", x, "_", length(sublist)-1, "hlabel"), style="display:inline;", class=paste0("live-display"), style="color:#f6931f; font-weight:bold;")
                ),
                tags$div(
                    tags$p(class="live-display-label", style="padding-left:1em;display:inline;", "L:"),
                    tags$p(id=paste0(inputId, "highlow", x, "_", length(sublist)-1, "llabel"), style="display:inline;", class="live-display", style="color:#f6931f; font-weight:bold;")
                ),
                tags$div(
                    tags$p(class="live-display-label", style="display:inline;", "ML:"),
                    tags$p(id=paste0(inputId, "ml", x, "_", length(sublist)-1, "mllabel"), style="display:inline;", class="live-display", style="color:#f6931f; font-weight:bold;")
                )
            )
        } else live.number.display <- div()
        
        # confidence
        if(confidence) conf <- tags$select(class="vis-hide", tags$option(value='', ''), tags$option(value=55, '55'), tags$option(value=60, '60'), tags$option(value=65, '65'), tags$option(value=70, '70'), tags$option(value=75, '75'), tags$option(value=80, '80'), tags$option(value=85, '85'), tags$option(value=90, '90'), tags$option(value=95, '95'))
        else conf <- div()
        
        # the .multipointslider-vertical spans are nested in .sliderpod spans
        tags$span(style=paste0("width:", widest, "em;min-width:6em;"),
            tags$span(class="sliderpod", style=spanstyle, subspans),
            tags$p(class="x-axislabel", names(valuelist)[y]), #padleft
            tags$div(style="text-align:center;", #padleft
#                tags$label(`for`=paste0(inputId, "conf", x), "Conf:"),
                conf,
#                tags$input(class="vis-hide", style="text-align:center;", type="text", placeholder="Conf: 50-100%"),
                live.number.display
            )
        )
    })
    # lead with the vertical axis, follow with a placeholder for the validation legend
    contents <- c(list(tags$div(class="multipointslider-vertical-axis", style=paste0("height:",height,"px;"), ticks)), contents, list(tags$div(class="validate-legend")))
    # optional y-axis label
    if(length(ylab)) contents <- c(list(tags$div(class="multipointslider-vertical-ylab", style=paste0("height:",height,"px;"), tags$p(style=paste0("height:", height, "px;width:", height, "px;"), ylab))), contents)
    # style the colors of each slider
    inlinestyle <- list(tags$style(
        paste0(unlist(lapply(1:length(groupnames), function(x) {
            paste0("#", inputId, ' .highlow.multipointslider', x-1, ' .ui-slider-range {background: ', col[x], ';}')
        })), collapse='\n')
    ))
    contents <- c(inlinestyle, contents)
    # add a legend if requested
    if(legend) {
        tr <- lapply(1:length(groupnames), function(x) {
            tags$tr(
                tags$td(style=paste0("padding:0em 1em 0em ", 3 * length(c(bg.lines, as.logical(length(ylab))))+1,"em;"), groupnames[x]),
                tags$td(tags$div(style=paste0("padding:8px;height:1em;width:3em;background-color:", col[x], ";")))
            )
        })
        legend <- tags$table(tr)
    } else legend <- NULL
    # A nav above the input has buttons for the four steps
    if(confidence) {
        buttons <- tags$nav(class="navbar",
#          tags$p(class="navbar-brand", "Steps"),
          tags$div(class="collapse navbar-collapse",
            tags$div(class="navbar-nav", `data-parent`=inputId,
              tags$a(class="nav-item nav-link active", style="margin-right:-4px;", `data-step`="highlow", "Step 1: Set High and Low"),
              tags$a(class="step-ml nav-item nav-link", style="margin-right:-4px;", `data-step`="ml", "Step 2: Set Most Likely"),
              tags$a(class="nav-item nav-link", style="margin-right:-4px;", `data-step`="confidence", "Step 3: Set Confidence"),
              tags$a(class="nav-item nav-link", `data-step`="validate", "Step 4: Validate")
            )
          )
        ) 
    } else {
        buttons <- tags$nav(class="navbar",
#          tags$p(class="navbar-brand", "Steps"),
          tags$div(class="collapse navbar-collapse",
            tags$div(class="navbar-nav", `data-parent`=inputId,
              tags$a(class="nav-item nav-link active", style="margin-right:-4px;", `data-step`="highlow", "Step 1: Set High and Low"),
              tags$a(class="step-ml nav-item nav-link", style="margin-right:-4px;", `data-step`="ml", "Step 2: Set Most Likely"),
              tags$a(class="nav-item nav-link", `data-step`="validate", "Step 3: Validate")
            )
          )
        )
    }    
    # The type key is used by the input binding find method
    slidertag <- tags$div(id=inputId, 
        type = 'multipointslider',
        style = if (!is.null(width)) paste0("width: ", shiny::validateCssUnit(width), ";") else '',
        class = divClass,
        buttons,
        legend,
        contents,
        tags$script(type="text/javascript", paste0("multipointslider( '#", inputId, "' );"))
    )
    
    htmltools::htmlDependencies(slidertag) <- jqueryDep
    htmltools::attachDependencies(slidertag, enqueryDep, append=TRUE)
}


# convert a list to a data.frame
sliderTable <- function(x) {
    conf <- lapply(x, function(y) {
        if(length(y$conf)) y$conf
        else NA
    })
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
    for(i in 3:6) hlml[,i] <- as.numeric(hlml[,i])
    hlml
}

sliderList <- function(x) {
    sapply(x$name, function(y) {
        slids <- sapply(x[x$name == y, 'label'], function(z) {
            as.list(x[x$name == y & x$label == z, c('high', 'low', 'ml')])
        }, simplify=FALSE)
        conf <- x[x$name == y, 'confidence'][1]
        if(is.na(conf)) conf <- ''
        c(list(conf=conf), slids)
    }, simplify=FALSE)
}


















