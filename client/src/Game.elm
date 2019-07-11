module Game exposing
    ( Board
    , Game
    , GameState(..)
    , Player(..)
    , init
    , update
    , view
    )

import Array exposing (Array)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


type alias Game =
    { board : Board
    , state : GameState
    }


type alias Board =
    Array (Array (Maybe Player))


type GameState
    = PlayerTurn Player
    | Winner Player


type Player
    = X
    | O


init : Game
init =
    Game
        (Array.initialize 3 (always (Array.initialize 3 (always Nothing))))
        (PlayerTurn X)


update : Player -> ( Int, Int ) -> Game -> Game
update player location game =
    let
        updatedBoard =
            placePiece player location game.board
    in
    { game
        | board = updatedBoard
        , state = nextState updatedBoard game.state
    }


placePiece : Player -> ( Int, Int ) -> Board -> Board
placePiece player ( x, y ) board =
    Array.get y board
        |> Maybe.map (\row -> Array.set y (Array.set x (Just player) row) board)
        |> Maybe.withDefault board


nextState : Board -> GameState -> GameState
nextState board state =
    case state of
        PlayerTurn player ->
            if hasWinner board then
                Winner player

            else
                PlayerTurn (other player)

        Winner player ->
            PlayerTurn (other player)


hasWinner : Board -> Bool
hasWinner board =
    List.any (haveSameValue board)
        [ [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ) ]
        , [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ]
        , [ ( 0, 2 ), ( 1, 2 ), ( 2, 2 ) ]
        , [ ( 0, 0 ), ( 0, 1 ), ( 0, 2 ) ]
        , [ ( 1, 0 ), ( 1, 1 ), ( 1, 2 ) ]
        , [ ( 2, 0 ), ( 2, 1 ), ( 2, 2 ) ]
        , [ ( 0, 0 ), ( 1, 1 ), ( 2, 2 ) ]
        , [ ( 0, 2 ), ( 1, 1 ), ( 2, 0 ) ]
        ]


haveSameValue : Board -> List ( Int, Int ) -> Bool
haveSameValue board =
    List.map (get board)
        >> (\values -> List.all ((==) (Just X)) values || List.all ((==) (Just O)) values)


get : Board -> ( Int, Int ) -> Maybe Player
get board ( x, y ) =
    Array.get y board
        |> Maybe.andThen (\row -> Array.get x row)
        |> Maybe.withDefault Nothing


view : msg -> (Player -> ( Int, Int ) -> msg) -> Game -> Element msg
view newGame onClick game =
    el
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        ]
    <|
        case game.state of
            PlayerTurn player ->
                column [ spacing 16 ]
                    [ el [ Font.size 16 ] (text ("Player " ++ toString player ++ ", it's your turn."))
                    , column [ centerX, Border.width 1 ]
                        (Array.indexedMap
                            (viewRow (onClick player))
                            game.board
                            |> Array.toList
                        )
                    ]

            Winner player ->
                column [ spacing 24 ]
                    [ text ("Player " ++ toString player ++ ", you won!")
                    , Input.button
                        [ Border.width 2
                        , Border.rounded 4
                        , pointer
                        , paddingXY 20 10
                        , centerX
                        ]
                        { onPress = Just newGame
                        , label = text "Play again?"
                        }
                    ]


viewRow : (( Int, Int ) -> msg) -> Int -> Array (Maybe Player) -> Element msg
viewRow onClick y row =
    Element.row [] (Array.indexedMap (viewSquare onClick y) row |> Array.toList)


viewSquare : (( Int, Int ) -> msg) -> Int -> Int -> Maybe Player -> Element msg
viewSquare onClick y x value =
    Input.button
        [ width (px 48)
        , height (px 48)
        , Border.width 1
        ]
        { onPress = Just (onClick ( x, y ))
        , label =
            el
                [ centerX
                , centerY
                ]
                (text (value |> Maybe.map toString |> Maybe.withDefault ""))
        }


toString : Player -> String
toString player =
    case player of
        X ->
            "X"

        O ->
            "O"


other : Player -> Player
other player =
    case player of
        X ->
            O

        O ->
            X
