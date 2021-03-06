-- base
import Control.Monad
import Data.Maybe
import System.Environment
import System.Exit

-- Hackage
import Data.Default
import System.Taffybar.Hooks.PagerHints (pagerHints)
import qualified Data.Map as M

-- Xmonad
import XMonad
import XMonad.Actions.Volume
import XMonad.Config.Desktop
import XMonad.Hooks.DynamicLog ()
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Prompt
import XMonad.Prompt.Pass
import XMonad.Wallpaper
import qualified XMonad.StackSet as W



myManageHook = composeAll
    [
      className =? "Pidgin"         --> doShift "1:chat"
    , className =? "Sylpheed"       --> doShift "1:chat"
    , className =? "Chromium"       --> doShift "2:web"
    , className =? "Google-chrome"  --> doShift "2:web"
    , className =? "Emacs"          --> doShift "3:code"
    , className =? "VirtualBox"     --> doShift "4:vm"
    , className =? "Kodi"           --> doShift "5:media"
    , className =? "scribus"        --> doShift "8:writing"
    , className =? "Okular"         --> doShift "7:reading"
    , resource  =? "desktop_window" --> doIgnore
    , className =? "Gimp"           --> doFloat
    , title     =? "pinentry-gtk-2" --> doFloat
    , resource  =? "gpicview"       --> doFloat
    , className =? "MPlayer"        --> doFloat
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)]



myLayout = avoidStruts (
    Tall 1 (3/100) (1/2)            |||
    Mirror (Tall 1 (3/100) (1/2))   |||
    tabbed shrinkText tabConfig     |||
    Full                            |||
    spiral (6/7))                   |||
    noBorders (fullscreenFull Full) |||
    layoutHook desktopConfig

tabConfig :: Theme
tabConfig = def {
    activeBorderColor   = "#7c7c7c",
    activeTextColor     = "#ceffac",
    activeColor         = "#000000",
    inactiveBorderColor = "#7c7c7c",
    inactiveTextColor   = "#eeeeee",
    inactiveColor       = "#000000"
}

-- Keys ------------------------------------------------------------------------

myModMask :: KeyMask
myModMask = mod4Mask

-- Apple Magic Keyboard with Numeric Keypad - US English
xK_XF86AudioMute :: KeySym
xK_XF86AudioMute = 0x1008FF12

xK_XF86XK_AudioLowerVolume :: KeySym
xK_XF86XK_AudioLowerVolume = 0x1008FF11

xK_XF86XK_AudioRaiseVolume :: KeySym
xK_XF86XK_AudioRaiseVolume = 0x1008FF13

-- xK_XF86XK_AudioPrev        = 0x1008FF16
-- xK_XF86XK_AudioNext        = 0x1008FF17
-- xK_XF86XK_AudioPlay        = 0x1008FF14

xK_XF86Eject :: KeySym
xK_XF86Eject = 0x1008FF2C

myKeys :: String -> XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys home_dir conf@XConfig {XMonad.modMask = modMask} = M.fromList $
  [
    -- launch a terminal
    ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

   -- Lock the screen using xscreensaver.
  , ((modMask .|. controlMask, xK_l), spawn "xscreensaver-command -lock")

  -- Launch dmenu via yeganesh.
  , ((modMask, xK_p),
     spawn $ "$(" ++ home_dir ++ "/.local/bin/yeganesh -x -- -fn '-*-terminus-*-r-normal-*-*-120-*-*-*-*-iso8859-*' -nb '#000000' -nf '#ffffff' -sb '#7c7c7c' -sf '#ceffac')")

  -- Lower, raise, mute volume.
  , ((0, xK_XF86XK_AudioLowerVolume), void (lowerVolume 3))
  , ((0, xK_XF86XK_AudioRaiseVolume), void (raiseVolume 3))
  , ((0, xK_XF86AudioMute), void toggleMute)

  -- Eject CD tray.
  , ((0, xK_XF86Eject), spawn "eject -T")

  -- pass(1) prompt
  , ((modMask .|. controlMask , xK_p), passPrompt ((def XPC) { font = "xft:Fira Mono:style=Bold" }))

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c), kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space), sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n), refresh)

  -- Move focus to the next window.
  , ((modMask, xK_Tab), windows W.focusDown)

  -- Move focus to the next window.
  , ((modMask, xK_j), windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k), windows W.focusUp)

  -- Move focus to the master window.
  , ((modMask, xK_m), windows W.focusMaster)

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return), windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j), windows W.swapDown)

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k), windows W.swapUp)

  -- Shrink the master area.
  , ((modMask, xK_h), sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l), sendMessage Expand)

  -- Push window back into tiling.
  , ((modMask, xK_t), withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma), sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period), sendMessage (IncMasterN (-1)))

  -- Quit xmonad.
  , ((modMask .|. shiftMask .|. controlMask, xK_q), io exitSuccess)

    -- Restart xmonad
    , ((modMask, xK_q), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modMask .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

  ]
  ++

  --
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  --
  [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]


-- Mouse bindings --------------------------------------------------------------
myMouseBindings :: XConfig l -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings XConfig {XMonad.modMask = modMask} = M.fromList
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1), \w -> focus w >> mouseMoveWindow w)

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), \w -> focus w >> windows W.swapMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w
                                          >> windows W.shiftMaster))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

main :: IO ()
main = do
    setRandomWallpaper ["$HOME/Pictures", "/void/pictures/wallpapers"]

    hd <- lookupEnv "HOME"
    let home_dir = fromMaybe "/home/adam/" hd

    let workspaces = ["1:chat","2:web","3:code","4:vm","5:media","6:extra", "7:reading", "8:writing", "9:misc"]

    xmonad $ ewmh $ pagerHints $ desktopConfig {
        -- simple stuff
        terminal           = "terminology",
        focusFollowsMouse  = True,
        borderWidth        = 4,
        modMask            = myModMask,
        workspaces         = workspaces,
        normalBorderColor  = "#7c7c7c",
        focusedBorderColor = "#ceffac",

        -- key bindings
        keys               = myKeys home_dir,
        mouseBindings      = myMouseBindings,

        -- hooks, layouts
        layoutHook         = smartBorders myLayout,
        manageHook         = myManageHook <+> manageHook desktopConfig,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = setWMName "LG3D" <+> myStartUpHook home_dir
    }

myStartUpHook :: String -> X ()
myStartUpHook home_dir = do
    spawn "setxkbmap -option ctrl:nocaps"
    -- spawn "xinput set-prop 'Logitech Trackball' 'libinput Accel Speed' 1"
    spawn "xscreensaver"
    spawn "arbtt-capture"
    spawn (home_dir ++ ".local/bin/taffybar")
    return ()


-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
