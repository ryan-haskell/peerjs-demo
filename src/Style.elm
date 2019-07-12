module Style exposing
    ( colors
    , styles
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


colors =
    { white = rgb 1 1 1
    , black = rgb 0 0 0
    , red = rgb 0.7 0.2 0.2
    , green = rgb 0.2 0.6 0.3
    }


button : Color -> Color -> Color -> List (Element.Attribute msg)
button fontColor borderColor backgroundColor =
    [ Border.rounded 4
    , Border.width 2
    , Border.color borderColor
    , Background.color backgroundColor
    , Font.color fontColor
    , paddingXY 20 10
    ]


styles =
    { buttons =
        { success = button colors.white colors.green colors.green
        , danger = button colors.white colors.red colors.red
        , default = button colors.black colors.black colors.white
        }
    }
