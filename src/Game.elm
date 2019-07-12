module Game exposing
    ( Board
    , Game
    , GameState(..)
    , Player(..)
    , decoder
    , encode
    , init
    , update
    , view
    )

import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Grid exposing (Grid)
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Style exposing (styles)


type alias Game =
    { board : Board
    , state : GameState
    }



-- ENCODE


decoder : Decoder Game
decoder =
    D.map2 Game
        (D.field "board" (Grid.decoder (D.maybe playerDecoder)))
        (D.field "state" stateDecoder)


encode : Game -> E.Value
encode game =
    E.object
        [ ( "board", Grid.encode maybePlayerEncoder game.board )
        , ( "state", encodeGameState game.state )
        ]


playerDecoder : Decoder Player
playerDecoder =
    D.string
        |> D.andThen
            (\str ->
                if str == "X" then
                    D.succeed X

                else if str == "O" then
                    D.succeed O

                else
                    D.fail "who dat"
            )


maybePlayerEncoder : Maybe Player -> E.Value
maybePlayerEncoder player =
    case player of
        Just p ->
            playerEncoder p

        Nothing ->
            E.null


playerEncoder : Player -> E.Value
playerEncoder player =
    E.string (toString player)


stateDecoder : Decoder GameState
stateDecoder =
    D.field "type" D.string
        |> D.andThen
            (\t ->
                if t == "player-turn" then
                    D.field "value" playerDecoder
                        |> D.map PlayerTurn

                else if t == "winner" then
                    D.field "value" (D.maybe playerDecoder)
                        |> D.map Winner

                else
                    D.fail "who dis"
            )


encodeGameState : GameState -> E.Value
encodeGameState state =
    case state of
        PlayerTurn player ->
            E.object
                [ ( "type", E.string "player-turn" )
                , ( "value", playerEncoder player )
                ]

        Winner player ->
            E.object
                [ ( "type", E.string "winner" )
                , ( "value", maybePlayerEncoder player )
                ]


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


view : msg -> msg -> (Player -> ( Int, Int ) -> msg) -> Player -> Game -> Element msg
view quitGame newGame onClick u game =
    column
        [ centerX
        , centerY
        , Font.family [ Font.monospace ]
        , spacing 48
        ]
        [ case game.state of
            PlayerTurn player ->
                column [ spacing 24, centerX ]
                    [ el [ Font.size 20, Font.semiBold, centerX ]
                        (text
                            ((if u == player then
                                "your"

                              else
                                "their"
                             )
                                ++ " move"
                            )
                        )
                    , column [ centerX, Border.width 1 ]
                        (List.indexedMap
                            (viewRow (u == player) (onClick player))
                            (Grid.toListOfLists game.board)
                        )
                    ]

            Winner winner ->
                column [ spacing 24, centerX ]
                    [ el [ centerX ]
                        (text <|
                            case winner of
                                Just player ->
                                    if u == player then
                                        "You won!"
                                    else
                                        "You lose, heheh."

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


viewRow : Bool -> (( Int, Int ) -> msg) -> Int -> List (Maybe Player) -> Element msg
viewRow isYourTurn onClick y row =
    Element.row [] (List.indexedMap (viewSquare isYourTurn onClick y) row)


viewSquare : Bool -> (( Int, Int ) -> msg) -> Int -> Int -> Maybe Player -> Element msg
viewSquare isYourTurn onClick y x value =
    Input.button
        [ width (px 48)
        , height (px 48)
        , Border.width 1
        ]
        { onPress =
            if isYourTurn then
                Just (onClick ( x, y ))

            else
                Nothing
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
