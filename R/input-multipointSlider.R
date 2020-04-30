





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
    col = colorRampPalette(c('#0044b2','#c6d7f2')),
    redraw = FALSE
) {
    if(any(
        missing(min), 
        missing(max), 
        missing(step)
    )) stop('Must supply min, max, and step.') 
    
    if(missing(inputId)) stop('Must supply inputId.')
    if(missing(valuelist)) stop('Must supply valuelist.')
    if(!length(names(valuelist))) stop('valuelist should be a named list.')
    if(length(valuelist$stage)) {
        activestep <- valuelist$stage
        valuelist <- valuelist[names(valuelist) != 'stage']
    } else activestep <- NULL
    grouplabels <- names(valuelist)
    groupnames <- lapply(valuelist, names)
    if(all(groupnames[[1]] %in% c('data', 'conf', 'temporal'))) {
        groupnames <- lapply(valuelist, function(x) names(x$data))
        hasdata <- TRUE
    } else hasdata <- FALSE
    if(!any(unlist(lapply(groupnames, length)))) stop('all values and list elements in valuelist must be named.')
    if(!any(unlist(lapply(groupnames, function(x) {all(x %in% groupnames[[1]]) && all(groupnames[[1]] %in% x)})))) stop('each element of valuelist should be the same length and have the same names.')
    groupnames <- groupnames[[1]]
    if(hasdata) {
        valuelist <- sapply(valuelist, function(x) {
            if(is.list(x$data)) {
                z <- sapply(x, function(y) {
                    sapply(y, unlist, simplify=FALSE)
                }, simplify=FALSE)
                z$conf <- x$conf
                z$temporal <- x$temporal
                z
            } else x$data[groupnames]
        }, simplify=FALSE)
        valuelist <- sapply(valuelist, function(x) {
            if(length(x$conf) || length(x$temporal)) x
            else x$data
        }, simplify=FALSE)
    } else valuelist <- sapply(valuelist, function(x) x[groupnames], simplify=FALSE)
    
    if(is.function(col)) col <- col(length(groupnames))
    else col <- col[1:length(groupnames)]
    
    ht.unit <- match.arg(ht.unit)
    if(ht.unit == 'em') height <- 17 * as.numeric(height)
    
    ticklabs <- pretty(min:max)
    mintick <- ticklabs[1]
    maxtick <- ticklabs[length(ticklabs)]
    ticklabs <- ticklabs[-1]
    ticks <- lapply(rev(ticklabs), function(x) tags$div(class="tick", style=paste0("height: ", height/length(ticklabs), "px;padding-right:10px;text-align:right;"),tags$p(x)))
    ticks <- c(ticks, list(tags$div(style="padding:0px 10px;text-align:right;",tags$p(mintick))))
    tickpct <- 100/length(ticklabs)
    tickpct <- tickpct/2
    
    divClass <- "multipointslider-input"
    # width based on how many sliders are in a .sliderpod
    widest <- max(unlist(lapply(valuelist, length))) * 2.8
    spanstyle <- paste0("height:",height,"px;width:", widest, "em;min-width:6em;")
    # show/hide lines, background transparency
    if(bg.lines) {
        if(bg.transparent) spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, transparent 1px, transparent ", tickpct, "%);background-image: repeating-linear-gradient(0deg, #ddd, #ddd 1px, transparent 1px, transparent ", tickpct, "%);"))
        else spanstyle <- c(spanstyle, paste0("background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #fff 1px, #fff ", tickpct, "%);background-image: repeating-linear-gradient(0deg, #ddd, #ddd 1px, #fff 1px, #fff ", tickpct, "%);"))
    } else {
        if(bg.transparent) spanstyle <- c(spanstyle, "background:transparent;")
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
        confselected <- sublist$conf
        tempselected <- sublist$temporal
        if(length(sublist$data)) sublist <- sublist$data
        # each set of sliders is in a .multipointslider-vertical span 
        subspans <- lapply(1:length(sublist), function(z) {
            livenumber <- "0"
            if(z == length(sublist) && live.numbers) livenumber <- "1"
            if(length(sublist[[z]]['disabled'])) {
                if(!is.na(sublist[[z]]['disabled'])) disabled <- unlist(sublist[[z]]['disabled']) 
            }
            if(length(sublist[[z]]['reference'])) {
                if(!is.na(sublist[[z]]['reference'])) reference <- unlist(sublist[[z]]['reference'])
            }
            tags$span(class="multipointslider-vertical", 
                tags$span(id=paste0(inputId, "highlow", x, "_", z-1), class=paste0("highlow multipointslider", z-1), style=paste0("height:",height,"px;"), `data-min`=mintick, `data-max`=maxtick, `data-step`=step, `data-disabled`=disabled, `data-reference`=reference, `data-label`=grouplabels[y], `data-name`=groupnames[z], `data-frozen`="false", `data-live`=livenumber, paste0(unlist(sublist[[z]][c('low','high')]), collapse=',')),
                tags$span(id=paste0(inputId, "ml", x, "_", z-1), class=paste0("ml multipointslider", z-1, " vis-hide"), style=paste0("height:",height,"px;"), `data-min`=mintick, `data-max`=maxtick, `data-step`=step, `data-disabled`=disabled, `data-reference`=reference, `data-name`=groupnames[z], `data-live`=livenumber, unlist(sublist[[z]]['ml']))
            )
        })
        # The live number display only updates from the right-most slider of each sliderpod
        if(live.numbers) {
            if(x == 0) {
                live.number.display <- div(
                    tags$div(style="padding:0.5em 0em 0.15em 0em;",
                        tags$p(class="live-display-label", style="padding-left:0.7em;display:inline;font-size:0.9em;", "H:"),
                        tags$p(id=paste0(inputId, "highlow", x, "_", length(sublist)-1, "hlabel"), style="display:inline;", class=paste0("live-display"), style="color:#f6931f; font-weight:bold;")
                    ),
                    tags$div(style="padding:0.5em 0em 0.15em 0em;",
                        tags$p(class="live-display-label", style="padding-left:0.7em;display:inline;font-size:0.9em;", "L:"),
                        tags$p(id=paste0(inputId, "highlow", x, "_", length(sublist)-1, "llabel"), style="display:inline;", class="live-display", style="color:#f6931f; font-weight:bold;")
                    ),
                    tags$div(style="padding:0.5em 0em 0.15em 0em;",
                        tags$p(class="live-display-label", style="display:inline;font-size:0.9em;", "ML:"),
                        tags$p(id=paste0(inputId, "ml", x, "_", length(sublist)-1, "mllabel"), style="display:inline;", class="live-display", style="color:#f6931f; font-weight:bold;")
                    )
                )
            } else {
                live.number.display <- div(
                    tags$div(
                        tags$p(class="live-display-label", style="padding-left:0.7em;display:inline;font-size:0.9em;", "H:"),
                        tags$input(id=paste0(inputId, "highlow", x, "_", length(sublist)-1, "hlabel"), style="display:inline;", class="live-display", type="text", style="color:#f6931f; font-weight:bold;", `data-sliderindex`=x)
                    ),
                    tags$div(
                        tags$p(class="live-display-label", style="padding-left:0.7em;display:inline;font-size:0.9em;", "L:"),
                        tags$input(id=paste0(inputId, "highlow", x, "_", length(sublist)-1, "llabel"), style="display:inline;", class="live-display", type="text", style="color:#f6931f; font-weight:bold;", `data-sliderindex`=x)
                    ),
                    tags$div(
                        tags$p(class="live-display-label", style="display:inline;font-size:0.9em;", "ML:"),
                        tags$input(id=paste0(inputId, "ml", x, "_", length(sublist)-1, "mllabel"), style="display:inline;", class="live-display", type="text", style="color:#f6931f; font-weight:bold;", `data-sliderindex`=x)
                    )
                )
            }
        } else live.number.display <- div()
        
        # Temporal selector
        temp_opts <- lapply(c("<1 Year", "1 Year", "3 Years", "5 Years", "10 Years", "15 Years", "25 Years", ">25 Years"), function(o) {
            opt.tag <- tags$option(value=o, o)
            if(length(tempselected)) {
                if(tempselected == o) opt.tag <- tags$option(value=o, selected="selected", o)
            }
            opt.tag
        })
        temp_opts <- c(list(class="temporal vis-hide", `data-trigger`="hover", `data-toggle`="tooltip", `data-placement`="left", `data-container`="body", title="How long to reach the above value?", tags$option(value='','')), temp_opts)
        temporal <- do.call(tags$select, temp_opts)
        
        # confidence
        if(confidence) {
            if(length(confselected)) 
                if(!is.na(confselected)) confselected <- as.numeric(confselected)
            opts <- lapply(seq(55, 95, by=5), function(o) {
                opt.tag <- tags$option(value=o, o)
                if(length(confselected)) {
                    if(confselected == o) opt.tag <- tags$option(value=o, selected="selected", o)
                }
                opt.tag
            })
            opts <- c(list(class="confidence vis-hide", `data-trigger`="hover", `data-toggle`="tooltip", `data-placement`="left", `data-container`="body", title="How confident are you that the range above will contain the actual value?", tags$option(value='','')), opts)
            conf <- do.call(tags$select, opts)
        } else conf <- div()
        
        # the .multipointslider-vertical spans are nested in .sliderpod spans
        tags$span(style=paste0("width:", widest, "em;min-width:6em;"),
            tags$span(class="sliderpod", `data-trigger`="hover", `data-toggle`="tooltip", `data-container`="body", title="For fine adjustment, click a handle to activate it and use your up/down arrow keys to move it.", style=spanstyle, subspans),
            tags$p(class="x-axislabel", names(valuelist)[y]), #padleft
            tags$div(style="text-align:center;", #padleft
#                tags$label(`for`=paste0(inputId, "conf", x), "Conf:"),
                conf,
                temporal,
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
        if(length(activestep)) {
            stepclass <- c('highlow', 'ml', 'confidence', 'temporal', 'validate') 
            active <- stepclass == activestep
            stepclass[active] <- 'active'
            stepclass[!active] <- ''
        } else stepclass <- c('active', '', '', '', '')
        buttons <- tags$nav(class="navbar",
#          tags$p(class="navbar-brand", "Steps"),
          tags$div(class="collapse navbar-collapse",
            tags$div(class="navbar-nav", `data-parent`=inputId,
              tags$a(class=paste0("nav-item nav-link ", stepclass[1]), style="margin-right:-4px;", onclick="stageseq()", `data-stage`="highlow", "Step 1: Set High and Low"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[2]), style="margin-right:-4px;", onclick="stageseq()", `data-stage`="ml", "Step 2: Set Most Likely"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[3]), style="margin-right:-4px;", `data-stage`="confidence", onclick="stageseq()", "Step 3: Set Confidence"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[4]), style="margin-right:-4px;", `data-stage`="temporal", onclick="stageseq()", "Step 4: Set Time Frame"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[5]), onclick="stageseq()", `data-stage`="validate", "Step 5: Validate")
            )
          )
        ) 
    } else {
        if(length(activestep)) {
            stepclass <- c('highlow', 'ml', 'temporal', 'validate') 
            active <- stepclass == activestep
            stepclass[active] <- 'active'
            stepclass[!active] <- ''
        } else stepclass <- c('active', '', '', '')
        buttons <- tags$nav(class="navbar",
#          tags$p(class="navbar-brand", "Steps"),
          tags$div(class="collapse navbar-collapse",
            tags$div(class="navbar-nav", `data-parent`=inputId,
              tags$a(class=paste0("nav-item nav-link ", stepclass[1]), style="margin-right:-4px;", onclick="stageseq()", `data-stage`="highlow", "Step 1: Set High and Low"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[2]), style="margin-right:-4px;", onclick="stageseq()", `data-stage`="ml", "Step 2: Set Most Likely"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[3]), style="margin-right:-4px;", `data-stage`="temporal", onclick="stageseq()", "Step 3: Set Time Frame"),
              tags$a(class=paste0("nav-item nav-link ", stepclass[4]), onclick="stageseq()", `data-stage`="validate", "Step 4: Validate")
            )
          )
        )
    }  
    if(!length(activestep)) activestep <- 'highlow'
    # If element already exists, must first destroy it
    if(redraw) {
        destroyfn <- paste0("destroySlider( '#", inputId, "' );")
    } else {
        destroyfn <- ""
    }
    # The type key is used by the input binding find method
    slidertag <- tags$div(id=inputId, 
        type = 'multipointslider',
        style = if (!is.null(width)) paste0("width: ", shiny::validateCssUnit(width), ";") else '',
        class = divClass,
        buttons,
        legend,
        contents,
        tags$script(type="text/javascript", paste0(destroyfn,"multipointslider( '#", inputId, "' );setstage( '#", inputId, "', '", activestep,"' );"))
        #tags$script(type="text/javascript", paste0("multipointslider( '#", inputId, "' );$( '#", inputId, "' ).find('a.active').first().click();"))
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

# convert a data.frame to a list
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


















