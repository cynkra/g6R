# g6_plugins creates proper plugin configuration

    Code
      g6_plugins(g6())
    Condition
      Error in `g6_plugins()`:
      ! You must provide at least one plugin configuration.

# validate plugins works

    Code
      g6_plugins(g6(), "blabla")
    Condition
      Error in `validate_component()`:
      ! 'blabla' is not a valid plugin. Valid choices are: background, bubble-sets, contextmenu, edge-bundling, edge-filter-lens, fisheye, fullscreen, grid-line, history, hull, legend, minimap, snapline, timebar, toolbar, tooltip, watermark.
    Code
      g6_plugins(g6(), list(test = 1))
    Condition
      Error in `validate_component()`:
      ! 'unknown' is not a valid plugin. Valid choices are: background, bubble-sets, contextmenu, edge-bundling, edge-filter-lens, fisheye, fullscreen, grid-line, history, hull, legend, minimap, snapline, timebar, toolbar, tooltip, watermark.

# individual plugin functions work correctly

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 6
        .. .. ..$ width         : chr "100%"
        .. .. ..$ height        : chr "100%"
        .. .. ..$ backgroundSize: chr "cover"
        .. .. ..$ transition    : chr "background 0.5s"
        .. .. ..$ zIndex        : chr "-1"
        .. .. ..$ type          : chr "background"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Condition
      Error in `valid_choices[[x]]()`:
      ! 'members' is required and must contain at least one element ID

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 8
        .. .. ..$ key      : chr "contextmenu"
        .. .. ..$ className: chr "g6-contextmenu"
        .. .. ..$ trigger  : chr "contextmenu"
        .. .. ..$ offset   : num [1:2] 4 4
        .. .. ..$ onClick  : 'JS_EVAL' chr "(value, target, current) => {\n        const graph = HTMLWidgets\n          .find(`#${target.closest('.g6').id}"| __truncated__
        .. .. ..$ getItems : 'JS_EVAL' chr "() => {\n        return [\n          { name: 'Create edge', value: 'create_edge' },\n          { name: 'Remove "| __truncated__
        .. .. ..$ enable   : 'JS_EVAL' chr "(e) => e.targetType === 'node'"
        .. .. ..$ type     : chr "contextmenu"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 10
        .. .. ..$ key            : chr "edge-bundling"
        .. .. ..$ bundleThreshold: num 0.6
        .. .. ..$ cycles         : num 6
        .. .. ..$ divisions      : num 1
        .. .. ..$ divRate        : num 2
        .. .. ..$ iterations     : num 90
        .. .. ..$ iterRate       : num 0.667
        .. .. ..$ K              : num 0.1
        .. .. ..$ lambda         : num 0.1
        .. .. ..$ type           : chr "edge-bundling"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 10
        .. .. ..$ key           : chr "edge-filter-lens"
        .. .. ..$ trigger       : chr "pointermove"
        .. .. ..$ r             : num 60
        .. .. ..$ minR          : num 0
        .. .. ..$ scaleRBy      : chr "wheel"
        .. .. ..$ nodeType      : chr "both"
        .. .. ..$ nodeStyle     :List of 1
        .. .. .. ..$ label: logi FALSE
        .. .. ..$ edgeStyle     :List of 1
        .. .. .. ..$ label: logi TRUE
        .. .. ..$ preventDefault: logi TRUE
        .. .. ..$ type          : chr "edge-filter-lens"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 11
        .. .. ..$ key           : chr "fish-eye"
        .. .. ..$ trigger       : chr "pointermove"
        .. .. ..$ r             : num 120
        .. .. ..$ minR          : num 0
        .. .. ..$ d             : num 1.5
        .. .. ..$ maxD          : num 5
        .. .. ..$ minD          : num 0
        .. .. ..$ showDPercent  : logi TRUE
        .. .. ..$ nodeStyle     :List of 1
        .. .. .. ..$ label: logi TRUE
        .. .. ..$ preventDefault: logi TRUE
        .. .. ..$ type          : chr "fisheye"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 3
        .. .. ..$ key    : chr "fullscreen"
        .. .. ..$ autoFit: logi TRUE
        .. .. ..$ type   : chr "fullscreen"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 10
        .. .. ..$ key            : chr "grid-line"
        .. .. ..$ border         : logi TRUE
        .. .. ..$ borderLineWidth: num 1
        .. .. ..$ borderStroke   : chr "#eee"
        .. .. ..$ borderStyle    : chr "solid"
        .. .. ..$ follow         : logi FALSE
        .. .. ..$ lineWidth      : num 1
        .. .. ..$ size           : num 20
        .. .. ..$ stroke         : chr "#eee"
        .. .. ..$ type           : chr "grid-line"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 3
        .. .. ..$ key      : chr "history"
        .. .. ..$ stackSize: num 0
        .. .. ..$ type     : chr "history"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Condition
      Error in `valid_choices[[x]]()`:
      ! argument "members" is missing, with no default

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 15
        .. .. ..$ key              : chr "legend"
        .. .. ..$ trigger          : chr "hover"
        .. .. ..$ position         : chr "bottom"
        .. .. ..$ orientation      : chr "horizontal"
        .. .. ..$ layout           : chr "flex"
        .. .. ..$ showTitle        : logi FALSE
        .. .. ..$ titleText        : chr ""
        .. .. ..$ width            : num 240
        .. .. ..$ height           : num 160
        .. .. ..$ itemSpacing      : num 4
        .. .. ..$ rowPadding       : num 10
        .. .. ..$ colPadding       : num 10
        .. .. ..$ itemMarkerSize   : num 16
        .. .. ..$ itemLabelFontSize: num 16
        .. .. ..$ type             : chr "legend"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 7
        .. .. ..$ key     : chr "minimap"
        .. .. ..$ delay   : num 128
        .. .. ..$ padding : num 10
        .. .. ..$ position: chr "right-bottom"
        .. .. ..$ shape   : chr "key"
        .. .. ..$ size    : num [1:2] 240 160
        .. .. ..$ type    : chr "minimap"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 8
        .. .. ..$ key                : chr "snapline"
        .. .. ..$ tolerance          : num 5
        .. .. ..$ offset             : num 20
        .. .. ..$ autoSnap           : logi TRUE
        .. .. ..$ shape              : chr "key"
        .. .. ..$ verticalLineStyle  :List of 1
        .. .. .. ..$ stroke: chr "#1783FF"
        .. .. ..$ horizontalLineStyle:List of 1
        .. .. .. ..$ stroke: chr "#1783FF"
        .. .. ..$ type               : chr "snapline"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Condition
      Error in `valid_choices[[x]]()`:
      ! argument "data" is missing, with no default

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 5
        .. .. ..$ getItems: 'JS_EVAL' chr "( ) => [\n        { id : 'zoom-in' , value : 'zoom-in' },\n        { id : 'zoom-out' , value : 'zoom-out' },\n "| __truncated__
        .. .. ..$ key     : chr "toolbar"
        .. .. ..$ position: chr "top-left"
        .. .. ..$ onClick : 'JS_EVAL' chr "( value, target, current ) => {   \n        // Handle button click events\n        const graph = HTMLWidgets\n "| __truncated__
        .. .. ..$ type    : chr "toolbar"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 7
        .. .. ..$ key      : chr "tooltip"
        .. .. ..$ position : chr "top-right"
        .. .. ..$ enable   : logi TRUE
        .. .. ..$ trigger  : chr "hover"
        .. .. ..$ offset   : num [1:2] 10 10
        .. .. ..$ enterable: logi FALSE
        .. .. ..$ type     : chr "tooltip"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

