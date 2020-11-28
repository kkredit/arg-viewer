port module Main exposing (..)

import ArgdownJsInterop exposing (..)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Spinner as Spinner
import Browser
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (id)
import Json.Decode exposing (decodeString, errorToString)



-- PORTS


port updateMap : String -> Cmd msg


port mountMapAtId : String -> Cmd msg


port receiveMap : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveMap UpdateMapStateJson



---- MODEL ----


type alias Model =
    { variant : VariantConfig
    , argmap : ArgumentMapState
    }


init : ( Model, Cmd Msg )
init =
    ( Model variants.contrib Loading, updateMap variants.contrib.name )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateMapStateJson s ->
            let
                state =
                    parseRenderStatus s
            in
            ( { model | argmap = state }
            , if state == Success then
                mountMapAtId "map"

              else
                Cmd.none
            )

        SubmitUpdate u ->
            ( model, updateMap u )


parseRenderStatus : String -> ArgumentMapState
parseRenderStatus jsonStatus =
    case decodeString updateMapStateDecoder jsonStatus of
        Err e ->
            Failed ("Error parsing JSON response: " ++ errorToString e)

        Ok status ->
            if status.success then
                Success

            else
                Failed status.error



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Argument Map Viewer" ]
        , Grid.container []
            [ Grid.row [ Row.centerXs ]
                [ Grid.col [ Col.xs12 ]
                    [ renderMapInfo model.argmap, div [ id "map" ] [] ]
                ]
            ]
        ]


renderMapInfo : ArgumentMapState -> Html Msg
renderMapInfo argmap =
    case argmap of
        Loading ->
            div [ id "loading" ] [ Spinner.spinner [ Spinner.grow ] [] ]

        Success ->
            span [] []

        Failed message ->
            text ("Error rendering map.\n" ++ message)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
