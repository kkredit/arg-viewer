module Main exposing (..)

import About
import Argmaps
import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Html exposing (Attribute, div, text)
import Html.Attributes exposing (class, hidden, href, id)
import Url
import Url.Parser as UrlParser exposing ((</>), Parser, fragment, map, oneOf, s)



---- MODEL ----


type alias Model =
    { key : Nav.Key
    , basepath : String
    , route : Maybe Route
    , navbarState : Navbar.State
    , argmapsState : Argmaps.Model
    }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init basepath url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( argmapsState, argmapsCmd ) =
            Argmaps.initialState
    in
    ( Model key basepath (UrlParser.parse (routeParser basepath) url) navbarState argmapsState, Cmd.batch [ navbarCmd, argmapsCmd ] )



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
            ( { model | route = UrlParser.parse (routeParser model.basepath) url }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ArgmapsMsg am ->
            let
                ( argmapsState, argmapsCmd ) =
                    Argmaps.update am model.argmapsState
            in
            ( { model | argmapsState = argmapsState }, argmapsCmd )



---- ROUTING ----
-- Use hash based routing to work on GitHub Pages


type Route
    = Base (Maybe String)


routeParser : String -> Parser (Route -> a) a
routeParser basepath =
    let
        basePrepend =
            if basepath == "" then
                identity

            else
                (</>) <| s basepath
    in
    oneOf
        [ map Base (basePrepend <| fragment identity)
        ]



---- VIEW ----


baseHref : String -> String -> Attribute msg
baseHref basepath path =
    if String.left 1 path == "/" then
        href <| "/" ++ basepath ++ path

    else
        href path


view : Model -> Browser.Document Msg
view model =
    let
        ( title, content, isOnMap ) =
            case model.route of
                Nothing ->
                    ( "Invalid path", text "Invalid path.", False )

                Just route ->
                    case route of
                        Base maybeHash ->
                            case maybeHash of
                                Nothing ->
                                    ( "Argmaps", Argmaps.view model.argmapsState ArgmapsMsg, True )

                                Just hash ->
                                    case hash of
                                        "about" ->
                                            ( "About", About.view, False )

                                        _ ->
                                            ( "Argmaps", Argmaps.view model.argmapsState ArgmapsMsg, True )

        bHref =
            if model.basepath /= "" then
                baseHref model.basepath

            else
                href
    in
    { title = title
    , body =
        [ Navbar.config NavbarMsg
            |> Navbar.dark
            |> Navbar.brand [ bHref "/" ] [ text "Argument Maps" ]
            |> Navbar.items
                [ Navbar.itemLink [ bHref "/#about" ] [ text "About" ] ]
            |> Navbar.view model.navbarState
        , div [ class "container" ]
            [ content
            , div [ id "map", hidden (not isOnMap) ] []
            ]
        ]
    }



---- PROGRAM ----


main : Program String Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = Argmaps.subscriptions ArgmapsMsg
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
