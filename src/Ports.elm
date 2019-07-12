port module Ports exposing
    ( hostGame
    , fromJs
    , IncomingMessage(..)
    , readyUp
    )

import Json.Encode as Json
import Json.Decode as D exposing (Decoder)

-- INCOMING

port incoming : (Json.Value -> msg) -> Sub msg

decoder : Decoder IncomingMessage
decoder =
    D.field "action" D.string
    |> D.andThen (\action ->
        case action of
            "HOST_URL" ->
                D.map HostUrl (D.field "url" D.string)
            "FRIEND_READY" ->
                D.map FriendReady (D.field "id" D.string)
            _ ->
                D.fail ("Did not recognize action: " ++ action)
    )
type IncomingMessage
    = HostUrl String
    | FriendReady String
    | GotTrash


fromJs : (IncomingMessage -> msg) -> Sub msg
fromJs handler =
    incoming
        (\json ->
            case D.decodeValue decoder json of
                Ok message ->
                    (handler message)
                Err _ ->
                    (handler GotTrash)
        )


-- OUTGOING

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