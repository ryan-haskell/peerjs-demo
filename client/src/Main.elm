module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Element exposing (..)
import Game exposing (..)


type alias Flags =
    ()


type alias Model =
    { game : Game
    }


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
    ( Model Game.init
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickSquare player ( x, y ) ->
            ( { model | game = Game.update player ( x, y ) model.game }
            , Cmd.none
            )

        NewGame ->
            ( { model | game = Game.init }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Element Msg
view model =
    Game.view NewGame ClickSquare model.game
