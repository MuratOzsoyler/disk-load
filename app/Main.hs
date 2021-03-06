module Main where

import Prelude hiding (putStrLn)
import Control.Monad (forM_, when)
import Control.Monad.Loops (untilM_)
import Data.Maybe (fromMaybe, isJust)
import Data.Text (pack, Text, unpack)
import Data.Text.IO (putStrLn)
import System.IO (BufferMode (..), hSetBuffering, stdout)
import Turtle (cd, echo, fromString, options, textToLine, toText)

import DiscHandling.Inspection ( parseDiscInfo, readDiscInfo )
import DiscHandling.Ripping ( writeTracks )
import Utils
    ( createDirectory,
      ejectDisc,
      loadDisc,
      mkDirName,
      optionsParser,
      shellQuote, 
      showText)
import UI.Functions ( runInput )
import UI.Interaction ( getContinueConfirm, promptDisc )
import Types (InputResult(InputResultRipDisc),  InputState(..), ItemInfo(..) )

programTitle :: Text
programTitle = "Audio CD Ripper"

main :: IO ()
main = do
    mbwd <- options (fromString $ unpack programTitle) optionsParser
    case mbwd of
        Just wd -> do
            cd wd
            putStrLn $ "Changed to directory: '" <> either id id (toText wd) <> "'\n"
        Nothing -> return ()

    hSetBuffering stdout NoBuffering
    putStrLn programTitle >> putStrLn ""

    ejectDisc
    flip untilM_ (not <$> getContinueConfirm) $ do
        promptDisc
        loadDisc
        info <- readDiscInfo
        when (isJust info) $ do
            discInfo@InputState {..} <- parseDiscInfo info
            print albumInfo
            print trackInfos
            discOutput@InputState {..} <- runInput discInfo
            printDiscOutput discOutput

            when (inputResult == InputResultRipDisc) $ do
                let dirName = mkDirName albumInfo
                echo $ fromMaybe "Invalid text!" $ textToLine $ shellQuote $ either id id $ toText dirName
                createDirectory $ shellQuote $ either id id $ toText dirName
                writeTracks dirName (from albumInfo) trackInfos
        ejectDisc
                
    echo "Do not forget to pick the disc off the tray and close the drive door"

printDiscOutput :: InputState -> IO ()
printDiscOutput InputState {..} = do
    putStrLn $ "inputResult=" <> showText inputResult 
    putStrLn "Album Info"
    printItemInfo albumInfo
    putStrLn "Track Infos"
    forM_ trackInfos printItemInfo 

printItemInfo :: ItemInfo -> IO ()
printItemInfo = print --ItemInfo {..} = do
    -- putStrLn 
    --     $ "title=" <> pack (show title)
    --     <> ", "
    --     <> "from=" <> pack (show from)