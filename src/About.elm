module About exposing (Model, Msg, initialState, view)

import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Markdown.Option exposing (..)
import Markdown.Render
import MdPages.AboutMd as AboutMd exposing (text)



---- MODEL ----


type alias Model msg =
    { aboutHtml : Html msg }


initialState : (Msg -> msg) -> Model msg
initialState toMsg =
    Model <|
        Html.div
            [ class "markdown-page" ]
            [ Markdown.Render.toHtml Extended AboutMd.text |> Html.map (MarkdownMsg >> toMsg) ]



---- UPDATE ----


type Msg
    = MarkdownMsg Markdown.Render.MarkdownMsg



---- VIEW ----


view : Model msg -> Html msg
view model =
    model.aboutHtml
