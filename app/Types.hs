{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}
module Types where

import Data.Maybe
import Data.Aeson
import GHC.Generics
import Database.SQLite.Simple.FromRow
import qualified Data.Text as T

newtype State = State [Candidate] deriving (Generic, Show)

data Status = Begin  | InterviewPassed | TestPassed deriving (Generic, Show)

data Candidate = Candidate
  { name :: T.Text
  , cid :: Integer
  , status :: Status
  }
  deriving (Generic, Show)

type EventId = Integer
type StreamId = Integer
type ReadmodelId = Integer

data EventBox :: * where
  EventBox :: forall event.
    { event :: event
    , id :: EventId
    , stream :: StreamId
    }-> EventBox

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

instance ToJSON State
instance FromJSON State

instance ToJSON Status
instance FromJSON Status

instance ToJSON Candidate
instance FromJSON Candidate

instance ToJSON Command
instance FromJSON Command

instance ToJSON Event
instance FromJSON Event

instance FromRow Event where
  fromRow = fromMaybe NoOp . decode <$> field
