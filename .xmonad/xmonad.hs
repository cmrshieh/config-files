import XMonad
import XMonad.Util.EZConfig
import XMonad.Hooks.SetWMName
import XMonad.Config.Gnome
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Actions.Submap
import XMonad.Actions.UpdatePointer

import Control.Arrow
import Data.Bits
import qualified Data.Map as M
import Data.Monoid

main = xmonad $ gnomeConfig
       { terminal = "mate-terminal"
       , modMask = mod4Mask -- set the mod key to the windows key
       , startupHook = setWMName "LG3D"
       , layoutHook  = smartBorders (layoutHook gnomeConfig)
       , manageHook = composeAll
                      [ manageHook gnomeConfig
                      , isFullscreen --> doFullFloat
                      , title =? "VLC (XVideo output)" --> doFullFloat
                      ]
       , normalBorderColor  = "#0D1012"
       , focusedBorderColor = "#082832"
       , borderWidth = 1
       }
       `additionalKeysP`
       [("M-f", fullFloatFocused)
       ]

fullFloatFocused =
    withFocused $ \f -> windows =<< appEndo `fmap` runQuery doFullFloat f
