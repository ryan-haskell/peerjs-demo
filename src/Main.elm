module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Game exposing (..)
import Ports
import Style exposing (styles)
import Json.Decode as D


type alias Flags =
    { id : Maybe String
    }


type Model
    = MainMenu
    | HostLobby String
    | JoinLobby String
    | InGame Player Game


type Msg
    = ClickSquare Player ( Int, Int )
    | NewGame Player
    | QuitGame
    | RequestToHostGame
    | FromJs Ports.IncomingMessage
    | ReadyUp


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> Element.layout [ width fill, height fill ]
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( case flags.id of
        Just id ->
            JoinLobby id

        Nothing ->
            MainMenu
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( InGame u game, ClickSquare player ( x, y ) ) ->
            let
                updatedGame =
                    Game.update player ( x, y ) game
            in
            ( InGame u updatedGame
            , Ports.sendGame updatedGame
            )

        ( _, ClickSquare _ _ ) ->
            ( model
            , Cmd.none
            )

        ( _, RequestToHostGame ) ->
            ( model
            , Ports.hostGame
            )

        ( _, NewGame player ) ->
            ( InGame player Game.init
            , Ports.sendGame Game.init
            )

        ( _, QuitGame ) ->
            ( MainMenu
            , Cmd.none
            )

        ( _, FromJs message ) ->
            case message of
                Ports.HostUrl url ->
                    ( HostLobby url
                    , Cmd.none
                    )

                Ports.FriendReady id ->
                    let
                        player =
                            case model of
                                HostLobby _ ->
                                    X

                                JoinLobby _ ->
                                    O

                                _ ->
                                    X
                    in
                    ( InGame player Game.init
                    , Cmd.none
                    )

                Ports.GameReceived gameValue ->
                    case model of
                        InGame u _ ->
                            case D.decodeValue Game.decoder gameValue of
                                Ok game ->
                                    ( InGame u game, Cmd.none )

                                Err reason ->
                                    let
                                        _ =
                                            Debug.log "GAME" reason
                                    in
                                    
                                    ( model
                                    , Cmd.none
                                    )

                        _ ->
                            ( model
                            , Cmd.none
                            )

                Ports.GotTrash ->
                    ( model
                    , Cmd.none
                    )

        ( JoinLobby id, ReadyUp ) ->
            ( model
            , Ports.readyUp id
            )

        ( HostLobby url, ReadyUp ) ->
            ( model, Cmd.none )

        ( _, ReadyUp ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.fromJs FromJs


view : Model -> Element Msg
view model =
    case model of
        MainMenu ->
            viewMainMenu

        HostLobby url ->
            viewHostLobby url

        JoinLobby id ->
            viewJoinLobby id

        InGame player game ->
            Game.view QuitGame (NewGame player) ClickSquare player game


viewMainMenu : Element Msg
viewMainMenu =
    column
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        , spacing 32
        ]
        [ el
            [ Font.size 32
            , Font.semiBold
            ]
            (text "tic-tac-whoa")
        , column [ centerX ]
            [ Input.button styles.buttons.success
                { onPress = Just RequestToHostGame
                , label = text "play"
                }
            ]
        ]


viewHostLobby : String -> Element Msg
viewHostLobby url =
    column
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        , spacing 32
        ]
        [ el
            [ Font.size 32
            , Font.semiBold
            , centerX
            ]
            (text "waiting for a pal")
        , column [ Font.size 14, spacing 8, centerX ]
            [ paragraph [ Font.center ]
                [ text "(You should send them this)" ]
            , paragraph [ Font.center ]
                [ text url ]
            ]
        , column [ centerX ]
            [ Input.button styles.buttons.danger
                { onPress = Just QuitGame
                , label = text "bail"
                }
            ]
        ]


viewJoinLobby : String -> Element Msg
viewJoinLobby id =
    column
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        , spacing 32
        ]
        [ el
            [ Font.size 32
            , Font.semiBold
            ]
            (text "ready to play?")
        , column [ centerX ]
            [ Input.button styles.buttons.success
                { onPress = Just ReadyUp
                , label = text "o hell yis"
                }
            ]
        ]
