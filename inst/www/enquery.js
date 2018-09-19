// ######################
// single sliders
// ######################

var threepointsliderBinding = new Shiny.InputBinding();

$.extend(threepointsliderBinding, {
  find: function(scope) {
    return $(scope).find('div[type="threepointslider"]');
  },
  
  getId: function(el) {
    return $(el).attr("id");
  },
  
  getValue: function(el) {
    var $arr = {}
    $(el).find( "span > span" ).each( function() { 
      if( $(this).find(".highlow").length ) {
        var $slide = {}
        $slide.high =  $(this).find(".highlow").slider("values", 1);
        $slide.low = $(this).find(".highlow").slider("values", 0);
        $slide.ml = $(this).find(".ml").slider("value");
        $arr[$("p.x-axislabel", $(this).parent() ).text()] = ( $slide );
      };
    } );
    return $arr;
  },
  
  setValue: function(el, value) {
    var $id = "#" + $(el).attr("id");
    for (var key in value) {
      if (value.hasOwnProperty(key)) {
        var sval = value[key]
        $(el).find( "span" ).each( function( index ) { 
          var $label = $(this).find("p.x-axislabel").text();
          if( $label == key ) {
            for (var skey in sval) {
              if( sval.hasOwnProperty("high")) {
                $(this).find(".highlow").slider("values", 1, sval.high);
              };
              if( sval.hasOwnProperty("low")) {
                $(this).find(".highlow").slider("values", 0, sval.low);
              };
              if( sval.hasOwnProperty("ml")) {
                $(this).find(".ml").slider("value", sval.ml);
              };
            };
          };
        });
      };
    };
    
  },
  
  receiveMessage: function(el, data) {
    if (data.hasOwnProperty('values'))
      this.setValue(el, data.values);

//      if (data.hasOwnProperty('label'))
//        $(el).parent().find('label[for="' + $escape(el.id) + '"]').text(data.label);

//      $(el).trigger('change');
  },
  
  subscribe: function(el, callback) {   
    $( el ).find( "span > span" ).each( function() { 
      $(this).find(".highlow").on("slidestop", function( event, ui ) { callback(); } );
      $(this).find(".ml").on("slidestop", function( event, ui ) { callback(); } );
    });
  },

  unsubscribe: function(el) {
    $(el).find("span > span" ).each( function( index ) { 
      $(this).off(".highlow");
      $(this).off(".ml");
    });
  }
  
});

Shiny.inputBindings.register(threepointsliderBinding)

//$( function() {
//    $( "#myEq" ).find( ".highlow" ).on( "slidestop", function( event, ui ) { console.log( fourpointsliderBinding.getValue($('#myEq') ) )} );
//    $( "#myEq" ).find( ".ml" ).on( "slidestop", function( event, ui ) { console.log( fourpointsliderBinding.getValue($('#myEq') ) )} );
//});



//function logval(id) {
//  $( id + ".threepointslider").find("span > span" ).each( function( index ) { 
//      $( this ).find( ".highlow" ).on( "slidestop", function( event, ui ) { console.log($( this ).find( ".highlow" ).slider("values") ); } );
//      $( this ).find( ".ml" ).on( "slidestop", function( event, ui ) { console.log($( this ).find( ".ml" ).slider("values") ); } );
//  });
//};



//Shiny.addCustomMessageHandler("logvalue",
//  function(message) { 
//   logval(message.id);
//   var value = {"slider2":{"high":500, "low":250, "ml": 325}};
//   threepointsliderBinding.setValue($('#myEq'), value);
//   console.log( value );
//  }
//);


