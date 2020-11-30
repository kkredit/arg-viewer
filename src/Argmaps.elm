port module Argmaps exposing (Model, Msg, initialState, subscriptions, update, view)

import ArgdownJsInterop exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Spinner as Spinner
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)



---- MODEL ----


type alias Model =
    { config : MapConfig
    , argmap : ArgumentMapState
    }


initialState : ( Model, Cmd msg )
initialState =
    ( Model defaultConfig Loading, updateMap (configSerialize defaultConfig) )



---- UPDATE ----


type Msg
    = UpdateMapStateJson String
    | UpdateConfig MapConfig


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        UpdateMapStateJson s ->
            let
                state =
                    parseRenderStatus s

                command =
                    if state == Success then
                        mountMapAtId "map"

                    else
                        Cmd.none
            in
            ( { model | argmap = state }, command )

        UpdateConfig c ->
            ( { model | config = c, argmap = Loading }, updateMap (configSerialize c) )



-- PORTS


port updateMap : String -> Cmd msg


port mountMapAtId : String -> Cmd msg


port updateStatus : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : (Msg -> msg) -> model -> Sub msg
subscriptions toMsg _ =
    updateStatus <| UpdateMapStateJson >> toMsg



---- VIEW ----


view : Model -> (Msg -> msg) -> Html msg
view model toMsg =
    div []
        [ h1 [] [ text "Argument Map Viewer" ]
        , Grid.container []
            [ Grid.row [ Row.centerXs ]
                [ Grid.col [ Col.xs10 ]
                    (List.map (makeButton model.config.name toMsg)
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
            , Grid.row [ Row.centerXs ] [ Grid.col [ Col.xs12 ] [ div [ id "map" ] [] ] ]
            ]
        ]


makeButton : String -> (Msg -> msg) -> MapConfig -> Html msg
makeButton name toMsg mc =
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
            , Button.attrs [ class "config-button", onClick <| toMsg <| UpdateConfig mc ]
            ]
            [ text mc.label ]
        ]


renderMapSpecials : ArgumentMapState -> Maybe (Html msg)
renderMapSpecials argmap =
    case argmap of
        Success ->
            Nothing

        Loading ->
            Just (div [ id "loading" ] [ Spinner.spinner [ Spinner.grow ] [] ])

        Failed message ->
            Just (text ("Error rendering map.\n" ++ message))
