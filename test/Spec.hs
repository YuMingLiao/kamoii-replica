{-# LANGUAGE StandaloneDeriving #-}

module Main where

import           Data.Monoid
import qualified Data.Text as T

import           Test.QuickCheck
import           Test.QuickCheck.Instances

import           Replica.VDOM
import           Replica.VDOM.Types

instance Arbitrary Attr where
  arbitrary = do
    t <- choose (0, 3) :: Gen Int
    case t of
      0 -> AText <$> arbitrary
      1 -> ABool <$> arbitrary
      2 -> AEvent <$> pure (EventOptions False False False) <*> pure (\_ -> pure ())
      3 -> AMap <$> arbitrary

instance Eq Attr where
  AText m == AText n = m == n
  ABool m == ABool n = m == n
  AEvent _ _ == AEvent _ _ = True
  AMap m   == AMap n = m == n

instance Show Attr where
  show (AText t)  = "AText " <> T.unpack t
  show (ABool t)  = "ABool " <> show t
  show (AEvent _ _) = "AEvent"
  show (AMap m)   = "AMap " <> show m
 
propAttrsDiff :: Attrs -> Attrs -> Bool 
propAttrsDiff a b = patchAttrs (diffAttrs a b) a == b

quickCheckAttrsDiff = quickCheckWith args propAttrsDiff
  where
    args = stdArgs { maxSize = 7, maxSuccess = 1000 }

--------------------------------------------------------------------------------

deriving instance Eq VDOM
deriving instance Show VDOM

instance Arbitrary VDOM where
  arbitrary = do
    t <- choose (0, 1) :: Gen Int
    case t of
      0 -> VNode <$> arbitrary <*> arbitrary <*> pure Nothing <*> arbitrary
      -- 1 -> VLeaf <$> arbitrary <*> arbitrary
      1 -> VText <$> arbitrary

propDiff :: HTML -> HTML -> Bool 
propDiff a b = patch (diff a b) a == b

quickCheckDiff a b = quickCheckWith args propDiff
  where
    args = stdArgs { maxSize = a, maxSuccess = b }

--------------------------------------------------------------------------------

main :: IO ()
main = do
  quickCheckAttrsDiff
  quickCheckDiff 4 1000
  quickCheckDiff 5 200
