makeAxis <- function(range, height, width) {
    ticklabs <- pretty(range[1]:range[2])
    tickchar <- max(nchar(ticklabs))
    if(missing(width)) {
        mintick <- ticklabs[1]
        ticklabs <- ticklabs[-1]
        ticks <- lapply(rev(ticklabs), function(x) tags$div(class="drawLine-ytick", style=paste0("height: ", height/length(ticklabs), "px;padding-right:10px;text-align:right;"),tags$p(x)))
        ticks <- c(ticks, list(tags$div(style="padding:0px 10px;text-align:right;",tags$p(mintick))))
        tickpct <- 100/length(ticklabs)
    } else {
        ticks <- lapply(ticklabs, function(x) tags$span(class="drawLine-xtick", style=paste0("width: ", width/(length(ticklabs)-1), "px;"), x))
        tickpct <- 100/(length(ticklabs) - 1)
    }
    if(!ticklabs[length(ticklabs)] %% 2) tickpct <- tickpct/2
    else if(!ticklabs[length(ticklabs)] %% 3) tickpct <- tickpct/3
    list(ticks, tickpct, tickchar)
}



drawLineInput <- function(inputId, xlim, ylim, xlab="", ylab="", px.wide, px.high, width) {
    
    xtick <- makeAxis(xlim, width=px.wide)
    ytick <- makeAxis(ylim, height=px.high)
    
    if(missing(width)) width <- "100%"
    css <- paste0('#', inputId, ' {
        height: ', px.high, 'px;
        width: ', px.wide, 'px;
        border: 1px solid black;
        margin: auto;
        background: repeating-linear-gradient(to bottom, #ddd, #ddd 1px, #00000000 1px, #00000000 ', ytick[[2]], '%), repeating-linear-gradient(to right, #ddd, #ddd 1px, #00000000 1px, #00000000 ', xtick[[2]], '%);
      }'
    )
    
    xpad <- ytick[[3]] * 10 + 10 + as.logical(nchar(ylab)) * 77
    
    canvastag <- tags$div(style=paste0("width:", width, ";"), class="drawLine-input", type="drawLine-input",
        tags$style(css),
        tags$button(id=paste0(inputId, "clearCanvas"), "Clear"),
        tags$div(
            tags$div(class="drawLine-y-lab", p(ylab)),
            tags$div(class="drawLine-y-axis", ytick[[1]]),
            tags$div(id=inputId, class="drawLine-container", `data-value`=HTML('{"x":[], "y":[], "d":[]}')),
            tags$div(class="drawLine-x-axis", style=paste0("padding-left:", xpad, "px;"), xtick[[1]]),
            tags$div(class="drawLine-x-lab", style=paste0("padding-left:", px.wide/2-nchar(xlab)*5+xpad, "px;"), p(xlab)),
            dragCanvas(inputId, width=px.wide,height=px.high)
        )
    )
    htmltools::htmlDependencies(canvastag) <- jqueryDep
    htmltools::attachDependencies(canvastag, enqueryDep, append=TRUE)
}

dragCanvas <- function(inputId, width, height) {
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
              ", inputId, "paint = false;
            });
            
            var ", inputId, "clickX = new Array();
            var ", inputId, "clickY = new Array();
            var ", inputId, "clickDrag = new Array();
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
                if(", inputId, "clickDrag[i] && i){
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






