port module Ports exposing (incoming, outgoing)


port incoming : (String -> msg) -> Sub msg


port outgoing : String -> Cmd msg
