# 3. forever IO monad and join act in an STM monad

Date: 2024-10-17

## Status

Accepted (Found)

## Context

fireLoop wants to when getting a new frame, ignore events from past frame,
when a step is still blocking (frame is available to users), fire dispatchable events.
If not, ignore it too.

frameFire seems only for one frame, which is reasonable.

## Decision

join act to recurse (not setting new frames but wait for frame events)
when reach pure () or other IO action, means act is done and forever will get new frame.

## Consequences

