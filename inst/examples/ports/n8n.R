library(shiny)
library(g6R)

ui <- fluidPage(
  g6_output("dag", height = "800px"),
  icon("gears")
)

server <- function(input, output, session) {
  output$dag <- render_g6(
    g6(
      nodes = g6_nodes(
        # Webhook (left)
        g6_node(
          id = "webhook",
          type = "custom-rect-node",
          style = list(
            labelText = "Webhook",
            x = 100,
            y = 300,
            size = c(50, 50),
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjU2IiBoZWlnaHQ9IjI1NiIgdmlld0JveD0iMCAtOC41IDI1NiAyNTYiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQiPjxwYXRoIGQ9Ik0xMTkuNTQgMTAwLjUwM2MtMTAuNjEgMTcuODM2LTIwLjc3NSAzNS4xMDgtMzEuMTUyIDUyLjI1LTIuNjY1IDQuNDAxLTMuOTg0IDcuOTg2LTEuODU1IDEzLjU4IDUuODc4IDE1LjQ1NC0yLjQxNCAzMC40OTMtMTcuOTk4IDM0LjU3NS0xNC42OTcgMy44NTEtMjkuMDE2LTUuODA4LTMxLjkzMi0yMS41NDMtMi41ODQtMTMuOTI3IDguMjI0LTI3LjU4IDIzLjU4LTI5Ljc1NyAxLjI4Ni0uMTg0IDIuNi0uMjA1IDQuNzYyLS4zNjdsMjMuMzU4LTM5LjE2OEM3My42MTIgOTUuNDY1IDY0Ljg2OCA3OC4zOSA2Ni44MDMgNTcuMjNjMS4zNjgtMTQuOTU3IDcuMjUtMjcuODgzIDE4LTM4LjQ3NyAyMC41OS0yMC4yODggNTIuMDAyLTIzLjU3MyA3Ni4yNDYtOC4wMDEgMjMuMjg0IDE0Ljk1OCAzMy45NDggNDQuMDk0IDI0Ljg1OCA2OS4wMzEtNi44NTQtMS44NTgtMTMuNzU2LTMuNzMyLTIxLjM0My01Ljc5IDIuODU0LTEzLjg2NS43NDMtMjYuMzE1LTguNjA4LTM2Ljk4MS02LjE3OC03LjA0Mi0xNC4xMDYtMTAuNzMzLTIzLjEyLTEyLjA5My0xOC4wNzItMi43My0zNS44MTUgOC44OC00MS4wOCAyNi42MTgtNS45NzYgMjAuMTMgMy4wNjkgMzYuNTc1IDI3Ljc4NCA0OC45NjciIGZpbGw9IiNjNzNhNjMiLz48cGF0aCBkPSJNMTQ5Ljg0MSA3OS40MWM3LjQ3NSAxMy4xODcgMTUuMDY1IDI2LjU3MyAyMi41ODcgMzkuODM2IDM4LjAyLTExLjc2MyA2Ni42ODYgOS4yODQgNzYuOTcgMzEuODE3IDEyLjQyMiAyNy4yMTkgMy45MyA1OS40NTctMjAuNDY1IDc2LjI1LTI1LjA0IDE3LjIzOC01Ni43MDcgMTQuMjkzLTc4Ljg5Mi03Ljg1MSA1LjY1NC00LjczMyAxMS4zMzYtOS40ODcgMTcuNDA3LTE0LjU2NiAyMS45MTIgMTQuMTkyIDQxLjA3NyAxMy41MjQgNTUuMzA1LTMuMjgyIDEyLjEzMy0xNC4zMzcgMTEuODctMzUuNzE0LS42MTUtNDkuNzUtMTQuNDA4LTE2LjE5Ny0zMy43MDctMTYuNjkxLTU3LjAzNS0xLjE0My05LjY3Ny0xNy4xNjgtMTkuNTIyLTM0LjE5OS0yOC44OTMtNTEuNDkxLTMuMTYtNS44MjgtNi42NDgtOS4yMS0xMy43Ny0xMC40NDMtMTEuODkzLTIuMDYyLTE5LjU3MS0xMi4yNzUtMjAuMDMyLTIzLjcxNy0uNDUzLTExLjMxNiA2LjIxNC0yMS41NDUgMTYuNjM0LTI1LjUzIDEwLjMyMi0zLjk0OSAyMi40MzUtLjc2MiAyOS4zNzggOC4wMTQgNS42NzQgNy4xNyA3LjQ3NyAxNS4yNCA0LjQ5MSAyNC4wODMtLjgzIDIuNDY2LTEuOTA1IDQuODUyLTMuMDcgNy43NzQiIGZpbGw9IiM0YjRiNGIiLz48cGF0aCBkPSJNMTY3LjcwNyAxODcuMjFoLTQ1Ljc3Yy00LjM4NyAxOC4wNDQtMTMuODYzIDMyLjYxMi0zMC4xOSA0MS44NzYtMTIuNjkzIDcuMi0yNi4zNzMgOS42NDEtNDAuOTMzIDcuMjktMjYuODA4LTQuMzIzLTQ4LjcyOC0yOC40NTYtNTAuNjU4LTU1LjYzLTIuMTg0LTMwLjc4NCAxOC45NzUtNTguMTQ3IDQ3LjE3OC02NC4yOTMgMS45NDcgNy4wNzEgMy45MTUgMTQuMjEgNS44NjIgMjEuMjY0LTI1Ljg3NiAxMy4yMDItMzQuODMyIDI5LjgzNi0yNy41OSA1MC42MzYgNi4zNzUgMTguMzA0IDI0LjQ4NCAyOC4zMzcgNDQuMTQ3IDI0LjQ1NyAyMC4wOC0zLjk2MiAzMC4yMDQtMjAuNjUgMjguOTY4LTQ3LjQzMiAxOS4wMzYgMCAzOC4wODgtLjE5NyA1Ny4xMjYuMDk3IDcuNDM0LjExNyAxMy4xNzMtLjY1NCAxOC43NzMtNy4yMDggOS4yMi0xMC43ODQgMjYuMTkxLTkuODExIDM2LjEyMS4zNzQgMTAuMTQ4IDEwLjQwOSA5LjY2MiAyNy4xNTctMS4wNzcgMzcuMTI3LTEwLjM2MSA5LjYyLTI2LjczIDkuMTA2LTM2LjQyNC0xLjI2LTEuOTkyLTIuMTM2LTMuNTYyLTQuNjczLTUuNTMzLTcuMjk4IiBmaWxsPSIjNGE0YTRhIi8+PC9zdmc+",
            iconWidth = 20,
            iconHeight = 20,
            radius = 8
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "right")
          )
        ),
        # AI Agent (center)
        g6_node(
          id = "ai_agent",
          type = "custom-rect-node",
          style = list(
            labelText = "AI Agent\nTools Agent\n",
            labelPlacement = "top",
            size = c(150, 100),
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDM2IDM2IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGFyaWEtaGlkZGVuPSJ0cnVlIiBjbGFzcz0iaWNvbmlmeSBpY29uaWZ5LS10d2Vtb2ppIj48ZWxsaXBzZSBmaWxsPSIjZjQ5MDBjIiBjeD0iMzMuNSIgY3k9IjE0LjUiIHJ4PSIyLjUiIHJ5PSIzLjUiLz48ZWxsaXBzZSBmaWxsPSIjZjQ5MDBjIiBjeD0iMi41IiBjeT0iMTQuNSIgcng9IjIuNSIgcnk9IjMuNSIvPjxwYXRoIGZpbGw9IiNmZmFjMzMiIGQ9Ik0zNCAxOWExIDEgMCAwIDEtMSAxaC0zYTEgMSAwIDAgMS0xLTF2LTlhMSAxIDAgMCAxIDEtMWgzYTEgMSAwIDAgMSAxIDF6TTcgMTlhMSAxIDAgMCAxLTEgMUgzYTEgMSAwIDAgMS0xLTF2LTlhMSAxIDAgMCAxIDEtMWgzYTEgMSAwIDAgMSAxIDF6Ii8+PHBhdGggZmlsbD0iI2ZmY2M0ZCIgZD0iTTI4IDVjMCAyLjc2MS00LjQ3OCA0LTEwIDRTOCA3Ljc2MSA4IDVzNC40NzctNSAxMC01IDEwIDIuMjM5IDEwIDUiLz48cGF0aCBmaWxsPSIjZjQ5MDBjIiBkPSJNMjUgNC4wODNDMjUgNS42OTQgMjEuODY1IDcgMTggN3MtNy0xLjMwNi03LTIuOTE3IDMuMTM0LTIuOTE3IDctMi45MTcgNyAxLjMwNiA3IDIuOTE3Ii8+PHBhdGggZmlsbD0iIzI2OSIgZD0iTTMwIDUuNUMzMCA2Ljg4MSAyOC44ODEgNyAyNy41IDdoLTE5QzcuMTE5IDcgNiA2Ljg4MSA2IDUuNVM3LjExOSAzIDguNSAzaDE5QTIuNSAyLjUgMCAwIDEgMzAgNS41Ii8+PHBhdGggZmlsbD0iIzU1YWNlZSIgZD0iTTMwIDZINmEyIDIgMCAwIDAtMiAydjI2aDI4VjhhMiAyIDAgMCAwLTItMiIvPjxwYXRoIGZpbGw9IiMzYjg4YzMiIGQ9Ik0zNSAzM3YtMWEyIDIgMCAwIDAtMi0ySDIyLjA3MWwtMy4zNjQgMy4zNjRhMSAxIDAgMCAxLTEuNDE0IDBMMTMuOTI5IDMwSDNhMiAyIDAgMCAwLTIgMnYxYzAgMS4xMDQtLjEwNCAyIDEgMmgzMmMxLjEwNCAwIDEtLjg5NiAxLTIiLz48Y2lyY2xlIGZpbGw9IiNmZmYiIGN4PSIyNC41IiBjeT0iMTQuNSIgcj0iNC41Ii8+PGNpcmNsZSBmaWxsPSIjZGQyZTQ0IiBjeD0iMjQuNSIgY3k9IjE0LjUiIHI9IjIuNzIxIi8+PGNpcmNsZSBmaWxsPSIjZmZmIiBjeD0iMTEuNSIgY3k9IjE0LjUiIHI9IjQuNSIvPjxwYXRoIGZpbGw9IiNmNWY4ZmEiIGQ9Ik0yOSAyNS41YTIuNSAyLjUgMCAwIDEtMi41IDIuNWgtMTdhMi41IDIuNSAwIDEgMSAwLTVoMTdhMi41IDIuNSAwIDAgMSAyLjUgMi41Ii8+PHBhdGggZmlsbD0iI2NjZDZkZCIgZD0iTTE3IDIzaDJ2NWgtMnptLTUgMGgydjVoLTJ6bTEwIDBoMnY1aC0yek03IDI1LjVhMi41IDIuNSAwIDAgMCAyIDIuNDV2LTQuOWEyLjUgMi41IDAgMCAwLTIgMi40NW0yMC0yLjQ1djQuODk5YTIuNSAyLjUgMCAwIDAgMC00Ljg5OSIvPjxjaXJjbGUgZmlsbD0iI2RkMmU0NCIgY3g9IjExLjUiIGN5PSIxNC41IiByPSIyLjcyMSIvPjwvc3ZnPg==",
            iconWidth = 40,
            iconHeight = 40,
            x = 320,
            y = 300,
            radius = 8
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out", placement = "right"),
            g6_input_port(
              key = "down1",
              label = "chat model",
              placement = c(0.15, 1)
            ),
            g6_input_port(
              key = "down2",
              label = "mode memory",
              placement = c(0.32, 1)
            ),
            g6_input_port(
              key = "down3",
              label = "tool",
              arity = 3,
              placement = c(0.49, 1)
            ),
            g6_input_port(
              key = "down4",
              label = "output parser",
              placement = c(0.66, 1)
            )
          )
        ),
        # Switch (right of AI Agent)
        g6_node(
          id = "switch",
          type = "custom-rect-node",
          style = list(
            labelText = "Switch \n mode: rules",
            size = c(50, 50),
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBhdGggc3R5bGU9ImZpbGw6bm9uZTtzdHJva2U6IzM4NDU0ZjtzdHJva2Utd2lkdGg6MjtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbWl0ZXJsaW1pdDoxMCIgZD0iTTI4LjY2NCA0VjFtMCA1OFY0MG0wLTIwdjQiLz48cGF0aCBzdHlsZT0iZmlsbDojMjNhMjRkIiBkPSJNNDguNTUzIDIwSDEwLjA2MWEyLjM5NyAyLjM5NyAwIDAgMS0yLjM5Ny0yLjM5N1Y2LjM5N0EyLjM5NyAyLjM5NyAwIDAgMSAxMC4wNjEgNGgzOC40OTJsOC43MTEgNy44NGEuMjE0LjIxNCAwIDAgMSAwIC4zMTl6Ii8+PHBhdGggc3R5bGU9ImZpbGw6I2ViYmExNiIgZD0iTTExLjQ0NyA0MGgzOC44MjFhMi4zOTcgMi4zOTcgMCAwIDAgMi4zOTctMi4zOTdWMjYuMzk3QTIuMzk3IDIuMzk3IDAgMCAwIDUwLjI2OCAyNEgxMS40NDdsLTguNzExIDcuODRhLjIxNC4yMTQgMCAwIDAgMCAuMzE5eiIvPjwvc3ZnPg==",
            iconWidth = 30,
            iconHeight = 30,
            x = 520,
            y = 300,
            radius = 8
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "get", placement = c(1, 0.2)),
            g6_output_port(key = "post", placement = c(1, 0.5)),
            g6_output_port(key = "delete", placement = c(1, 0.8))
          )
        ),
        # Right-side rectangular nodes (top to bottom)
        g6_node(
          id = "get_properties",
          type = "custom-rect-node",
          style = list(
            labelText = "Get properties",
            x = 700,
            y = 180,
            size = c(50, 50),
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20,
            radius = 8
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out", placement = "right")
          )
        ),
        g6_node(
          id = "structure_response",
          type = "custom-rect-node",
          style = list(
            labelText = "Structure Response",
            x = 900,
            y = 180,
            size = c(50, 50),
            radius = 8,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIgNTEyIiB4bWw6c3BhY2U9InByZXNlcnZlIj48cGF0aCBzdHlsZT0iZmlsbDojNmRjODJhIiBkPSJNNDk1LjMwNCA1MTJIMTYuNjk2QzcuNDc5IDUxMiAwIDUwNC41MjcgMCA0OTUuMzA0VjE2LjY5NkMwIDcuNDczIDcuNDc5IDAgMTYuNjk2IDBoNDc4LjYwOUM1MDQuNTIxIDAgNTEyIDcuNDczIDUxMiAxNi42OTZ2NDc4LjYwOWMwIDkuMjIyLTcuNDc5IDE2LjY5NS0xNi42OTYgMTYuNjk1Ii8+PHBhdGggc3R5bGU9ImZpbGw6IzYxYjMyNSIgZD0iTTQ5NS4zMDQgMEgyNTZ2NTEyaDIzOS4zMDRjOS4yMTcgMCAxNi42OTYtNy40NzMgMTYuNjk2LTE2LjY5NlYxNi42OTZDNTEyIDcuNDczIDUwNC41MjEgMCA0OTUuMzA0IDAiLz48cGF0aCBzdHlsZT0iZmlsbDojZmZmIiBkPSJNMTgzLjY1MiA0NDUuMjE3SDExNi44N2MtOS4yMTcgMC0xNi42OTYtNy40NzMtMTYuNjk2LTE2LjY5NlY4My40NzhjMC05LjIyMyA3LjQ3OS0xNi42OTYgMTYuNjk2LTE2LjY5Nmg2Ni43ODNjOS4yMTcgMCAxNi42OTYgNy40NzMgMTYuNjk2IDE2LjY5NnMtNy40NzkgMTYuNjk2LTE2LjY5NiAxNi42OTZoLTUwLjA4N3YzMTEuNjUyaDUwLjA4N2M5LjIxNyAwIDE2LjY5NiA3LjQ3MyAxNi42OTYgMTYuNjk2cy03LjQ4IDE2LjY5NS0xNi42OTcgMTYuNjk1Ii8+PHBhdGggc3R5bGU9ImZpbGw6I2ZmZTZiMyIgZD0iTTM5NS4xMyA0NDUuMjE3aC02Ni43ODNjLTkuMjE3IDAtMTYuNjk2LTcuNDczLTE2LjY5Ni0xNi42OTZzNy40NzktMTYuNjk2IDE2LjY5Ni0xNi42OTZoNTAuMDg3VjEwMC4xNzRoLTUwLjA4N2MtOS4yMTcgMC0xNi42OTYtNy40NzMtMTYuNjk2LTE2LjY5NnM3LjQ3OS0xNi42OTYgMTYuNjk2LTE2LjY5Nmg2Ni43ODNjOS4yMTcgMCAxNi42OTYgNy40NzMgMTYuNjk2IDE2LjY5NnYzNDUuMDQzYzAgOS4yMjMtNy40NzggMTYuNjk2LTE2LjY5NiAxNi42OTYiLz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out", placement = "right")
          )
        ),
        g6_node(
          id = "post_url",
          type = "custom-rect-node",
          style = list(
            labelText = "Post URL",
            x = 700,
            y = 300,
            size = c(50, 50),
            radius = 8,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out", placement = "right")
          )
        ),
        g6_node(
          id = "delete_return",
          type = "custom-rect-node",
          style = list(
            labelText = "Delete/Return",
            x = 700,
            y = 420,
            size = c(50, 50),
            radius = 8,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBhdGggc3R5bGU9ImZpbGw6bm9uZTtzdHJva2U6IzM4NDU0ZjtzdHJva2Utd2lkdGg6MjtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbWl0ZXJsaW1pdDoxMCIgZD0iTTI4LjY2NCA0VjFtMCA1OFY0MG0wLTIwdjQiLz48cGF0aCBzdHlsZT0iZmlsbDojMjNhMjRkIiBkPSJNNDguNTUzIDIwSDEwLjA2MWEyLjM5NyAyLjM5NyAwIDAgMS0yLjM5Ny0yLjM5N1Y2LjM5N0EyLjM5NyAyLjM5NyAwIDAgMSAxMC4wNjEgNGgzOC40OTJsOC43MTEgNy44NGEuMjE0LjIxNCAwIDAgMSAwIC4zMTl6Ii8+PHBhdGggc3R5bGU9ImZpbGw6I2ViYmExNiIgZD0iTTExLjQ0NyA0MGgzOC44MjFhMi4zOTcgMi4zOTcgMCAwIDAgMi4zOTctMi4zOTdWMjYuMzk3QTIuMzk3IDIuMzk3IDAgMCAwIDUwLjI2OCAyNEgxMS40NDdsLTguNzExIDcuODRhLjIxNC4yMTQgMCAwIDAgMCAuMzE5eiIvPjwvc3ZnPg==",
            iconWidth = 30,
            iconHeight = 30
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out1", placement = c(1, 0.3)),
            g6_output_port(key = "out2", placement = c(1, 0.7))
          )
        ),
        g6_node(
          id = "delete_url",
          type = "custom-rect-node",
          style = list(
            labelText = "Delete URL",
            x = 900,
            y = 380,
            size = c(50, 50),
            radius = 8,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out", placement = "right")
          )
        ),
        g6_node(
          id = "return_output",
          type = "custom-rect-node",
          style = list(
            labelText = "Return output",
            x = 900,
            y = 480,
            size = c(50, 50),
            radius = 8,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_input_port(key = "in", placement = "left"),
            g6_output_port(key = "out", placement = "right")
          )
        ),
        # Bottom circle nodes (left to right, spaced out)
        g6_node(
          id = "google_gemini",
          type = "custom-circle-node",
          style = list(
            labelText = "Google Gemini\nChat Model",
            x = 160,
            y = 520,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMiAzMiIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHBhdGggZD0iTTguOSAxNmMwIC42LjEgMS4yLjIgMS44TDExIDE2bC0xLjgtMS44cS0uMy45LS4zIDEuOCIgc3R5bGU9ImZpbGw6bm9uZSIvPjxwYXRoIGQ9Ik0xNiAyMy4xYy0zLjMgMC02LTIuMi02LjgtNS4ybC02LjcgNi43QzUuMyAyOSAxMC4zIDMyIDE2IDMyYzMuMSAwIDYtLjkgOC41LTIuNWwtNi43LTYuN3EtLjkuMy0xLjguMyIgc3R5bGU9ImZpbGw6IzM0YTg1MyIvPjxwYXRoIGQ9Ik0zMiAxMy44Yy0uMS0uNS0uNS0uOC0xLS44SDE2Yy0uNiAwLTEgLjQtMSAxdjVjMCAuNi40IDEgMSAxaDUuM2MtLjkgMS40LTIuMiAyLjMtMy41IDIuOGw2LjcgNi43QzI5IDI2LjcgMzIgMjEuNyAzMiAxNnYtLjdxLjE1LS42IDAtMS41IiBzdHlsZT0iZmlsbDojNDI4NWY0Ii8+PHBhdGggZD0iTTguOSAxNmMwLS42LjEtMS4yLjItMS44TDIuNSA3LjVDLjkgMTAgMCAxMi45IDAgMTZzLjkgNiAyLjUgOC41bDYuNy02LjdxLS4zLS45LS4zLTEuOCIgc3R5bGU9ImZpbGw6I2ZiYmMwNSIvPjxwYXRoIGQ9Ik0yOC41IDZjLTEuMS0xLjQtMi41LTIuNi00LTMuNkMyMiAuOSAxOS4xIDAgMTYgMCAxMC4zIDAgNS4zIDMgMi41IDcuNWw2LjcgNi43QzEwIDExLjIgMTIuOCA5IDE2IDlxLjkgMCAxLjguM2MuOS4zIDEuNy44IDIuNiAxLjUuMy4zLjcuMyAxLjEuMWw2LjctMy4zYy4zLS4xLjUtLjQuNS0uNy4xLS4zIDAtLjYtLjItLjkiIHN0eWxlPSJmaWxsOiNlYTQzMzUiLz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top")
          )
        ),
        g6_node(
          id = "proxmox_api_doc",
          type = "custom-circle-node",
          style = list(
            labelText = "Proxmox API\nDocumentation",
            x = 250,
            y = 600,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top")
          )
        ),
        g6_node(
          id = "proxmox_api_wiki",
          type = "custom-circle-node",
          style = list(
            labelText = "Proxmox API\nWiki",
            x = 340,
            y = 600,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top")
          )
        ),
        g6_node(
          id = "proxmox",
          type = "custom-circle-node",
          style = list(
            labelText = "Proxmox",
            x = 430,
            y = 520,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHJhZGlhbEdyYWRpZW50IGlkPSJhIiBjeD0iNTAlIiBjeT0iNTAlIiBmeD0iNTAlIiBmeT0iNTAlIiByPSI1MCUiPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiM2NzliY2I7c3RvcC1vcGFjaXR5Oi43NSIgb2Zmc2V0PSIwJSIvPjxzdG9wIHN0eWxlPSJzdG9wLWNvbG9yOiMxMjMxNDE7c3RvcC1vcGFjaXR5OjEiIG9mZnNldD0iMTAwJSIvPjwvcmFkaWFsR3JhZGllbnQ+PC9kZWZzPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDYiIHJ5PSI0NCIgc3R5bGU9InN0cm9rZS13aWR0aDo0O3N0cm9rZTojZGRkO2ZpbGw6bm9uZSIvPjxlbGxpcHNlIGN4PSI1MCIgY3k9IjUwIiByeD0iNDciIHJ5PSI0NCIgc3R5bGU9ImZpbGw6dXJsKCNhKSIvPjxnIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiNhYWE7c3Ryb2tlLXdpZHRoOjEuNXB4O3N0cm9rZS1saW5lY2FwOmJ1dHQiPjxwYXRoIGQ9Ik01MCA5NGMtMTAtNC0yOC0xOC0yOC00NCAwLTI5IDE4LTM4IDI4LTQ0djg4czI5LTEwIDI4LTQ1UzUwIDYgNTAgNk00IDUwaDkyIi8+PHBhdGggZD0iTTE3IDIwczEyIDEyIDMzIDEyYzIyIDAgMzQtMTIgMzQtMTJNMTQgNzhzMTMtMTEgMzYtMTFjMjUgMCAzNiAxMSAzNiAxMSIvPjwvZz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top")
          )
        ),
        g6_node(
          id = "auto_fixing_parser",
          type = "custom-rect-node",
          style = list(
            labelText = "Auto-fixing\nOutput Parser",
            labelPlacement = "right",
            size = c(100, 50),
            x = 520,
            y = 600,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA2NCA2NCIgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+PHN0eWxlPi5zdDF7b3BhY2l0eTouMn0uc3Qye2ZpbGw6IzIzMWYyMH0uc3Qze2ZpbGw6IzRmNWQ3M30uc3Q1e2ZpbGw6I2ZmZn08L3N0eWxlPjxnIGlkPSJMYXllcl8xIj48Y2lyY2xlIGN4PSIzMiIgY3k9IjMyIiByPSIzMiIgc3R5bGU9ImZpbGw6Izc2YzJhZiIvPjxnIGNsYXNzPSJzdDEiPjxwYXRoIGNsYXNzPSJzdDIiIGQ9Ik00OS45IDQ2LjIgMzUuOCAzMi4xYy0xLTEtMi41LTEuNC0zLjgtMWwtOC4xLTgtMy01LjktNS45LTMtMi45IDIuOCAzIDUuOSA1LjkgMyA4LjEgOGMtLjQgMS4zIDAgMi44IDEgMy44bDE0LjEgMTQuMWMxLjYgMS42IDQuMSAxLjYgNS43IDAgMS42LTEuNSAxLjYtNCAwLTUuNiIvPjwvZz48cGF0aCBjbGFzcz0ic3QzIiBkPSJNMzQuNSAzNy4zIDE4LjQgMjEuNGwyLjktMi44IDE2LjEgMTUuOXoiLz48cGF0aCBkPSJNNDkuOSA0OS45Yy0xLjYgMS42LTQuMSAxLjYtNS43IDBMMzAuMSAzNS44Yy0xLjYtMS42LTEuNi00LjEgMC01LjdzNC4xLTEuNiA1LjcgMGwxNC4xIDE0LjFjMS42IDEuNiAxLjYgNC4xIDAgNS43IiBzdHlsZT0iZmlsbDojZjVjZjg3Ii8+PGcgY2xhc3M9InN0MSI+PHBhdGggY2xhc3M9InN0MiIgZD0ibTUzLjMgMTguNC02LjUgNi41Yy0xLjYgMS42LTQuMSAxLjYtNS43IDBzLTEuNi00LjEgMC01LjdsNi41LTYuNWMtMS4xLS40LTIuMy0uNy0zLjYtLjctNS41IDAtMTAgNC41LTEwIDEwIDAgMS4zLjMgMi41LjcgMy42bC0xMSAxMWMtMS4yLS4zLTIuNC0uNi0zLjctLjYtNS41IDAtMTAgNC41LTEwIDEwIDAgMS4zLjMgMi41LjcgMy42bDYuNS02LjVjMS42LTEuNiA0LjEtMS42IDUuNyAwczEuNiA0LjEgMCA1LjdsLTYuNSA2LjVjMS4xLjQgMi40LjcgMy42LjcgNS41IDAgMTAtNC41IDEwLTEwIDAtMS4zLS4zLTIuNS0uNy0zLjZsMTEtMTFjMS4xLjQgMi40LjcgMy42LjcgNS41IDAgMTAtNC41IDEwLTEwIC4xLTEuNC0uMi0yLjYtLjYtMy43Ii8+PC9nPjxwYXRoIGNsYXNzPSJzdDUiIGQ9Ik0yMy4wOSAzNS4yNTMgMzUuMTgyIDIzLjE2bDUuNjU3IDUuNjU3TDI4Ljc0NyA0MC45MXoiLz48cGF0aCBjbGFzcz0ic3QzIiBkPSJtMjEgMjMuOS01LjktMy0zLTUuOSAyLjgtMi45IDUuOSAzLjEgMy4xIDUuOXoiLz48cGF0aCBjbGFzcz0ic3Q1IiBkPSJNNDYuOCAyMi44Yy0xLjYgMS42LTQuMSAxLjYtNS43IDBzLTEuNi00LjEgMC01LjdsNi41LTYuNWMtMS4xLS4zLTIuMy0uNi0zLjYtLjYtNS41IDAtMTAgNC41LTEwIDEwczQuNSAxMCAxMCAxMCAxMC00LjUgMTAtMTBjMC0xLjMtLjMtMi41LS43LTMuNnpNMTcuMiA0MS4yYzEuNi0xLjYgNC4xLTEuNiA1LjcgMHMxLjYgNC4xIDAgNS43bC02LjUgNi41YzEuMS40IDIuNC43IDMuNi43IDUuNSAwIDEwLTQuNSAxMC0xMHMtNC41LTEwLTEwLTEwLTEwIDQuNS0xMCAxMGMwIDEuMy4zIDIuNS43IDMuNnoiLz48L2c+PGcgaWQ9IkxheWVyXzIiLz48L3N2Zz4=",
            iconWidth = 30,
            iconHeight = 30,
            radius = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top"),
            g6_input_port(key = "in1", placement = c(0.7, 1)),
            g6_input_port(key = "in2", placement = c(0.4, 1))
          )
        ),
        g6_node(
          id = "groq_chat_model",
          type = "custom-circle-node",
          style = list(
            labelText = "Groq Chat\nModel",
            x = 610,
            y = 750,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODAwIiBoZWlnaHQ9IjgwMCIgdmlld0JveD0iMCAwIDY0IDY0IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxkZWZzPjxzdHlsZT4uY2xzLTR7ZmlsbDojNTQ1OTZlfS5jbHMtNXtmaWxsOiM2MWM1YTh9PC9zdHlsZT48L2RlZnM+PHRpdGxlPmNoYXQ8L3RpdGxlPjxnIGlkPSJjaGF0Ij48cGF0aCBkPSJNMzUgOEMyMC4wOSA4IDggMTcuNCA4IDI5YzAgNi4zOSAzLjY4IDEyLjExIDkuNDcgMTZMMTUgNTNsOC4yNi01LjA4QTMzLjUgMzMuNSAwIDAgMCAzNSA1MGMxNC45MSAwIDI3LTkuNCAyNy0yMVM0OS45MSA4IDM1IDgiIHN0eWxlPSJmaWxsOiNmOTk7c3Ryb2tlOiM1NDU5NmU7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDoycHgiLz48cGF0aCBkPSJNMjkgMTJDMTQuMDkgMTIgMiAyMS40IDIgMzNjMCA2LjM5IDMuNjggMTIuMTEgOS40NyAxNkw5IDU3bDguMjYtNS4wOEEzMy41IDMzLjUgMCAwIDAgMjkgNTRjMTQuOTEgMCAyNy05LjQgMjctMjFTNDMuOTEgMTIgMjkgMTIiIHN0eWxlPSJzdHJva2U6IzU0NTk2ZTtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLXdpZHRoOjJweDtmaWxsOiM5YWY0M2IiLz48cGF0aCBjbGFzcz0iY2xzLTQiIGQ9Ik0xMC44MSA1MS4xMSA5IDU3bDcuMjgtNC40OGEzMyAzMyAwIDAgMS01LjQ3LTEuNDFNMzAuMzQgMTJDNDEuMTcgMTQuNzYgNDkgMjIuNjcgNDkgMzJjMCAxMS42LTEyLjA5IDIxLTI3IDIxaC0xLjM0QTM0LjMgMzQuMyAwIDAgMCAyOSA1NGMxNC45MSAwIDI3LTkuNCAyNy0yMSAwLTExLjI1LTExLjM3LTIwLjQzLTI1LjY2LTIxIiBzdHlsZT0ib3BhY2l0eTouMSIvPjxjaXJjbGUgY2xhc3M9ImNscy00IiBjeD0iMzEiIGN5PSIyNyIgcj0iMiIvPjxjaXJjbGUgY2xhc3M9ImNscy00IiBjeD0iMTQiIGN5PSIyNyIgcj0iMiIvPjxjaXJjbGUgY2xhc3M9ImNscy01IiBjeD0iMzEiIGN5PSIzMiIgcj0iMiIvPjxjaXJjbGUgY2xhc3M9ImNscy01IiBjeD0iMTQiIGN5PSIzMiIgcj0iMiIvPjxlbGxpcHNlIGNsYXNzPSJjbHMtNCIgY3g9IjIyIiBjeT0iMzYiIHJ4PSI0IiByeT0iNSIvPjxlbGxpcHNlIGN4PSIyMiIgY3k9IjM5IiByeD0iMiIgcnk9IjEiIHN0eWxlPSJmaWxsOiNmZjkyN2QiLz48L2c+PC9zdmc+",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top")
          )
        ),
        g6_node(
          id = "structured_output_parser",
          type = "custom-circle-node",
          style = list(
            labelText = "Structured\nOutput Parser",
            x = 450,
            y = 750,
            iconSrc = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI4MDAiIGhlaWdodD0iODAwIiB2aWV3Qm94PSIwIDAgMzIgMzIiIHhtbDpzcGFjZT0icHJlc2VydmUiPjxwYXRoIGQ9Ik0yOSAzMkgzYTMgMyAwIDAgMS0zLTNWM2EzIDMgMCAwIDEgMy0zaDI2YTMgMyAwIDAgMSAzIDN2MjZhMyAzIDAgMCAxLTMgMyIgc3R5bGU9ImZpbGw6I2YyYzk5ZSIvPjxwYXRoIGQ9Ik0yNyAzMkgzYTMgMyAwIDAgMS0zLTNWM2EzIDMgMCAwIDEgMy0zaDI0YTMgMyAwIDAgMSAzIDN2MjZhMyAzIDAgMCAxLTMgMyIgc3R5bGU9ImZpbGw6I2Y5ZTBiZCIvPjxwYXRoIGQ9Ik0yOCAzdjE3YTEgMSAwIDAgMS0xIDFIM2ExIDEgMCAwIDEtMS0xVjNhMSAxIDAgMCAxIDEtMWgyNGExIDEgMCAwIDEgMSAxbS0xIDIxSDE2YTEgMSAwIDAgMCAwIDJoMTFhMSAxIDAgMCAwIDAtMm0tMTQgMGExIDEgMCAxIDAgMCAyIDEgMSAwIDAgMCAwLTIiIHN0eWxlPSJmaWxsOiM2NzYyNWQiLz48cGF0aCBkPSJNOS41IDhoLTNhLjUuNSAwIDAgMSAwLTFoM2EuNS41IDAgMCAxIDAgMW0uNSAxLjVhLjUuNSAwIDAgMC0uNS0uNWgtM2EuNS41IDAgMCAwIDAgMWgzYS41LjUgMCAwIDAgLjUtLjVtMCAyYS41LjUgMCAwIDAtLjUtLjVoLTNhLjUuNSAwIDAgMCAwIDFoM2EuNS41IDAgMCAwIC41LS41bTAgMmEuNS41IDAgMCAwLS41LS41aC0zYS41LjUgMCAwIDAgMCAxaDNhLjUuNSAwIDAgMCAuNS0uNSIgc3R5bGU9ImZpbGw6I2U2OWQ4YSIvPjxwYXRoIGQ9Ik0yNC41IDE2aC0xN2EuNS41IDAgMCAxIDAtMWgxN2EuNS41IDAgMCAxIDAgMU0yMyAxMy41YS41LjUgMCAwIDAtLjUtLjVoLTExYS41LjUgMCAwIDAgMCAxaDExYS41LjUgMCAwIDAgLjUtLjUiIHN0eWxlPSJmaWxsOiM5OGQzYmMiLz48cGF0aCBkPSJNNi41IDZoLTFhLjUuNSAwIDAgMSAwLTFoMWEuNS41IDAgMCAxIDAgMU0yNSA3LjVhLjUuNSAwIDAgMC0uNS0uNWgtMTNhLjUuNSAwIDAgMCAwIDFoMTNhLjUuNSAwIDAgMCAuNS0uNW0tMiAyYS41LjUgMCAwIDAtLjUtLjVoLTExYS41LjUgMCAwIDAgMCAxaDExYS41LjUgMCAwIDAgLjUtLjVtMiAyYS41LjUgMCAwIDAtLjUtLjVoLTEzYS41LjUgMCAwIDAgMCAxaDEzYS41LjUgMCAwIDAgLjUtLjVtLTE4IDZhLjUuNSAwIDAgMC0uNS0uNWgtMWEuNS41IDAgMCAwIDAgMWgxYS41LjUgMCAwIDAgLjUtLjUiIHN0eWxlPSJmaWxsOiNmZmYyZGYiLz48L3N2Zz4=",
            iconWidth = 20,
            iconHeight = 20
          ),
          ports = g6_ports(
            g6_output_port(key = "out", placement = "top")
          )
        )
      ),
      edges = g6_edges(
        # Main flow
        g6_edge(
          source = "webhook",
          target = "ai_agent",
          style = list(
            sourcePort = "out",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect",
            labelText = "GET",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          source = "ai_agent",
          target = "switch",
          style = list(
            sourcePort = "out",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect"
          )
        ),
        # Switch to right-side nodes
        g6_edge(
          type = "cubic",
          source = "switch",
          target = "get_properties",
          style = list(
            sourcePort = "get",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect",
            labelText = "GET",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          source = "get_properties",
          target = "structure_response",
          style = list(
            sourcePort = "out",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect"
          )
        ),
        g6_edge(
          source = "switch",
          target = "post_url",
          style = list(
            sourcePort = "post",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect",
            labelText = "POST",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "switch",
          target = "delete_return",
          style = list(
            sourcePort = "delete",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect",
            labelText = "DELETE",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "delete_return",
          target = "delete_url",
          style = list(
            sourcePort = "out1",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect",
            labelText = "true",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "delete_return",
          target = "return_output",
          style = list(
            sourcePort = "out2",
            targetPort = "in",
            endArrow = TRUE,
            stroke = "#c1c2cb",
            lineWidth = 1,
            endArrowType = "triangleRect",
            labelText = "false",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        # AI Agent downward edges (cubic/curved)
        g6_edge(
          source = "google_gemini",
          target = "ai_agent",
          style = list(
            type = "cubic",
            sourcePort = "out",
            targetPort = "down1",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "chat model",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "proxmox_api_doc",
          target = "ai_agent",
          style = list(
            sourcePort = "out",
            targetPort = "down3",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "tool",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "proxmox_api_wiki",
          target = "ai_agent",
          style = list(
            sourcePort = "out",
            targetPort = "down3",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "tool",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "proxmox",
          target = "ai_agent",
          style = list(
            sourcePort = "out",
            targetPort = "down3",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "tool",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "auto_fixing_parser",
          target = "ai_agent",
          style = list(
            sourcePort = "out",
            targetPort = "down4",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "output parser",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        # Output parser edges
        g6_edge(
          type = "cubic",
          source = "groq_chat_model",
          target = "auto_fixing_parser",
          style = list(
            sourcePort = "out",
            targetPort = "in1",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "model",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        ),
        g6_edge(
          type = "cubic",
          source = "structured_output_parser",
          target = "auto_fixing_parser",
          style = list(
            sourcePort = "out",
            targetPort = "in2",
            stroke = "#c1c2cb",
            endArrow = TRUE,
            lineDash = c(6, 4),
            labelText = "output parser",
            labelPlacement = "start",
            labelBackground = TRUE,
            labelBackgroundFill = "#545353ff"
          )
        )
      )
    ) |>
      #g6_layout(antv_dagre_layout(rankdir = "LR")) |>
      g6_options(
        animation = FALSE,
        background = "#1b1b1b",
        theme = "dark",
        node = list(
          style = list(
            fill = "#282828",
            stroke = "#c1c2cb",
            #labelFill = "#cdcfd3",
            lineWidth = 2
          ),
          state = list(
            selected = list(
              fill = "#282828",
              stroke = "#c1c2cb"
            )
          )
        )
      ) |>
      g6_behaviors(
        click_select(multiple = TRUE),
        drag_element(
          enable = JS(
            "(e) => {
          return !e.shiftKey && !e.altKey;
        }"
          )
        ),
        drag_canvas(
          enable = JS(
            "(e) => {
          return e.targetType === 'canvas' && !e.shiftKey && !e.altKey;
        }"
          )
        ),
        zoom_canvas(),
        create_edge(
          enable = JS(
            "(e) => {
        return e.shiftKey}"
          )
        )
      )
  )
}

shinyApp(ui, server)
