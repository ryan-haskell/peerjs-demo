module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Element exposing (..)
import Game exposing (..)


type alias Flags =
    ()


type Model
    = MainMenu
    | InLobby Id
    | InGame Id Game


type alias Id =
    String


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
    ( InGame "1234" Game.init, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( InGame id game, ClickSquare player ( x, y ) ) ->
            ( InGame id (Game.update player ( x, y ) game)
            , Cmd.none
            )

        ( InGame id _, NewGame ) ->
            ( InGame id Game.init
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Element Msg
view model =
    case model of
        MainMenu ->
            viewMainMenu

        InLobby id ->
            viewLobby id

        InGame id game ->
            viewGame id game


viewMainMenu : Element Msg
viewMainMenu =
    text "TODO: Main menu"


viewLobby : Id -> Element Msg
viewLobby id =
    text "TODO: Player lobby"


viewGame : Id -> Game -> Element Msg
viewGame id game =
    Game.view NewGame ClickSquare game
