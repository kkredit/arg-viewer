module ArgdownJsInterop exposing (..)

import Json.Decode exposing (Decoder, bool, field, map2, string)


type alias VariantConfig =
    { name : String }


variants :
    { whole : VariantConfig
    , contrib : VariantConfig
    , goingdark : VariantConfig
    , goldenage : VariantConfig
    , fallacies : VariantConfig
    , measures : VariantConfig
    , classes : VariantConfig
    }
variants =
    { whole = VariantConfig "whole"
    , contrib = VariantConfig "contrib"
    , goingdark = VariantConfig "goingdark"
    , goldenage = VariantConfig "goldenage"
    , fallacies = VariantConfig "fallacies"
    , measures = VariantConfig "measures"
    , classes = VariantConfig "classes"
    }


type ArgdownError
    = InvalidSettings
    | OtherError


type Msg
    = UpdateMapStateJson String
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
