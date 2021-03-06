module Main where

import Prelude hiding (putStrLn)
import Control.Monad (forM_)
import Data.Text (unpack, Text)
import Data.Text.IO (putStrLn)

import UI.Functions ( runInput )
import Types (emptyInputState,  InputState(..), ItemInfo(..) )
import Data.Vector (fromList)
import Utils (optionsParser, showText)
import Turtle (toText, cd, options, IsString(fromString))

programTitle :: Text
programTitle = "Test Audio CD Ripper GUI"

main :: IO ()
main = do
    mbwd <- options (fromString $ unpack programTitle) optionsParser
    case mbwd of
        Just wd -> do
            cd wd
            putStrLn $ "Changed to directory: '" <> either id id (toText wd) <> "'\n"
        Nothing -> return ()

    let discInfo@InputState {..} = emptyInputState 
            { albumInfo = ItemInfo True "Üstad" "Münir Nurettin Selçuk" 
            , trackInfos = fromList
                [ ItemInfo True "Track 01" ""
                , ItemInfo True "Track 02" ""
                , ItemInfo True "Track 03" ""
                , ItemInfo True "Track 03" ""
                , ItemInfo True "Track 04" ""
                , ItemInfo True "Track 05" ""
                , ItemInfo True "Track 06" ""
                , ItemInfo True "Track 07" ""
                , ItemInfo True "Track 08" ""
                , ItemInfo True "Track 09" ""
                , ItemInfo True "Track 10" ""
                ]
            } 
    print albumInfo
    print trackInfos
    discOutput@InputState {..} <- runInput discInfo
    printDiscOutput discOutput

printDiscOutput :: InputState -> IO ()
printDiscOutput InputState {..} = do
    putStrLn $ "inputResult =" <> showText inputResult
    putStrLn "Album Info"
    printItemInfo albumInfo
    putStrLn "Track Infos"
    forM_ trackInfos printItemInfo 

printItemInfo :: ItemInfo -> IO ()
printItemInfo = print