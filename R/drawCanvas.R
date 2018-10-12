makeAxis <- function(range, height, width) {
    ticklabs <- pretty(range[1]:range[2])
    tickchar <- max(nchar(ticklabs))
    tickrange <- range(ticklabs)
    if(missing(width)) {
        mintick <- ticklabs[1]
        ticklabs <- ticklabs[-1]
        ticks <- lapply(rev(ticklabs), function(x) tags$div(class="drawLine-ytick", style=paste0("height: ", height/length(ticklabs), "px;padding-right:10px;text-align:right;"),tags$p(x)))
        ticks <- c(ticks, list(tags$div(style="padding:0px 10px;text-align:right;",tags$p(mintick))))
        tickpct <- 100/length(ticklabs)
    } else {
        maxtick <- ticklabs[length(ticklabs)]
        ticks <- lapply(ticklabs[-length(ticklabs)], function(x) tags$span(class="drawLine-xtick", style=paste0("width: ", width/(length(ticklabs)-1), "px;"), x))
        ticks <- c(ticks, list(tags$span(class="drawLine-xtick", maxtick)))
        tickpct <- 100/(length(ticklabs) - 1)
    }
    if(!ticklabs[length(ticklabs)] %% 2) tickpct <- tickpct/2
    else if(!ticklabs[length(ticklabs)] %% 3) tickpct <- tickpct/3
    # return the tick tags, the % spacing for css lines, the number of characters for y axis offsetting, and the final range from pretty()
    list(ticks, tickpct, tickchar, tickrange)
}

drawLineInput <- function(inputId, xlim, ylim, valuelist, xlab="", ylab="", px.wide, px.high, redrawn=FALSE, width) {
    xtick <- makeAxis(xlim, width=px.wide)
    ytick <- makeAxis(ylim, height=px.high)
    xtickrange <- xtick[[4]]
    ytickrange <- ytick[[4]]
    if(missing(width)) width <- "100%"
    css <- paste0('#', inputId, ' {
        height: ', px.high, 'px;
        width: ', px.wide, 'px;
        border: 1px solid black;
        margin: auto;
        background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #00000000 1px, #00000000 ', ytick[[2]], '%), repeating-linear-gradient(to right, #ddd, #ddd 1px, #00000000 1px, #00000000 ', xtick[[2]], '%);
        background-image: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #00000000 1px, #00000000 ', ytick[[2]], '%), repeating-linear-gradient(to right, #ddd, #ddd 1px, #00000000 1px, #00000000 ', xtick[[2]], '%);
      }'
    )

#    tags$div(class="drawLine-y-lab", style=paste0("height:", px.high, "px;"), p(style=paste0("height:", px.high, "px;width:", px.high,"px;"), ylab)),
    if(!missing(valuelist)) {
        if(!length(valuelist$x)) {
            default <- HTML(toJSON(valuelist, auto_unbox=TRUE, null='null'))
            valuelist <- list(x="new Array()", y="new Array()", d="new Array()")
        } else {
            valuelist <- sapply(c('x', 'y', 'd'), function(x) {
                y <- unlist(valuelist[[x]]) 
                ht <- px.high
                wd <- px.wide
                xlim <- list(min=xtickrange[1], max=xtickrange[2])
                ylim <- list(min=ytickrange[1], max=ytickrange[2])
                if(x=='x') {
                    z <- (y - xlim$min)/(xlim$max - xlim$min) * wd
                } else if(x=='y') {
#                    if(ylim$min < 0) ngcorrection <- abs(ylim$min)/(ylim$max - ylim$min) * ht
#                    else ngcorrection <- ylim$min
                    z <- ht - ( (y - ylim$min)/(ylim$max - ylim$min) * ht)
                } else {
                    z <- y
                }
                jsonlite::toJSON(z, auto_unbox=TRUE, null='null')
            }, simplify=FALSE)
            default <- as.character(toJSON(valuelist, auto_unbox=TRUE, null='null'))
            default <- gsub('"\\[', '\\[', default)
            default <- gsub('\\]"', '\\]', default)
            default <- HTML(default)
        }
    } else {
        default <- HTML('{"x":[], "y":[], "d":[]}')
        valuelist <- list(x="new Array()", y="new Array()", d="new Array()")
    }
    xpad <- ytick[[3]] * 10 + 10 + as.logical(nchar(ylab)) * 65
    #"px;width:", xpad + px.wide + 16, 
    
#    if(!redrawn) initscript <- dragCanvas(inputId, width=px.wide, height=px.high, valuelist=valuelist)
#    else initscript <- tags$script()
    
    canvastag <- tags$div(style=paste0("width:", width, ";"), class="drawLine-input", type="drawLine-input",
        tags$style(css),
        tags$button(id=paste0(inputId, "clearCanvas"), "Clear"),
        tags$div(
            tags$div(class="drawLine-y-lab", style=paste0("height:", px.high, "px;"), p(style=paste0("px;width:", px.high,"px;left:-", px.high/2, "px;top:", px.high/2,"px;"), ylab)),
            tags$div(class="drawLine-y-axis", ytick[[1]]),
            tags$div(id=inputId, class="drawLine-container", `data-value`=default, `data-dims`=HTML(paste0('{"x":', px.wide, ',"y":', px.high, '}')), `data-ylim`=HTML(paste0('{"min":', ytickrange[1], ',"max":', ytickrange[2], '}')), `data-xlim`=HTML(paste0('{"min":', xtickrange[1], ',"max":', xtickrange[2], '}'))),
            tags$div(class="drawLine-x-axis", style=paste0("padding-left:", xpad, "px;"), xtick[[1]]),
            tags$div(class="drawLine-x-lab", style=paste0("padding-left:", xpad, "px;width:", px.wide,"px;"), p(xlab)),
            dragCanvas(inputId, width=px.wide, height=px.high, valuelist=valuelist),
            tags$script(paste0(inputId, "redraw();"))
        )
    )
    htmltools::htmlDependencies(canvastag) <- jqueryDep
    htmltools::attachDependencies(canvastag, enqueryDep, append=TRUE)
}


