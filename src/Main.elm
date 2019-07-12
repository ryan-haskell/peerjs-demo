module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Game exposing (..)


type alias Flags =
    ()


type Model
    = MainMenu
    | InGame Game


type Msg
    = ClickSquare Player ( Int, Int )
    | NewGame


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Element Msg
view model =
    case model of
        MainMenu ->
            viewMainMenu

        InGame game ->
            Game.view NewGame ClickSquare game


colors =
    { white = rgb 1 1 1
    , black = rgb 0 0 0
    }


viewMainMenu : Element Msg
viewMainMenu =
    column
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        , spacing 16
        ]
        [ el
            [ Font.size 32
            , Font.semiBold
            ]
            (text "tic-tac-whoa")
        , column [ centerX ]
            [ Input.button
                [ Border.rounded 4
                , Border.width 2
                , Background.color colors.white
                , Font.color colors.black
                , paddingXY 20 10
                ]
                { onPress = Just NewGame
                , label = text "Create game"
                }
            ]
        ]
