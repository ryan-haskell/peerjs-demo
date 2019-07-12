port module Ports exposing
    ( hostGame
    , incoming
    , readyUp
    )

import Json.Encode as Json


port incoming : (String -> msg) -> Sub msg


port outgoing :
    { action : String
    , payload : Json.Value
    }
    -> Cmd msg


hostGame : Cmd msg
hostGame =
    outgoing
        { action = "HOST_GAME"
        , payload = Json.null
        }

readyUp : String -> Cmd msg
readyUp id =
    outgoing
        { action = "READY_UP"
        , payload = Json.string id
        }