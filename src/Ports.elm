port module Ports exposing
    ( IncomingMessage(..)
    , fromJs
    , hostGame
    , readyUp
    , sendGame
    )

import Game exposing (Game)
import Json.Decode as D exposing (Decoder)
import Json.Encode as Json



-- INCOMING


port incoming : (Json.Value -> msg) -> Sub msg


decoder : Decoder IncomingMessage
decoder =
    D.field "action" D.string
        |> D.andThen
            (\action ->
                case action of
                    "HOST_URL" ->
                        D.map HostUrl (D.field "payload" D.string)

                    "FRIEND_READY" ->
                        D.map FriendReady (D.field "payload" D.string)

                    "GAME_RECEIVED" ->
                        D.map GameReceived (D.field "payload" D.value)

                    _ ->
                        D.fail ("Did not recognize action: " ++ action)
            )


type IncomingMessage
    = HostUrl String
    | FriendReady String
    | GameReceived Json.Value
    | GotTrash


fromJs : (IncomingMessage -> msg) -> Sub msg
fromJs handler =
    incoming
        (\json ->
            case D.decodeValue decoder json of
                Ok message ->
                    handler message

                Err reason ->
                    handler GotTrash
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


sendGame : Game -> Cmd msg
sendGame game =
    outgoing
        { action = "SEND_GAME"
        , payload = Game.encode game
        }
