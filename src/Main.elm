module Main exposing (..)

import Argmaps as Argmaps
import Bootstrap.Navbar as Navbar
import Browser
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, href, id)



---- MODEL ----


type alias Model =
    { navbarState : Navbar.State
    , argmapsState : Argmaps.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( argmapsState, argmapsCmd ) =
            Argmaps.initialState
    in
    ( Model navbarState argmapsState, argmapsCmd )



---- UPDATE ----


type Msg
    = NavbarMsg Navbar.State
    | ArgmapsMsg Argmaps.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ArgmapsMsg am ->
            let
                ( argmapsState, argmapsCmd ) =
                    Argmaps.update am model.argmapsState
            in
            ( { model | argmapsState = argmapsState }, argmapsCmd )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Navbar.config NavbarMsg
            |> Navbar.brand [ href "#" ] [ text "Argument Maps" ]
            |> Navbar.items
                [ Navbar.itemLink [ href "#" ] [ text "About" ] ]
            |> Navbar.view model.navbarState
        , Argmaps.view model.argmapsState ArgmapsMsg
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = Argmaps.subscriptions ArgmapsMsg
        }
