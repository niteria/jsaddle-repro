{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Concurrent
import Control.Monad.IO.Class
import Data.Text
import Language.Javascript.JSaddle
import Language.Javascript.JSaddle.Warp

extraJs :: Text
extraJs =
  mconcat
    [ "(function(f) {"
    , "  f('Hello');"
    , "  let s = document.createElement('div'); "
    , "  window['handler'] = function() { console.log('Logging from default handler'); };"
    , "  window['register'] = function(f) { window['handler'] = f; };"
    , "  s.innerHTML = '<button onclick=\"handler()\">Click me</button>'; "
    , "  document.getElementsByTagName('body')[0].appendChild(s);"
    , "})"
    ]

main :: IO ()
main =
  run 8085 $ do
    result <- liftIO newEmptyMVar
    deRefVal $
      call
        (eval extraJs)
        global
        [fun $ \_ _ [arg1] -> do valToText arg1 >>= (liftIO . putMVar result)]
    liftIO $ takeMVar result
    cb <-
      function $ \_ _ _ -> do
        deRefVal $
          call
            (eval
               ("(function (f) { console.log('Logging from callback'); f(); })" :: Text))
            global
            [fun $ \_ _ [] -> return ()]
        return ()
    jsg1 ("register" :: Text) cb
    return ()