updateDrawLineInput <- function(session, inputId, label=NULL, valuelist) {
  vals <- dropNulls(valuelist)
  message <- dropNulls(list(
    label = label,
    valuelist = valuelist
  ))
  invisible(session$sendInputMessage(inputId, message))
}




dragCanvas <- function(inputId, width, height, valuelist) {
    tags$script(type="text/javascript",
        HTML(paste0("
            var ", inputId, "canvasWidth = ", width, ";
            var ", inputId, "canvasHeight = ", height, ";
            
            var ", inputId, " = document.getElementById('", inputId, "');
            ", inputId, "canvas = document.createElement('canvas');
            ", inputId, "canvas.setAttribute('width', ", inputId, "canvasWidth);
            ", inputId, "canvas.setAttribute('height', ", inputId, "canvasHeight);
            ", inputId, "canvas.setAttribute('id', '", inputId, "canvas');
            ", inputId, ".appendChild(", inputId, "canvas);
            if(typeof G_vmlCanvasManager != 'undefined') {
	            ", inputId, "canvas = G_vmlCanvasManager.initElement(", inputId, "canvas);
            }
            ", inputId, "context = ", inputId, "canvas.getContext('2d');
            
            $('#", inputId, "canvas').mousedown(function(e){
              var mouseX = e.pageX - this.offsetLeft;
              var mouseY = e.pageY - this.offsetTop;
              
              ", inputId, "paint = true;
              ", inputId, "addClick(e.pageX - this.offsetLeft, e.pageY - this.offsetTop);
              ", inputId, "redraw();
            });
            
            $('#", inputId, "canvas').mousemove(function(e){
              if(", inputId, "paint){
                ", inputId, "addClick(e.pageX - this.offsetLeft, e.pageY - this.offsetTop, true);
                ", inputId, "redraw();
              };
            });
            
            $('#", inputId, "canvas').mouseup(function(e){
              $('#", inputId, "').data('value', {\"x\":", inputId, "clickX, \"y\":", inputId, "clickY, \"d\":", inputId, "clickDrag});
              ", inputId, "paint = false;
            });
            
            $('#", inputId, "').mouseleave(function(e){
              $('#", inputId, "').data('value', {\"x\":", inputId, "clickX, \"y\":", inputId, "clickY, \"d\":", inputId, "clickDrag});
              ", inputId, "paint = false;
            });
            
            var ", inputId, "clickX = ", valuelist$x, ";
            var ", inputId, "clickY = ", valuelist$y, ";
            var ", inputId, "clickDrag = ", valuelist$d, ";
            var ", inputId, "paint;

            function ", inputId, "addClick(x, y, dragging) {
              if(", inputId, "clickX.length) {
                  var last_x = ", inputId, "clickX[", inputId, "clickX.length - 1];
                  if(x < last_x) x = last_x
              }
              ", inputId, "clickX.push(x);
              ", inputId, "clickY.push(y);
              ", inputId, "clickDrag.push(dragging);
            };
            
            function ", inputId, "redraw() {
              ", inputId, "context.clearRect(0, 0, ", inputId, "context.canvas.width, ", inputId, "context.canvas.height); // Clears the canvas
              
              ", inputId, "context.strokeStyle = '#df4b26';
              ", inputId, "context.lineJoin = 'round';
              ", inputId, "context.lineWidth = 5;
			
              for(var i=0; i < ", inputId, "clickX.length; i++) {		
                ", inputId, "context.beginPath();
                //if(", inputId, "clickDrag[i] && i){
                if(i){
                  ", inputId, "context.moveTo(", inputId, "clickX[i-1], ", inputId, "clickY[i-1]);
                 } else {
                   ", inputId, "context.moveTo(", inputId, "clickX[i]-1, ", inputId, "clickY[i]);
                 };
                 ", inputId, "context.lineTo(", inputId, "clickX[i], ", inputId, "clickY[i]);
                 ", inputId, "context.closePath();
                 ", inputId, "context.stroke();
              };
            };

            $('#", inputId, "clearCanvas').click(function(){
                ", inputId, "context.clearRect(0, 0, ", inputId, "context.canvas.width, ", inputId, "context.canvas.height);
                ", inputId, "clickX.length = 0;
                ", inputId, "clickY.length = 0;
                ", inputId, "clickDrag.length = 0;
                $('#", inputId, "').data('value', {\"x\":[], \"y\":[], \"d\":[]});
            }); 
            
            $('#", inputId, "reportCanvas').click(function(){
                var value = $('#", inputId, "').data('value');
                if(value.hasOwnProperty('x')) {
                    console.log('X:');
                    console.log(value.x);
                }
                if(value.hasOwnProperty('y')) {
                    console.log('Y:');
                    console.log(value.y.map(function(e){
                        return ", inputId, "context.canvas.height - e;
                    }));
                }
                if(value.hasOwnProperty('drag')) {
                    console.log('drag:');
                    console.log(value.d);
                }
            });"
        ))
    )
} 

       
#drawLineInput("myInput", xlim=c(0,25), ylim=c(0, 100), xlab="x-label", ylab="y-label", px.wide=800, px.high=600)






