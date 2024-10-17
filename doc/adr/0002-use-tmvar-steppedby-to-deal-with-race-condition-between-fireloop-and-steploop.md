# 2. use TMVar steppedBy to deal with race condition between fireLoop and stepLoop

Date: 2024-10-17

## Status

Accepted (Found)

## Context

unknown

## Decision

use TMVar to deal with race condition between firing events and stepping frames

alternative:
synchron hasn't implemented orr io so maybe it's not an option for this context.
But synchron is logical event time, so maybe fireLoop can orr [await newFrame, await clientEvent' >> fire (loop)]
and stepLoop can emit steppedBy/newFrame

eventLoop: forever $ receiveData conn; emit clientEvent
can emit e replace EventQueue : TQueue?

frameLoop: sendTextData ReplaceDOM first then forever sendTextData conn UpdateDOM
frameLoop's newerFrame comes from Session { sesFrame }. setNewFrame renew it. So maybe emit works.
await newFrame or await terminate


setNewFrame and getNewFrame" fv is a TVar (frame0, r)
steppedBy <- setNewFrame
(frame,steppedBy) <- getNewFrame

## Consequences

unstructured, implicit programming flow
