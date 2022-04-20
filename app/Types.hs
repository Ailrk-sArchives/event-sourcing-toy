{-# LANGUAGE DeriveGeneric #-}
module Types where

import Data.Maybe
import Data.Aeson
import GHC.Generics
import Database.SQLite.Simple.FromRow
import qualified Data.Text as T

data Status = Begin  | InterviewPassed | TestPassed deriving (Generic, Show)

data Candidate = Candidate
  { name :: T.Text
  , cid :: Integer
  , status :: Status
  }
  deriving (Generic, Show)

data Event
  = CandidateAdded Candidate
  | CandidateDeleted Integer
  | CandidateInterviewPassed Integer
  | CandidateTestPassed Integer
  | NoOp
  deriving (Generic, Show)

data Command
  = AddCandidate Candidate
  | DeleteCandidate Integer
  | PassCandidateInterview Integer
  | PassCandidateTest Integer
  deriving (Generic, Show)

instance ToJSON Status
instance FromJSON Status

instance ToJSON Candidate
instance FromJSON Candidate

instance ToJSON Event
instance FromJSON Event

instance FromRow Event where
  fromRow = fromMaybe NoOp . decode <$> field