// ######################
// create three point sliders
// ######################
function threepointslider( id ) {
  // setup highlow range
  $( id + " > span > span > .highlow" ).each(function( index ) {
    // read initial values from markup and remove that
    var values =  $( this ).text().split(',').map(Number);
    var minval = parseFloat( $( this ).data("min") );
    var maxval = parseFloat( $( this ).data("max") );
    var stepval = parseFloat( $( this ).data("step") );
    var disab = $( this ).data("disabled");
    var disabled = (disab === 'true' || disab === 1 || disab === '1' || disab === true);
    $( this ).empty().slider({
      range: true,
      min: minval,
      max: maxval,
      step: stepval,
      values: values,
      animate: true,
      disabled: disabled,
      orientation: "vertical",
      slide: function(event, ui) { 
        $( id + " .hlabel" + index ).html( $( id + "highlow" + index ).slider( "values", 1 ) );
        $( id + " .llabel" + index ).html( $( id + "highlow" + index ).slider( "values", 0 ) );
        var ml = $(id + "ml" + index ).slider( "value");
        if(ui.values[1] < ml | ui.values[0] > ml){
           return false;
        } else {
          return ui.values;
        }
      },
      stop: function(event, ui) {},
      change: function(event, ui) {
        $( id + " .hlabel" + index ).html( $( id + "highlow" + index ).slider( "values", 1 ) );
        $( id + " .llabel" + index ).html( $( id + "highlow" + index ).slider( "values", 0 ) );
      }
    });
    $( id + " .hlabel" + index ).html( $( id + "highlow" + index ).slider( "values", 1 ) );
    $( id + " .llabel" + index ).html( $( id + "highlow" + index ).slider( "values", 0 ) );
  });
  // setup ml point
  $( id + " > span > span > .ml" ).each(function( index ) {
    // read initial values from markup and remove that
    var value = parseFloat( $( this ).text() );
    var minval = parseFloat( $( this ).data("min") );
    var maxval = parseFloat( $( this ).data("max") );
    var stepval = parseFloat( $( this ).data("step") );
    var disab = $( this ).data("disabled");
    var disabled = (disab === 'true' || disab === 1 || disab === '1' || disab === true);
    $( this ).empty().slider({
      value: value,
      min: minval,
      max: maxval,
      step: stepval,
      animate: true,
      disabled: disabled,
      orientation: "vertical",
      slide: function(event, ui) { 
        $( id + " .mllabel" + index ).html( $( id + "ml" + index ).slider( "value" ) );
        var high = $(id + "highlow" + index ).slider( "values", 1);
        var low =  $(id + "highlow" + index ).slider( "values", 0);
        if(ui.value > high | ui.value < low){
           return false;
        } else {
          return ui.value;
        }
      },
      stop: function(event, ui) {},
      change: function(event, ui) {
        $( id + " .mllabel" + index ).html( $( id + "ml" + index ).slider( "value" ) );
      }
    });
    $( id + " .mllabel" + index ).html( $( id + "ml" + index ).slider( "value" ) );
  });
};

function getValue(el) {
  var $arr = {}
  $(el).find( "span > span" ).each( function( index ) { 
    var $slide = {}
    $slide.high =  $(this).find(".highlow").slider("values", 1);
    $slide.low = $(this).find(".highlow").slider("values", 0);
    $slide.ml = $(this).find(".ml").slider("value");
    $arr[$("p.x-axislabel", $(this).parent() ).text()] = ( $slide )
  } );
  return $arr;
}

// ######################
// grouped sliders
// ######################
var fourpointsliderBinding = new Shiny.InputBinding();

$.extend(fourpointsliderBinding, {
  find: function(scope) {
    return $(scope).find('div[type="fourpointslider"]');
  },
  
  getId: function(el) {
    return $(el).attr("id");
  },
  
  getValue: function(el) {
    var pod = {}
    $(el).find( "span" ).each( function( i ) {
      var grp = {}
      var label = $(this).find("p.x-axislabel").text();
      if(label.length) {
        $(this).find( ".sliderpod .fourpointslider-vertical" ).each(function( ) {
          if( $(this).find(".highlow").length ) {
            var name = $(this).find(".highlow").data("name");
            var slide = {}
            slide.high =  $(this).find(".highlow").slider("values", 1);
            slide.low = $(this).find(".highlow").slider("values", 0);
            slide.ml = $(this).find(".ml").slider("value");
            grp[name] = ( slide );
          };
        });
        var conf = $(this).find( "input" ).val();
        pod[label] = ( { "data":grp, "conf":conf } );
      };
    });
    return pod;
  },
  
  setValue: function(el, valuelist) {
    var $id = "#" + $(el).attr("id");
    for (var key in valuelist) {
      if (valuelist.hasOwnProperty(key)) {
        var sval = valuelist[key]
        $(el).find( ".sliderpod" ).each( function( ) {
          $(this).find( ".fourpointslider-vertical" ).each(function( ) {
            var label = $(this).find(".highlow").data("label");
//            var label = $(this).find("p.x-axislabel").text();
            if( label == key ) {
              for (var skey in sval) {
                var setval = sval[skey];
                var highlow = $(this).find(".highlow");
                var ml = $(this).find(".ml");
                var name = highlow.data("name");
                if( name == skey ) {
                  if( setval.hasOwnProperty("high")) {
                    highlow.slider("values", 1, setval.high);
                  };
                  if( setval.hasOwnProperty("low")) {
                    highlow.slider("values", 0, setval.low);
                  };
                  if( setval.hasOwnProperty("ml")) {
                    ml.slider("value", setval.ml);
                  };
                  if( setval.hasOwnProperty("disabled")) {
                    ml.slider("disabled", setval.disabled);
                    highlow.slider("disabled", setval.disabled);
                  };
                  if( setval.hasOwnProperty("reference")) {
                    ml.data("reference", setval.reference);
                    highlow.data("reference", setval.reference);
                  };
                };
              };
            };
          });
        });
      };
    }
  },
  
  receiveMessage: function(el, data) {
    if (data.hasOwnProperty('valuelist'))
      this.setValue(el, data.valuelist);

//      if (data.hasOwnProperty('label'))
//        $(el).parent().find('label[for="' + $escape(el.id) + '"]').text(data.label);

//      $(el).trigger('change');
  },
  
  subscribe: function(el, callback) {   
    $( el ).find( ".fourpointslider-vertical" ).each( function() { 
      $(this).find(".highlow").on("slidestop", function( event, ui ) { callback(); } );
      $(this).find(".ml").on("slidestop", function( event, ui ) { callback(); } );
    });
    $( el ).find( "input" ).each( function() { 
      $(this).on('keyup.textInputBinding input.textInputBinding', function (event) {
        callback(true);
      });
    })
    $( el ).find( "input" ).each( function() { 
      $(this).on("change", function(event) { callback(false); } );
    });
  },

  unsubscribe: function(el) {
    $(el).find("fourpointslider-vertical" ).each( function( index ) { 
      $(this).off(".highlow");
      $(this).off(".ml");
    });
    $( el ).find( "input" ).each( function() { 
      $(this).off();
    });
  }
  
});

