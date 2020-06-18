{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Concurrent
import Control.Monad.IO.Class
import Data.Text
import Language.Javascript.JSaddle
import Language.Javascript.JSaddle.Warp
import System.Environment

extraJs :: Text
extraJs =
  mconcat
    [ "(function(f) {"
    , "  let s = document.createElement('div'); "
    , "  window['handler'] = function() { console.log('Logging from default handler'); };"
    , "  window['register'] = function(f) { window['handler'] = f; };"
    , "  s.innerHTML = '<button onclick=\"handler()\">Click me</button>'; "
    , "  document.getElementsByTagName('body')[0].appendChild(s);"
    , "})"
    ]

main :: IO ()
main = do
  [port] <- getArgs
  putStrLn $ "Running on port " <> port <> "..."
  run (read port) $ do
    result <- liftIO newEmptyMVar
    call (eval extraJs) global ()
    cb <-
      function $ \_ _ _ -> do
        call
          (eval
             ("(function () { console.log('Logging from callback'); })" :: Text))
          global
          ()
        return ()
    jsg1 ("register" :: Text) cb
    return ()
