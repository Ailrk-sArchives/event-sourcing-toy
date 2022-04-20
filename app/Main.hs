{-# LANGUAGE NoOverloadedStrings #-}
module Main where


import Data.Aeson
import Store
import Data.List
import Types
import qualified Data.Text as T
import Data.Maybe

newtype State = State [Candidate] deriving Show


initState :: State
initState = State []

interp :: State -> Event -> State
interp (State candidates) (CandidateAdded candidate) = State (candidate : candidates)
interp (State candidates) (CandidateDeleted id) = State $ updateCandidate candidates id (const Nothing)
interp (State candidates) (CandidateInterviewPassed id) = State $ updateCandidate candidates id (\can -> Just $ can { status = InterviewPassed })
interp (State candidates) (CandidateTestPassed id) = State $ updateCandidate candidates id (\can -> Just $ can { status = TestPassed })
interp state _ = state

decide :: Command -> [Event]
decide (AddCandidate can) = [CandidateAdded can]
decide (DeleteCandidate id) = [CandidateDeleted id]
decide (PassCandidateInterview id) = [CandidateInterviewPassed id]
decide (PassCandidateTest id) = [CandidateTestPassed id]

updateCandidate :: [Candidate] -> Integer -> (Candidate -> Maybe Candidate) -> [Candidate]
updateCandidate candidates id update =
  fromMaybe [] $ do
    can <- find (\can -> cid can == id) candidates
    let rest = filter (\candidate -> cid candidate /= id) candidates
    return $
      case update can of
        Just can1 -> can1 : rest
        _ -> rest

main :: IO ()
main = do
  let events = mconcat $ fmap decide
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

  do
    print $ foldl interp initState events
    append events

  do
    events1 <- readAll
    print $ foldl interp initState events
  return ()
