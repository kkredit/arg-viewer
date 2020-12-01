port module Argmaps exposing (Model, Msg, initialState, subscriptions, update, view)

import ArgdownJsInterop exposing (..)
import Bootstrap.Alert as Alert
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
    , alertVisibility : Alert.Visibility
    , argmap : ArgumentMapState
    }


initialState : ( Model, Cmd msg )
initialState =
    ( Model defaultConfig Alert.closed Loading, updateMap (configSerialize defaultConfig) )



---- UPDATE ----


type Msg
    = UpdateMapStateJson String
    | UpdateConfig MapConfig
    | AlertMsg Alert.Visibility


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

        -- TODO: error message isn't showing up!
        AlertMsg visibility ->
            ( { model | alertVisibility = visibility }, Cmd.none )



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
        [ h1 [ class "page-header" ] [ text "Argument Map Viewer" ]
        , Grid.container []
            [ makeRowCol Col.sm10
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
            , makeRowCol Col.sm10 [ renderMapSpecials model.argmap model.alertVisibility toMsg ]
            , makeRowCol Col.sm12 [ div [ id "map" ] [] ]
            ]
        ]


makeRowCol : Col.Option msg -> List (Html msg) -> Html msg
makeRowCol colOpt content =
    Grid.row [ Row.centerSm ] [ Grid.col [ colOpt ] content ]


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


renderMapSpecials : ArgumentMapState -> Alert.Visibility -> (Msg -> msg) -> Html msg
renderMapSpecials argmap alertVis toMsg =
    case argmap of
        Success ->
            text ""

        Loading ->
            div [ id "loading" ] [ Spinner.spinner [ Spinner.grow ] [] ]

        Failed message ->
            Alert.config
                |> Alert.danger
                |> Alert.dismissable (AlertMsg >> toMsg)
                |> Alert.children
                    [ Alert.h4 [] [ text "Error rendering map!" ]
                    , text message
                    ]
                |> Alert.view alertVis
