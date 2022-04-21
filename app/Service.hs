{-# LANGUAGE OverloadedStrings #-}
module Service where

import Types
import Data.Maybe ( fromMaybe )
import Data.List ( find )

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
