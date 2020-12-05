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
    , basePath : String
    , route : Maybe Route
    , navbarState : Navbar.State
    , argmapsState : Argmaps.Model
    , aboutState : About.Model Msg
    }


init : List String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        ( argmapsState, argmapsCmd ) =
            Argmaps.initialState

        basePath =
            strListIndex flags 0

        aboutState =
            About.initialState AboutMsg
    in
    ( Model key basePath (UrlParser.parse (routeParser basePath) url) navbarState argmapsState aboutState
    , Cmd.batch [ navbarCmd, argmapsCmd ]
    )


strListIndex : List String -> Int -> String
strListIndex list n =
    Maybe.withDefault "" <| List.head <| List.drop n list



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavbarMsg Navbar.State
    | ArgmapsMsg Argmaps.Msg
    | AboutMsg About.Msg


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
            ( { model | route = UrlParser.parse (routeParser model.basePath) url }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ArgmapsMsg am ->
            let
                ( argmapsState, argmapsCmd ) =
                    Argmaps.update am model.argmapsState
            in
            ( { model | argmapsState = argmapsState }, argmapsCmd )

        AboutMsg _ ->
            ( model, Cmd.none )



---- ROUTING ----
-- Use hash based routing to work on GitHub Pages


type Route
    = Base (Maybe String)


routeParser : String -> Parser (Route -> a) a
routeParser basePath =
    let
        basePrepend =
            if basePath == "" then
                identity

            else
                (</>) <| s basePath
    in
    oneOf
        [ map Base (basePrepend <| fragment identity)
        ]



---- VIEW ----


baseHref : String -> String -> Attribute msg
baseHref basePath path =
    if String.left 1 path == "/" then
        href <| "/" ++ basePath ++ path

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
                                            ( "About", About.view model.aboutState, False )

                                        _ ->
                                            ( "Argmaps", Argmaps.view model.argmapsState ArgmapsMsg, True )

        bHref =
            if model.basePath /= "" then
                baseHref model.basePath

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


main : Program (List String) Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = Argmaps.subscriptions ArgmapsMsg
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
