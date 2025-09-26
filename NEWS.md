# g6R 0.2.0

- Fix: state never get set on first render.
- Fix [#23](<https://github.com/cynkra/g6R/issues/23>): graph has to be re-rendered after dynamic plugin addition so that new elements like `hull` are drawn.
- Fix [#22](<https://github.com/cynkra/g6R/issues/22>): internal typo in JS function when an error was caught in the graph.
- Add `input$<graph_ID>-contextmenu` to extract the type and id of element which was clicked in the context menu.
This can be listened to from the Shiny server function.
- Fix layout and behavior issues in some examples: `drag_element_force` only works when `animation` is TRUE. Also added `autoFit = TRUE` wherever required (manual layout vignette).

# g6R 0.1.0

- Initial CRAN submission.