Shiny.inputBindings.register(fourpointsliderBinding)


// ######################
// create grouped sliders
// ######################
function fourpointslider( id ) {
// setup highlow range
  $( id + " .sliderpod" ).each(function( i ) {
     $(this).find( ".fourpointslider-vertical .highlow" ).each(function( j ) {
        // read initial values from markup and remove that
        var values = $( this ).text().split(',').map(Number);
        var min = parseFloat( $( this ).data("min") );
        var max = parseFloat( $( this ).data("max") );
        var step = parseFloat( $( this ).data("step") );
        // these two data vals come from R and may deviate from bare true
        var disab = $( this ).data("disabled");
        var disabled = isTrue(disab);
        var ref = $( this ).data("reference");
        var reference = isTrue(ref);
        var subid = $(this).attr("id");
        
        $( this ).empty().slider({
          range: true,
          min: min,
          max: max,
          step: step,
          values: values,
          animate: true,
          disabled: disabled,
          orientation: "vertical",
          slide: function(event, ui) {
            if( $(this).data("frozen") == "true" || reference ) { 
              //alert("High and Low values are frozen while you set a Most likely value.");
              return false;
            } else {
              if( $(this).data("live") == "1" ) { 
                $( "#" + subid + "hlabel" ).html( ui.values[1] );
                $( "#" + subid + "llabel" ).html( ui.values[0] );
              };
              return true;
            }; 
          },
          change: function(event, ui) {
            if( $(this).data("live") == "1" ) { 
              var id = $(this).attr("id");
                $( "#" + subid + "hlabel" ).html( ui.values[1] );
                $( "#" + subid + "llabel" ).html( ui.values[0] );
            };
          },
//          slide: function(event, ui) {
//          slide: function(event, ui) {
//            var ml = $(id + "ml" + i + "_" + j ).slider( "value");
//            if(ui.values[1] < ml | ui.values[0] > ml){
//               return false;
//            } else {
//              return ui.values;
//            }
//          },
          stop: function(event, ui) {}
      });
      // start the live update
      if( $(this).data("live") == "1" ) { 
        $( "#" + subid + "hlabel").html( $( this ).slider( "values", 1 ) );
        $( "#" + subid + "llabel").html( $( this ).slider( "values", 0 ) );
      };
    });
  });
  // setup ml point
  $( id + " .sliderpod" ).each(function( i ) {
      $(this).find( ".fourpointslider-vertical .ml" ).each(function( j ) {
        // read initial values from markup and remove that
        var value = parseFloat( $( this ).text() );
        var min = parseFloat( $( this ).data("min") );
        var max = parseFloat( $( this ).data("max") );
        var step = parseFloat( $( this ).data("step") );
        var disab = $( this ).data("disabled");
        var disabled = isTrue(disab);
        var ref = $( this ).data("reference");
        var reference = isTrue(ref);
        var subid = $(this).attr("id");
        $( this ).empty().slider({
          value: value,
          min: min,
          max: max,
          step: step,
          animate: true,
          disabled: disabled,
          orientation: "vertical",
          slide: function(event, ui) {
            if( reference ) { 
              //alert("High and Low values are frozen while you set a Most likely value.");
              return false;
            } else {
              if( $(this).data("live") == "1" ) { 
                $( "#" + subid + "mllabel" ).html( ui.value );
              };
              return true;
            }; 
          },
          change: function(event, ui) {
            if( $(this).data("live") == "1" ) { 
              var id = $(this).attr("id");
              $( "#" + subid + "mllabel" ).html( ui.value );
            };
          },
//          slide: function(event, ui) {
//            var high = $(id + "highlow" + i + "_" + j ).slider( "values", 1);
//            var low =  $(id + "highlow" + i + "_" + j ).slider( "values", 0);
//            if(ui.value > high | ui.value < low){
//               return false;
//            } else {
//              return ui.value;
//            }
//          },
          stop: function(event, ui) {}
        });
        // start the live update
        if( $(this).data("live") == "1" ) { 
          $( "#" + subid + "mllabel").html( $( this ).slider( "value" ) );
        };
     });
  });
};

