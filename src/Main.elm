module Main exposing (..)

import About
import Argmaps
import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, href)
import Url
import Url.Parser as UrlParser exposing ((</>), Parser, fragment, map, oneOf, s)



---- MODEL ----


type alias Model =
    { key : Nav.Key
    , route : Maybe Route
    , navbarState : Navbar.State
    , argmapsState : Argmaps.Model
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( argmapsState, argmapsCmd ) =
            Argmaps.initialState
    in
    ( Model key (UrlParser.parse routeParser url) navbarState argmapsState, Cmd.batch [ navbarCmd, argmapsCmd ] )



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavbarMsg Navbar.State
    | ArgmapsMsg Argmaps.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key <| Url.toString url )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | route = UrlParser.parse routeParser url }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ArgmapsMsg am ->
            let
                ( argmapsState, argmapsCmd ) =
                    Argmaps.update am model.argmapsState
            in
            ( { model | argmapsState = argmapsState }, argmapsCmd )



---- ROUTING ----


type Route
    = About
    | Argmaps (Maybe String)


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map About (s "about")
        , map Argmaps (fragment identity)
        ]



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    let
        ( title, content ) =
            case model.route of
                Nothing ->
                    ( "Invalid path", text "Invalid path." )

                Just route ->
                    case route of
                        About ->
                            ( "About", About.view )

                        Argmaps _ ->
                            ( "Argmaps", Argmaps.view model.argmapsState ArgmapsMsg )
    in
    { title = title
    , body =
        [ div [ class "container" ]
            [ Navbar.config NavbarMsg
                |> Navbar.brand [ href "/" ] [ text "Argument Maps" ]
                |> Navbar.items
                    [ Navbar.itemLink [ href "/about" ] [ text "About" ] ]
                |> Navbar.view model.navbarState
            , content
            ]
        ]
    }



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = Argmaps.subscriptions ArgmapsMsg
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
