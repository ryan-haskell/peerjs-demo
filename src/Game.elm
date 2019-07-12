module Game exposing
    ( Board
    , Game
    , GameState(..)
    , Player(..)
    , init
    , update
    , view
    )

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Grid exposing (Grid)
import Style exposing (styles)


type alias Game =
    { board : Board
    , state : GameState
    }


type alias Board =
    Grid (Maybe Player)


type GameState
    = PlayerTurn Player
    | Winner (Maybe Player)


type Player
    = X
    | O


init : Game
init =
    Game
        (Grid.init ( 3, 3 ) Nothing)
        (PlayerTurn X)


update : Player -> ( Int, Int ) -> Game -> Game
update player location game =
    let
        updatedBoard : Board
        updatedBoard =
            case Grid.get location game.board |> Maybe.withDefault Nothing of
                Just _ ->
                    game.board

                Nothing ->
                    Grid.set (Just player) location game.board
    in
    { game
        | board = updatedBoard
        , state =
            if game.board == updatedBoard then
                game.state

            else
                nextState updatedBoard game.state
    }


nextState : Board -> GameState -> GameState
nextState board state =
    case state of
        PlayerTurn player ->
            if hasWinner board then
                Winner (Just player)

            else if boardIsFull board then
                Winner Nothing

            else
                PlayerTurn (other player)

        Winner (Just player) ->
            PlayerTurn (other player)

        Winner Nothing ->
            PlayerTurn X


hasWinner : Board -> Bool
hasWinner board =
    List.any (haveSamePlayer board)
        [ [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ) ]
        , [ ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ]
        , [ ( 0, 2 ), ( 1, 2 ), ( 2, 2 ) ]
        , [ ( 0, 0 ), ( 0, 1 ), ( 0, 2 ) ]
        , [ ( 1, 0 ), ( 1, 1 ), ( 1, 2 ) ]
        , [ ( 2, 0 ), ( 2, 1 ), ( 2, 2 ) ]
        , [ ( 0, 0 ), ( 1, 1 ), ( 2, 2 ) ]
        , [ ( 0, 2 ), ( 1, 1 ), ( 2, 0 ) ]
        ]


boardIsFull : Board -> Bool
boardIsFull =
    Grid.every ((/=) Nothing)


haveSamePlayer : Board -> List ( Int, Int ) -> Bool
haveSamePlayer board locations =
    List.map (\location -> Grid.get location board) locations
        |> List.map (Maybe.withDefault Nothing)
        |> (\values -> List.all ((==) (Just X)) values || List.all ((==) (Just O)) values)


view : msg -> msg -> (Player -> ( Int, Int ) -> msg) -> Game -> Element msg
view quitGame newGame onClick game =
    column
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        , spacing 48
        ]
        [ case game.state of
            PlayerTurn player ->
                column [ spacing 24, centerX ]
                    [ el [ Font.size 20, Font.semiBold ] (text ("Player " ++ toString player ++ "'s move"))
                    , column [ centerX, Border.width 1 ]
                        (List.indexedMap
                            (viewRow (onClick player))
                            (Grid.toListOfLists game.board)
                        )
                    ]

            Winner winner ->
                column [ spacing 24, centerX ]
                    [ el [ centerX ]
                        (text <|
                            case winner of
                                Just player ->
                                    "Player " ++ toString player ++ ", you won!"

                                Nothing ->
                                    "Tie game!"
                        )
                    , el [ centerX ] <|
                        Input.button
                            styles.buttons.default
                            { onPress = Just newGame
                            , label = text "Play again?"
                            }
                    ]
        , el [ centerX ] <|
            Input.button
                styles.buttons.danger
                { onPress = Just quitGame
                , label = text "quit"
                }
        ]


viewRow : (( Int, Int ) -> msg) -> Int -> List (Maybe Player) -> Element msg
viewRow onClick y row =
    Element.row [] (List.indexedMap (viewSquare onClick y) row)


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
