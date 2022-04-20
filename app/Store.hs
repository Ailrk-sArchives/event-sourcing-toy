{-# LANGUAGE OverloadedStrings #-}
module Store where


import Database.SQLite.Simple
import Types
import Data.Aeson
import Data.Foldable


newtype Store =
  Store { path :: String
        }

append :: [Types.Event] -> IO ()
append events = do
  withConnection "candidate.db" $ \conn ->
    traverse_ (execute conn "insert into candidate (content) values (?)" . Only . encode) events


readAll :: IO [Event]
readAll =
  withConnection "candidate.db" $ \conn ->
      query_ conn "select content from candidate"
