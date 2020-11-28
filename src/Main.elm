port module Main exposing (..)

import ArgdownJsInterop exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Spinner as Spinner
import Browser
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (class, id, name)
import Html.Events exposing (onClick)
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
    { config : MapConfig
    , argmap : ArgumentMapState
    }


init : ( Model, Cmd Msg )
init =
    ( Model defaultConfig Loading, updateMap defaultConfig.name )



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

        UpdateConfig c ->
            ( { model | config = c, argmap = Loading }, updateMap c.name )

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
                [ Grid.col [ Col.xs10 ]
                    (List.map (makeButton model.config.name)
                        [ presetConfigs.whole
                        , presetConfigs.contrib
                        , presetConfigs.goingdark
                        , presetConfigs.goldenage
                        , presetConfigs.fallacies
                        , presetConfigs.measures
                        , presetConfigs.classes
                        ]
                    )
                ]
            , case renderMapSpecials model.argmap of
                Nothing ->
                    Grid.row [] []

                Just h ->
                    Grid.row [ Row.centerXs ] [ Grid.col [ Col.xs12 ] [ h ] ]
            , Grid.row [ Row.centerXs ]
                [ Grid.col [ Col.xs12 ] [ div [ id "map" ] [] ]
                ]
            ]
        ]


makeButton : String -> MapConfig -> Html Msg
makeButton name mc =
    let
        color =
            if name == mc.name then
                Button.primary

            else
                Button.light
    in
    span []
        [ Button.button
            [ color
            , Button.attrs [ class "config-button", onClick (UpdateConfig mc) ]
            ]
            [ text mc.label ]
        ]


renderMapSpecials : ArgumentMapState -> Maybe (Html Msg)
renderMapSpecials argmap =
    case argmap of
        Success ->
            Nothing

        Loading ->
            Just (div [ id "loading" ] [ Spinner.spinner [ Spinner.grow ] [] ])

        Failed message ->
            Just (text ("Error rendering map.\n" ++ message))



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