// march through the steps of a 4-point elicitation on nav click
$(document).ready(function() {
    $(".fourpointslider-input a").click(function(event) {
        var par = $(event.target).parent();
        par.find("a").each(function() { $(this).removeClass("active") });
        $(event.target).addClass(" active");
        
        var id = "#" + par.data("parent");
        var step = $(event.target).data("step");
        
        if(step == "ml") {
            enableML(id);
            disableHighLow(id);
            disableConfidence(id);
        } else if(step == "confidence") {
            enableConfidence(id);
            enableML(id);
            disableHighLow(id);
        } else if(step == "highlow") {
            enableHighLow(id);
            disableML(id);
            disableConfidence(id);
        } else if(step == "validate") {
            validateFPS(id);
        };
    });
});

// check against several variations on true
function isTrue( x ) {
    var truth = (x === 'TRUE' || x === 'true' || x === 1 || x === '1' || x === true);
    return truth; 
};

// unhide the ML slider
function enableML( id ) {
    $(id).find(".ml").each( function() { 
        $(this).removeClass("vis-hide"); 
        // check for data("disabled")
        var disabled = $(this).data("disabled")
        if(!isTrue(disabled)) $(this).slider( "enable" );
    });
};

// hide the ML slider
function disableML( id ) {
    $(id).find(".ml").each( function() {
        $(this).slider( "disable" );
        $(this).addClass(" vis-hide");
    });
};

// unfreeze the highlow slider
function enableHighLow( id ) {   
    $(id).find(".highlow").each( function() { 
        $(this).data("frozen", "false");
    });
};

// freeze the highlow slider
function disableHighLow( id ) {
    $(id).find(".highlow").each( function() { 
        $(this).data("frozen", "true");
        //$(this).slider("disable");
    });
};

// show the confidence inputs
function enableConfidence( id ) {
    $(id).find("input").each( function() {
        $(this).removeClass("vis-hide"); 
    });
};

// hide the confidence inputs
function disableConfidence( id ) {
    $(id).find("input").each( function() {
        $(this).addClass("vis-hide"); 
    });
};

// validate four point slider responses
function validateFPS( id ) {
    enableConfidence(id);
    enableML(id);
    var mlerr = false;
    var confblank = false;
    var conflow = false;
    // ml value must be between high and low values
    $(id).find(".fourpointslider-vertical").each(function() { 
        var ml = $(this).find(".ml").slider("value");
        var highlow =  $(this).find(".highlow").slider("values");
        if(ml < highlow[0] || ml > highlow[1]) {
            $(this).addClass(" mlerr-err");
            //$(this).effect("highlight", {color: '#b3ffb3'}, 10000);
            mlerr = true;
        } else {
            $(this).removeClass("mlerr-err");
        };
    });
    // confidence must not be blank, or less than 50
    $(id).find("input").each(function() { 
        if($(this).val() == "") {
            $(this).addClass(" confblank-err");
            //$(this).effect("highlight", {color: '#ffff99'}, 10000); 
            confblank = true;
        } else {
            $(this).removeClass(" confblank-err");
        };
        if(parseFloat($(this).val()) < 50) {
            $(this).addClass(" conflow-err");
            //$(this).effect("highlight", {color: '#ff9380'}, 10000);
            conflow = true;
        } else {
            $(this).removeClass(" conflow-err");
        };
    }); 
    // place a legend onscreen
    var leg = (mlerr || confblank || conflow);
    if(leg) {
        if(mlerr) {
            mlerr = "<tr><td style='padding-right:1em;'>ML out of bounds</td><td class='mlerr-err legend-fill'></td></tr>";
        } else {
            mlerr = "";
        };
        if(confblank) {
            confblank = "<tr><td style='padding-right:1em;'>Confidence missing</td><td class='confblank-err legend-fill'></td></tr>";
        } else {
            confblank = "";
        };
        if(conflow) {
            conflow = "<tr><td style='padding-right:1em;'>Confidence < 50</td><td class='conflow-err legend-fill'></td></tr>";
        } else {
            conflow = "";
        };
        var leghtml = "<table>" + mlerr + confblank + conflow + "</table>";
        $(id).find(".validate-legend").html(leghtml);
    } else {
        $(id).find(".validate-legend").empty();
    };
    
};




















