module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Game exposing (..)
import Style exposing (styles)


type alias Flags =
    ()


type Model
    = MainMenu
    | InGame Game


type Msg
    = ClickSquare Player ( Int, Int )
    | NewGame
    | QuitGame


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> Element.layout [ width fill, height fill ]
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( MainMenu
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( InGame game, ClickSquare player ( x, y ) ) ->
            ( InGame (Game.update player ( x, y ) game)
            , Cmd.none
            )

        ( MainMenu, ClickSquare _ _ ) ->
            ( model
            , Cmd.none
            )

        ( _, NewGame ) ->
            ( InGame Game.init
            , Cmd.none
            )

        ( _, QuitGame ) ->
            ( MainMenu
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Element Msg
view model =
    case model of
        MainMenu ->
            viewMainMenu

        InGame game ->
            Game.view QuitGame NewGame ClickSquare game


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
                { onPress = Just NewGame
                , label = text "play"
                }
            ]
        ]