---

    Code
      str(g6_plugins(g6(), plugin))
    Condition
      Warning in `valid_choices[[x]]()`:
      Neither 'imageURL' nor 'text' is provided; watermark may not be visible
    Output
      List of 8
       $ x            :List of 4
        ..$ data    : Named list()
        ..$ jsonUrl : NULL
        ..$ iconsUrl: chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ plugins :List of 1
        .. ..$ :List of 11
        .. .. ..$ key             : chr "watermark"
        .. .. ..$ width           : num 200
        .. .. ..$ height          : num 100
        .. .. ..$ opacity         : num 0.2
        .. .. ..$ rotate          : num 0.262
        .. .. ..$ textFill        : chr "#000"
        .. .. ..$ textFontSize    : num 16
        .. .. ..$ textAlign       : chr "center"
        .. .. ..$ textBaseline    : chr "alphabetic"
        .. .. ..$ backgroundRepeat: chr "repeat"
        .. .. ..$ type            : chr "watermark"
       $ width        : chr "100%"
       $ height       : NULL
       $ sizingPolicy :List of 7
        ..$ defaultWidth : NULL
        ..$ defaultHeight: NULL
        ..$ padding      : NULL
        ..$ fill         : NULL
        ..$ viewer       :List of 6
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi TRUE
        .. ..$ suppress     : logi FALSE
        .. ..$ paneHeight   : NULL
        ..$ browser      :List of 5
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ padding      : NULL
        .. ..$ fill         : logi FALSE
        .. ..$ external     : logi FALSE
        ..$ knitr        :List of 3
        .. ..$ defaultWidth : NULL
        .. ..$ defaultHeight: NULL
        .. ..$ figure       : logi TRUE
       $ dependencies : NULL
       $ elementId    : NULL
       $ preRenderHook: NULL
       $ jsHooks      : list()
       - attr(*, "class")= chr [1:2] "g6" "htmlwidget"
       - attr(*, "package")= chr "g6R"

