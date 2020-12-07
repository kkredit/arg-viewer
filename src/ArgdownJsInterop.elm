module ArgdownJsInterop exposing (..)

import Json.Decode exposing (Decoder, bool, decodeString, errorToString, field, map2, string)
import Json.Encode as Encode



---- MAP CONFIGS ----


type alias MapConfig =
    { name : String
    , label : String
    , groupDepth : Maybe Int
    , selectedSections : Maybe (List String)
    , excludeStatements : Maybe (List String)
    }


presetConfigs :
    { whole : MapConfig
    , contrib : MapConfig
    , goingdark : MapConfig
    , goldenage : MapConfig
    , fallacies : MapConfig
    , measures : MapConfig
    , classes : MapConfig
    }
presetConfigs =
    { whole = MapConfig "whole" "Entire Map" (Just 4) Nothing Nothing
    , contrib =
        MapConfig "contrib"
            "Contributing Factors"
            (Just 3)
            (Just
                [ "Central Issues"
                , "Response Measures"
                , "Arguments for Exceptional Access"
                , "Exceptional Access"
                ]
            )
            Nothing
    , goingdark =
        MapConfig "goingdark"
            "Going Dark"
            (Just 3)
            (Just
                [ "Exceptional Access"
                , "Central Issues"
                , "Going Dark Conclusions"
                , "Going Dark Argument"
                , "Going Dark Non Core"
                , "Mobile Device Security Sucks"
                ]
            )
            Nothing
    , goldenage =
        MapConfig "goldenage"
            "Golden Age for Surveillance"
            (Just 3)
            (Just
                [ "Exceptional Access"
                , "Central Issues"
                , "Going Dark Conclusions"
                , "Golden Age Argument"
                , "Golden Age Non Core"
                , "Mobile Device Security Sucks"
                ]
            )
            Nothing
    , fallacies =
        MapConfig "fallacies"
            "Fallacious Arguments"
            Nothing
            (Just [ "Exceptional Access", "Fallacies", "Fallacious Arguments" ])
            Nothing
    , measures =
        MapConfig "measures"
            "Response Measures"
            (Just 3)
            (Just
                [ "Central Issues"
                , "Desireable Properties"
                , "Response Measures"
                , "Exceptional Access"
                , "Current Capabilities"
                , "Legal Measures"
                , "Arguments for Measures"
                ]
            )
            Nothing
    , classes =
        MapConfig "classes"
            "Classes of EA"
            (Just 3)
            (Just
                [ "Central Issues"
                , "Desireable Properties"
                , "Exceptional Access"
                , "DAR EA Classes"
                , "DIM EA Classes"
                , "Arguments for EA Types"
                , "Mobile Device Security Sucks"
                ]
            )
            (Just [ "Exceptional Access" ])
    }


defaultConfig : MapConfig
defaultConfig =
    presetConfigs.contrib



---- COMMAND ----


captionPrefex : String
captionPrefex =
    "Encryption and Exceptional Access — "


configSerialize : MapConfig -> String
configSerialize c =
    Encode.encode 1 <|
        Encode.object
            [ ( "group", Encode.object [] )
            , ( "selection"
              , Encode.object
                    [ ( "selectedSections", justOrNull (Encode.list Encode.string) c.selectedSections )
                    , ( "excludeStatements", justOrNull (Encode.list Encode.string) c.excludeStatements )
                    ]
              )
            ]


justOrNull : (a -> Encode.Value) -> Maybe a -> Encode.Value
justOrNull encoder val =
    case val of
        Nothing ->
            Encode.null

        Just v ->
            encoder v



---- RESPONSE ----


type alias UpdateMapState =
    { success : Bool
    , error : String
    }


updateMapStateDecoder : Decoder UpdateMapState
updateMapStateDecoder =
    map2 UpdateMapState
        (field "success" bool)
        (field "error" string)


type ArgumentMapState
    = Loading
    | Failed String
    | Success


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
