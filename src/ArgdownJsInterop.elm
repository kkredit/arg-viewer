module ArgdownJsInterop exposing (..)

import Json.Decode exposing (Decoder, bool, field, map2, string)


type alias MapConfig =
    { name : String
    , label : String
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
    { whole = MapConfig "whole" "Entire Map"
    , contrib = MapConfig "contrib" "Contributing Factors"
    , goingdark = MapConfig "goingdark" "Going Dark"
    , goldenage = MapConfig "goldenage" "Golden Age for Surveillance"
    , fallacies = MapConfig "fallacies" "Fallacious Arguments"
    , measures = MapConfig "measures" "Response Measures"
    , classes = MapConfig "classes" "Classes of EA"
    }


defaultConfig : MapConfig
defaultConfig =
    presetConfigs.contrib


type ArgdownError
    = InvalidSettings
    | OtherError


type Msg
    = UpdateMapStateJson String
    | UpdateConfig MapConfig
    | SubmitUpdate String


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
