# g6_behaviors creates proper behavior configuration

    Code
      g6_behaviors(g6())
    Condition
      Error in `g6_behaviors()`:
      ! You must provide at least one behavior configuration.

# validate behavior works

    Code
      g6_behaviors(g6(), "blabla")
    Condition
      Error in `validate_component()`:
      ! 'blabla' is not a valid behavior. Valid choices are: auto-adapt-label, brush-select, click-select, collapse-expand, create-edge, drag-canvas, drag-element, drag-element-force, fix-element-size, focus-element, hover-activate, lasso-select, optimize-viewport-transform, scroll-canvas, zoom-canvas.
    Code
      g6_behaviors(g6(), list(test = 1))
    Condition
      Error in `validate_component()`:
      ! 'unknown' is not a valid behavior. Valid choices are: auto-adapt-label, brush-select, click-select, collapse-expand, create-edge, drag-canvas, drag-element, drag-element-force, fix-element-size, focus-element, hover-activate, lasso-select, optimize-viewport-transform, scroll-canvas, zoom-canvas.

# individual behavior functions work correctly

    Code
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 6
        .. .. ..$ key     : chr "auto-adapt-label"
        .. .. ..$ enable  : logi TRUE
        .. .. ..$ throttle: num 100
        .. .. ..$ padding : num 0
        .. .. ..$ sortNode:List of 1
        .. .. .. ..$ type: chr "degree"
        .. .. ..$ type    : chr "auto-adapt-label"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 9
        .. .. ..$ key           : chr "brush-select"
        .. .. ..$ animation     : logi FALSE
        .. .. ..$ enable        : 'JS_EVAL' chr "(e) => {\n      return true;\n    }"
        .. .. ..$ enableElements:List of 1
        .. .. .. ..$ : chr "node"
        .. .. ..$ immediately   : logi FALSE
        .. .. ..$ mode          : chr "default"
        .. .. ..$ state         : chr "selected"
        .. .. ..$ trigger       : chr "shift"
        .. .. ..$ type          : chr "brush-select"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 9
        .. .. ..$ key          : chr "click-select"
        .. .. ..$ animation    : logi TRUE
        .. .. ..$ degree       : num 0
        .. .. ..$ enable       : logi TRUE
        .. .. ..$ multiple     : logi FALSE
        .. .. ..$ state        : chr "selected"
        .. .. ..$ neighborState: chr "selected"
        .. .. ..$ trigger      :List of 1
        .. .. .. ..$ : chr "shift"
        .. .. ..$ type         : chr "click-select"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 6
        .. .. ..$ key      : chr "collapse-expand"
        .. .. ..$ animation: logi TRUE
        .. .. ..$ enable   : logi TRUE
        .. .. ..$ trigger  : chr "dblclick"
        .. .. ..$ align    : logi TRUE
        .. .. ..$ type     : chr "collapse-expand"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 5
        .. .. ..$ key    : chr "create-edge"
        .. .. ..$ trigger: chr "drag"
        .. .. ..$ enable : logi FALSE
        .. .. ..$ notify : logi FALSE
        .. .. ..$ type   : chr "create-edge"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 5
        .. .. ..$ key        : chr "drag-canvas"
        .. .. ..$ enable     : 'JS_EVAL' chr "(e) => {\n        return e.targetType === 'canvas';\n      }"
        .. .. ..$ direction  : chr "both"
        .. .. ..$ sensitivity: num 10
        .. .. ..$ type       : chr "drag-canvas"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 8
        .. .. ..$ key       : chr "drag-element"
        .. .. ..$ enable    : logi TRUE
        .. .. ..$ animation : logi TRUE
        .. .. ..$ state     : chr "selected"
        .. .. ..$ dropEffect: chr "move"
        .. .. ..$ hideEdge  : chr "none"
        .. .. ..$ shadow    : logi FALSE
        .. .. ..$ type      : chr "drag-element"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 6
        .. .. ..$ key     : chr "drag-element-force"
        .. .. ..$ fixed   : logi FALSE
        .. .. ..$ enable  : 'JS_EVAL' chr "(event) => {\n        return ['node', 'combo'].includes(event.targetType);\n      }"
        .. .. ..$ state   : chr "selected"
        .. .. ..$ hideEdge: chr "none"
        .. .. ..$ type    : chr "drag-element-force"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 9
        .. .. ..$ key        : chr "fix-element-size"
        .. .. ..$ enable     : logi TRUE
        .. .. ..$ reset      : logi FALSE
        .. .. ..$ state      : chr ""
        .. .. ..$ nodeFilter : 'JS_EVAL' chr "() => true"
        .. .. ..$ edge       :List of 3
        .. .. .. ..$ :List of 2
        .. .. .. .. ..$ shape : chr "key"
        .. .. .. .. ..$ fields: chr "lineWidth"
        .. .. .. ..$ :List of 2
        .. .. .. .. ..$ shape : chr "halo"
        .. .. .. .. ..$ fields: chr "lineWidth"
        .. .. .. ..$ :List of 2
        .. .. .. .. ..$ shape : chr "label"
        .. .. .. .. ..$ fields: chr "fontSize"
        .. .. ..$ edgeFilter : 'JS_EVAL' chr "() => true"
        .. .. ..$ comboFilter: 'JS_EVAL' chr "() => true"
        .. .. ..$ type       : chr "fix-element-size"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 4
        .. .. ..$ key      : chr "focus-element"
        .. .. ..$ animation:List of 2
        .. .. .. ..$ duration: num 500
        .. .. .. ..$ easing  : chr "ease-in"
        .. .. ..$ enable   : logi TRUE
        .. .. ..$ type     : chr "focus-element"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 7
        .. .. ..$ key      : chr "hover-activate"
        .. .. ..$ animation: logi TRUE
        .. .. ..$ enable   : logi TRUE
        .. .. ..$ degree   : num 0
        .. .. ..$ direction: chr "both"
        .. .. ..$ state    : chr "active"
        .. .. ..$ type     : chr "hover-activate"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 9
        .. .. ..$ key           : chr "lasso-select"
        .. .. ..$ animation     : logi FALSE
        .. .. ..$ enable        : logi TRUE
        .. .. ..$ enableElements:List of 1
        .. .. .. ..$ : chr "node"
        .. .. ..$ immediately   : logi FALSE
        .. .. ..$ mode          : chr "default"
        .. .. ..$ state         : chr "selected"
        .. .. ..$ trigger       : chr "shift"
        .. .. ..$ type          : chr "lasso-select"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 5
        .. .. ..$ key     : chr "optimize-viewport-transform"
        .. .. ..$ enable  : logi TRUE
        .. .. ..$ debounce: num 200
        .. .. ..$ shapes  : 'JS_EVAL' chr "(type) => type === 'node'"
        .. .. ..$ type    : chr "optimize-viewport-transform"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 6
        .. .. ..$ key           : chr "scroll-canvas"
        .. .. ..$ enable        : logi TRUE
        .. .. ..$ range         : num 1
        .. .. ..$ sensitivity   : num 1
        .. .. ..$ preventDefault: logi TRUE
        .. .. ..$ type          : chr "scroll-canvas"
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
      str(g6_behaviors(g6(), behavior))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ behaviors       :List of 1
        .. ..$ :List of 6
        .. .. ..$ key           : chr "zoom-canvas"
        .. .. ..$ animation     :List of 1
        .. .. .. ..$ duration: num 200
        .. .. ..$ enable        : logi TRUE
        .. .. ..$ preventDefault: logi TRUE
        .. .. ..$ sensitivity   : num 1
        .. .. ..$ type          : chr "zoom-canvas"
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

