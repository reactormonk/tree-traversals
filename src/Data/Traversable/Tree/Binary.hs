{-# OPTIONS_GHC -Wno-unused-top-binds #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE ScopedTypeVariables #-}
-- |
-- Different traversals for 'Data.Tree.Binary.Tree' from "Data.Tree.Binary".
--
module Data.Traversable.Tree.Binary 
  ( inorder, InOrder(..)
  , preorder, PreOrder(..)
  , postorder, PostOrder(..)
  , levelorder, LevelOrder(..)
  , rlevelorder, RLevelOrder(..)
  ) where

import Data.Traversable (foldMapDefault)

import Control.Applicative.Batch
import Data.Tree.Binary

-- $setup
-- >>> import Text.Show.Pretty (pPrint)
-- >>> :set -interactive-print pPrint

-- | 
-- Traverse the nodes of a tree from left-most to right-most.
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> _ <- inorder print example
-- [L,L]
-- [L,L,R]
-- [L]
-- [L,R,L]
-- [L,R,L,R]
-- [L,R]
-- []
-- [R]
-- [R,R,L]
-- [R,R]
-- [R,R,R]
inorder :: Applicative f => (a -> f b) -> Tree a -> f (Tree b)
inorder _ Leaf = pure Leaf
inorder f (Branch a la ra) = (\lb b rb -> Branch b lb rb) <$> inorder f la <*> f a <*> inorder f ra

-- | 
-- Traverse each node of the tree, then its left-subtree, then its right-subtree.
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> _ <- preorder print example
-- []
-- [L]
-- [L,L]
-- [L,L,R]
-- [L,R]
-- [L,R,L]
-- [L,R,L,R]
-- [R]
-- [R,R]
-- [R,R,L]
-- [R,R,R]
preorder :: Applicative f => (a -> f b) -> Tree a -> f (Tree b)
preorder _ Leaf = pure Leaf
preorder f (Branch a la ra) = Branch <$> f a <*> preorder f la <*> preorder f ra

-- | 
-- Traverse each node after traversing its left and right subtrees.
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> _ <- postorder print example
-- [L,L,R]
-- [L,L]
-- [L,R,L,R]
-- [L,R,L]
-- [L,R]
-- [L]
-- [R,R,L]
-- [R,R,R]
-- [R,R]
-- [R]
-- []
postorder :: Applicative f => (a -> f b) -> Tree a -> f (Tree b)
postorder _ Leaf = pure Leaf
postorder f (Branch a la ra) = (\lb rb b -> Branch b lb rb) <$> postorder f la <*> postorder f ra <*> f a

-- | 
-- Traverse each node of the tree in breadth-first order, left-to-right (i.e. all
-- nodes of depth zero, then all nodes of depth 1, then all nodes of depth 2,
-- etc.)
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> _ <- levelorder print example
-- []
-- [L]
-- [R]
-- [L,L]
-- [L,R]
-- [R,R]
-- [L,L,R]
-- [L,R,L]
-- [R,R,L]
-- [R,R,R]
-- [L,R,L,R]
levelorder :: Applicative f => (a -> f b) -> Tree a -> f (Tree b)
levelorder f = topDown $ \case
  Leaf           -> pure Leaf
  Branch a la ra -> Branch <$> lift (f a) <*> batch la <*> batch ra

-- | 
-- Traverse each node of the tree in breadth-last order, left-to-right (i.e. all
-- nodes of depth n, then all nodes of depth n-1, then all nodes of depth n-2,
-- etc.)
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> _ <- rlevelorder print example
-- [L,R,L,R]
-- [L,L,R]
-- [L,R,L]
-- [R,R,L]
-- [R,R,R]
-- [L,L]
-- [L,R]
-- [R,R]
-- [L]
-- [R]
-- []
rlevelorder :: Applicative f => (a -> f b) -> Tree a -> f (Tree b)
rlevelorder f = bottomUp $ \case
  Leaf           -> pure Leaf
  Branch a la ra -> Branch <$> lift (f a) <*> batch la <*> batch ra

-- | 'Tree' wrapper to use 'inorder' traversal
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> mapM_ print $ InOrder example
-- [L,L]
-- [L,L,R]
-- [L]
-- [L,R,L]
-- [L,R,L,R]
-- [L,R]
-- []
-- [R]
-- [R,R,L]
-- [R,R]
-- [R,R,R]
newtype InOrder a = InOrder { getInOrder :: Tree a }
  deriving Functor
instance Foldable InOrder where
  foldMap = foldMapDefault
instance Traversable InOrder where
  traverse f = fmap InOrder . inorder f . getInOrder

-- | 'Tree' wrapper to use 'preorder' traversal
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> mapM_ print $ PreOrder example
-- []
-- [L]
-- [L,L]
-- [L,L,R]
-- [L,R]
-- [L,R,L]
-- [L,R,L,R]
-- [R]
-- [R,R]
-- [R,R,L]
-- [R,R,R]
newtype PreOrder a = PreOrder { getPreOrder :: Tree a }
  deriving Functor
instance Foldable PreOrder where
  foldMap = foldMapDefault
instance Traversable PreOrder where
  traverse f = fmap PreOrder . preorder f . getPreOrder

-- | 'Tree' wrapper to use 'postorder' traversal
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> mapM_ print $ PostOrder example
-- [L,L,R]
-- [L,L]
-- [L,R,L,R]
-- [L,R,L]
-- [L,R]
-- [L]
-- [R,R,L]
-- [R,R,R]
-- [R,R]
-- [R]
-- []
newtype PostOrder a = PostOrder { getPostOrder :: Tree a }
  deriving Functor
instance Foldable PostOrder where
  foldMap = foldMapDefault
instance Traversable PostOrder where
  traverse f = fmap PostOrder . postorder f . getPostOrder

-- | 'Tree' wrapper to use 'levelorder' traversal
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> mapM_ print $ LevelOrder example
-- []
-- [L]
-- [R]
-- [L,L]
-- [L,R]
-- [R,R]
-- [L,L,R]
-- [L,R,L]
-- [R,R,L]
-- [R,R,R]
-- [L,R,L,R]
newtype LevelOrder a = LevelOrder { getLevelOrder :: Tree a }
  deriving Functor
instance Foldable LevelOrder where
  foldMap = foldMapDefault
instance Traversable LevelOrder where
  traverse f = fmap LevelOrder . levelorder f . getLevelOrder

-- | 'Tree' wrapper to use 'rlevelorder' traversal
--
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
-- >>> mapM_ print $ RLevelOrder example
-- [L,R,L,R]
-- [L,L,R]
-- [L,R,L]
-- [R,R,L]
-- [R,R,R]
-- [L,L]
-- [L,R]
-- [R,R]
-- [L]
-- [R]
-- []
newtype RLevelOrder a = RLevelOrder { getRLevelOrder :: Tree a }
  deriving Functor
instance Foldable RLevelOrder where
  foldMap = foldMapDefault
instance Traversable RLevelOrder where
  traverse f = fmap RLevelOrder . rlevelorder f . getRLevelOrder

{------------------------------------------------------------------------------
 - EXAMPLE HELPER FUNCTIONS
 ------------------------------------------------------------------------------}

data Direction = L | R
  deriving (Show, Eq, Enum)

type Path = [Direction]

-- |
-- >>> prettyPrint Leaf
-- ●
-- >>> prettyPrint (Branch [] Leaf $ Branch [R] Leaf $ Branch [R,R] Leaf Leaf)
--     []
-- ┌───┴───┐
-- ●      [R]
--      ┌──┴──┐
--      ●   [R,R]
--           ┌┴┐
--           ● ●
prettyPrint :: Show a => Tree a -> IO ()
prettyPrint = \t -> let (_,_,xs) = draw t in mapM_ putStrLn xs where
  draw :: Show a => Tree a -> (Int, Int, [String])
  draw Leaf = (1, 0, ["●"])
  draw (Branch a l r) = (w, c, top : next : outerMeld lb rb)
    where (lw,lc,lb) = draw l
          (rw,rc,rb) = draw r
          -- make both branches equidistant from the center
          rc' = max rc (lw - 1 - lc)
          rw' = rw - rc + rc'
          lw' = lc + 1 + rc'

          as = show a
          aw = length as
          alw = (aw - 1) `div` 2
          arw = aw - 1 - alw
          c = max lw' alw
          w = c + 1 + max rw' arw

          top = replicate (c - alw) ' ' ++ as
          next = concat
            [ replicate (c - lw' + lc) ' '
            , "┌"
            , replicate (lw' - 1 - lc) '─'
            , "┴"
            , replicate rc' '─'
            , "┐"
            ]
          meld ls rs = concat
            [ replicate (c - lw') ' '
            , take (lw' + 1) $ ls ++ repeat ' '
            , replicate (rc' - rc) ' '
            , rs
            ]
          outerMeld (x:xs) (y:ys) = meld x y : outerMeld xs ys
          outerMeld (x:xs) [] = meld x "" : outerMeld xs []
          outerMeld [] (y:ys) = meld "" y : outerMeld [] ys
          outerMeld [] [] = []

-- |
-- >>> prettyPrint balanced
--            []
--      ┌─────┴─────┐
--     [L]         [R]
--   ┌──┴──┐     ┌──┴──┐
-- [L,L] [L,R] [R,L] [R,R]
--  ┌┴┐   ┌┴┐   ┌┴┐   ┌┴┐ 
--  ● ●   ● ●   ● ●   ● ● 
balanced :: Tree Path
balanced =
  Branch []
    ( Branch [L]
      ( Branch [L,L] Leaf Leaf )
      ( Branch [L,R] Leaf Leaf )
    )
    ( Branch [R]
      ( Branch [R,L] Leaf Leaf )
      ( Branch [R,R] Leaf Leaf )
    )


-- |
-- >>> prettyPrint example
--                                                []
--                     ┌──────────────────────────┴──────────────────────────┐
--                    [L]                                                   [R]
--     ┌───────────────┴───────────────┐                             ┌───────┴───────┐
--   [L,L]                           [L,R]                           ●             [R,R]
-- ┌───┴───┐                 ┌─────────┴─────────┐                               ┌───┴───┐
-- ●    [L,L,R]           [L,R,L]                ●                            [R,R,L] [R,R,R]
--        ┌┴┐           ┌────┴────┐                                             ┌┴┐     ┌┴┐
--        ● ●           ●     [L,R,L,R]                                         ● ●     ● ●
--                               ┌┴┐                                 
--                               ● ●                                 
example :: Tree Path
example = 
  Branch []
  ( Branch [L]
    ( Branch [L,L]
      Leaf
      ( Branch [L,L,R]
        Leaf
        Leaf
      )
    )
    ( Branch [L,R]
      ( Branch [L,R,L]
        Leaf 
        ( Branch [L,R,L,R]
          Leaf
          Leaf
        )
      )
      Leaf
    )
  )
  ( Branch [R]
    Leaf
    ( Branch [R,R]
      ( Branch [R,R,L]
        Leaf
        Leaf
      )
      ( Branch [R,R,R]
        Leaf
        Leaf
      )
    )
  )

