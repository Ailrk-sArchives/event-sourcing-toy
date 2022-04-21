{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
module Main where


import Data.Aeson
import Store
import Data.List
import Types
import qualified Data.Text as T
import Service
import Servant.API
import Servant
import Servant.API.WebSocket
import Control.Monad.Trans.Class
import Control.Monad.IO.Class
import Network.Wai.Handler.Warp
import Network.WebSockets
import Data.Proxy
import Control.Concurrent
import Control.Concurrent.Async

cmds =
        [ AddCandidate (Candidate { name = T.pack "can1" , cid = 1, status = Begin })
        , AddCandidate (Candidate { name = T.pack "can2" , cid = 2, status = Begin })
        , AddCandidate (Candidate { name = T.pack "can3" , cid = 3, status = Begin })
        , AddCandidate (Candidate { name = T.pack "can4" , cid = 4, status = Begin })
        , DeleteCandidate 1
        , PassCandidateInterview 2
        , PassCandidateInterview 3
        , PassCandidateTest 3
        , AddCandidate (Candidate { name = T.pack "can5" , cid = 5, status = Begin })
        , AddCandidate (Candidate { name = T.pack "can6" , cid = 6, status = Begin })
        ]

type ServantType = "stream" :> WebSocket
              :<|> Raw

server :: Server ServantType
server = streamData :<|>  serveDirectoryFileServer "static/"
  where
    streamData c = do
      liftIO $ do
        events <- readAll
        let state = foldl interp initState events
        putStrLn "Sending data"
        sendTextData c (encode state) >> threadDelay  1000000


app :: Application
app = serve (Proxy :: Proxy ServantType) server

main :: IO ()
main = do
  -- let events = mconcat $ fmap decide cmds
  -- print $ foldl interp initState events
  -- append events
  run 4000 app
