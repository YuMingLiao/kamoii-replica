{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Replica.VDOM (
    module Replica.VDOM,
    module Replica.VDOM.Types,
    module Replica.VDOM.Diff,
    module Replica.VDOM.Render,
) where

import qualified Data.ByteString as B
import qualified Data.FileEmbed as FE
import qualified Data.Map as M
import qualified Data.Text as T
import qualified Data.Text.Encoding as T

import Replica.VDOM.Diff (AttrDiff, Diff, diff, diffAttrs, patch, patchAttrs)
import Replica.VDOM.Render (renderHTML)
import Replica.VDOM.Types (Attr (ABool, AEvent, AMap, AText), Attrs, DOMEvent(DOMEvent), HTML, VDOM (VLeaf, VNode, VRawText, VText))

t :: T.Text -> T.Text
t = id

type Path = [Int]

fireWithAttrs :: Attrs -> T.Text -> DOMEvent -> Maybe (IO ())
fireWithAttrs attrs evtName evtValue = case M.lookup evtName attrs of
  Just (AEvent _ attrEvent) -> Just (attrEvent evtValue)
  _ -> Nothing

-- Actually, it doens't fire right away since result is `Myabe (IO ())'.
fireEvent :: HTML -> Path -> T.Text -> DOMEvent -> Maybe (IO ())
fireEvent _ [] = \_ _ -> Nothing
fireEvent ds (x : xs) =
    if x < length ds
        then fireEventOnNode (ds !! x) xs
        else \_ _ -> Nothing
  where
    fireEventOnNode (VNode _ attrs _ns _) [] = fireWithAttrs attrs
    fireEventOnNode (VLeaf _ attrs _ns) [] = fireWithAttrs attrs
    fireEventOnNode (VNode _ _ _ns children) (p:ps) = if p < length children
      then fireEventOnNode (children !! p) ps
      else \_ _ -> Nothing
    fireEventOnNode _ _ = \_ _ -> Nothing

clientDriver :: B.ByteString
clientDriver = $(FE.embedFile "./js/dist/client.js")

defaultIndex :: T.Text -> HTML -> HTML
defaultIndex title header =
    [ VLeaf "meta" (fl [("charset", AText "utf-8")]) Nothing
    , VLeaf "!doctype" (fl [("html", ABool True)]) Nothing
    , VNode
        "html"
        mempty
        Nothing
        [ VNode "head" mempty Nothing ([VNode "title" mempty Nothing [VText title]] <> header)
        , VNode
            "body"
            mempty
            Nothing
            [ VNode
                "script"
                (fl [("language", AText "javascript")])
                Nothing
                [VRawText $ T.decodeUtf8 clientDriver]
            ]
        ]
    ]
  where
    fl = M.fromList

ssrHtml :: T.Text -> T.Text -> HTML -> HTML -> HTML
ssrHtml title wsPath header body =
    [ VLeaf "!doctype" (fl [("html", ABool True)]) Nothing
    , VNode
        "html"
        mempty
        Nothing
        [ VNode "head" mempty Nothing $
            [ VLeaf "meta" (fl [("charset", AText "utf-8")]) Nothing
            , VNode "title" mempty Nothing [VText title]
            ]
                <> header
        , VNode
            "body"
            (fl [("data-replica-ws-path", AText wsPath)])
            Nothing
            [ VNode "div" (fl [("data-app", AText "replica")]) Nothing body
            , VNode
                "script"
                (fl [("language", AText "javascript")])
                Nothing
                [VRawText $ T.decodeUtf8 clientDriver]
            ]
        ]
    ]
  where
    fl = M.fromList
