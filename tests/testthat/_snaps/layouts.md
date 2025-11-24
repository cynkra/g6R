# validate layout works

    Code
      g6_layout(g6(), NULL)
    Condition
      Error in `g6_layout()`:
      ! layout must be specified.
    Code
      g6_layout(g6(), "blabla")
    Condition
      Error in `validate_component()`:
      ! 'blabla' is not a valid layout. Valid choices are: antv-dagre, circular, combo-combined, concentric, d3-force, force-atlas2, fruchterman, radial, compact-box, dendrogram.
    Code
      g6_layout(g6(), list(test = 1))
    Condition
      Error in `validate_component()`:
      ! 'unknown' is not a valid layout. Valid choices are: antv-dagre, circular, combo-combined, concentric, d3-force, force-atlas2, fruchterman, radial, compact-box, dendrogram.

# individual layout functions work correctly

    Code
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 10
        .. ..$ type          : chr "antv-dagre"
        .. ..$ rankdir       : chr "TB"
        .. ..$ align         : chr "UL"
        .. ..$ nodesep       : num 50
        .. ..$ ranksep       : num 100
        .. ..$ ranker        : chr "network-simplex"
        .. ..$ controlPoints : logi FALSE
        .. ..$ sortByCombo   : logi FALSE
        .. ..$ edgeLabelSpace: logi TRUE
        .. ..$ radial        : logi FALSE
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 8
        .. ..$ type       : chr "circular"
        .. ..$ angleRatio : num 1
        .. ..$ clockwise  : logi TRUE
        .. ..$ divisions  : num 1
        .. ..$ nodeSize   : num 10
        .. ..$ nodeSpacing: num 10
        .. ..$ startAngle : num 0
        .. ..$ endAngle   : num 6.28
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 3
        .. ..$ type        : chr "combo-combined"
        .. ..$ comboPadding: num 10
        .. ..$ nodeSize    : num 10
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 8
        .. ..$ type          : chr "concentric"
        .. ..$ clockwise     : logi FALSE
        .. ..$ equidistant   : logi FALSE
        .. ..$ sortBy        : chr "degree"
        .. ..$ nodeSize      : num 30
        .. ..$ nodeSpacing   : num 10
        .. ..$ preventOverlap: logi FALSE
        .. ..$ startAngle    : num 4.71
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 3
        .. ..$ type   : chr "d3-force"
        .. ..$ link   :List of 2
        .. .. ..$ distance: num 100
        .. .. ..$ strength: num 2
        .. ..$ collide:List of 1
        .. .. ..$ radius: num 40
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 9
        .. ..$ type          : chr "force-atlas2"
        .. ..$ dissuadeHubs  : logi FALSE
        .. ..$ kg            : num 1
        .. ..$ kr            : num 5
        .. ..$ ks            : num 0.1
        .. ..$ ksmax         : num 10
        .. ..$ mode          : chr "normal"
        .. ..$ preventOverlap: logi FALSE
        .. ..$ tao           : num 0.1
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 3
        .. ..$ type   : chr "fruchterman"
        .. ..$ gravity: num 10
        .. ..$ speed  : num 5
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 9
        .. ..$ type                      : chr "radial"
        .. ..$ nodeSpacing               : num 10
        .. ..$ linkDistance              : num 50
        .. ..$ unitRadius                : num 100
        .. ..$ maxIteration              : num 1000
        .. ..$ maxPreventOverlapIteration: num 200
        .. ..$ preventOverlap            : logi FALSE
        .. ..$ sortStrength              : num 10
        .. ..$ strictRadial              : logi TRUE
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 3
        .. ..$ type     : chr "compact-box"
        .. ..$ direction: chr "LR"
        .. ..$ radial   : logi FALSE
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
      str(g6_layout(g6(), layout))
    Output
      List of 8
       $ x            :List of 6
        ..$ data            : list()
        .. ..- attr(*, "class")= chr "g6_data"
        ..$ jsonUrl         : NULL
        ..$ iconsUrl        : chr "//at.alicdn.com/t/font_2678727_za4qjydwkkh.js"
        ..$ mode            : chr "prod"
        ..$ preservePosition: logi FALSE
        ..$ layout          :List of 5
        .. ..$ type     : chr "dendrogram"
        .. ..$ direction: chr [1:6] "LR" "RL" "TB" "BT" ...
        .. ..$ nodeSep  : num 20
        .. ..$ rankSep  : num 200
        .. ..$ radial   : logi FALSE
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

