import XMonad
import Data.Word
import qualified Data.List as L
import XMonad.Util.NamedWindows (getName)
import XMonad.Hooks.EwmhDesktops hiding (fullscreenEventHook)
import XMonad.Layout.TwoPane
import XMonad.Actions.GroupNavigation
import XMonad.Actions.WindowBringer
import XMonad.Actions.CycleWindows (cycleRecentWindows)
import XMonad.Actions.RotSlaves
import XMonad.Prompt.Shell
import XMonad.Layout.Hidden
import XMonad.Layout.DragPane
import XMonad.Actions.FloatKeys
import XMonad.Actions.DynamicWorkspaces 
import XMonad.Actions.CycleWS
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.Navigation2D
import XMonad.Util.NamedScratchpad
import XMonad.Prompt
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run
import XMonad.Layout.Tabbed
import XMonad.Layout  
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.BoringWindows
import XMonad.Layout.Simplest
import XMonad.Layout.Circle
import XMonad.Layout.NoFrillsDecoration
import XMonad.Hooks.ManageHelpers
import XMonad.ManageHook
import XMonad.Actions.DynamicProjects
import qualified Data.Map as M
import Data.Tree
import XMonad.Actions.TreeSelect
import XMonad.Hooks.WorkspaceHistory
import qualified XMonad.StackSet as W
import XMonad.Layout.Groups.Helpers
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Grid
import XMonad.Layout.Fullscreen
import XMonad.Hooks.InsertPosition
import XMonad.Layout.Groups.Examples
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.TrackFloating

main = do 
{-    xmonad =<< statusBar "xmobar" myPP toggleStrutsKey (withNavigation2DConfig def $ dynamicProjects projects $ fullscreenSupport $ myConfig)
-}
  --d <- spawnPipe "xmobar ~/.xmobarrc2"
--  spawn $ "pkill polybar"
--  spawn $ "sleep 2"
  spawn $ "~/scripts/polybar.sh"
  xmonad $ ewmh $ docks $ myConfig
   

-----------------------------------------------------------------------
--myLogHook h = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ def
--  { ppOutput = hPutStrLn h
--  , ppCurrent = xmobarColor "yellow" "" . wrap "" ""
--  , ppTitle = xmobarColor "green" "" . shorten 10 
--  , ppOrder = \(ws:l:t:_) -> [ws, t]
--  }

--myPP = namedScratchpadFilterOutWorkspacePP 
--     $ xmobarPP { ppOrder = \(ws:l:t:_) -> [ws, t]
--                , ppCurrent = xmobarColor "yellow" "" . wrap "" ""
--                , ppTitle = xmobarColor "green" "" . (shorten 20)
--                }

myConfig = def {
      manageHook = fullscreenManageHook <+> myManageHook <+> {-insertPosition Below Newer <+>-}manageDocks <+> manageHook def
    , handleEventHook = handleEventHook def <+> docksEventHook <+> fullscreenEventHook
    , modMask = mod4Mask
    , terminal = myTerminal
    , layoutHook = avoidStruts myLayoutHook
    , keys = myKeys <+> keys def
    , XMonad.workspaces = toWorkspaces myWorkspaces
    , borderWidth = 3
    , focusedBorderColor = "#b8bb26"
    , normalBorderColor = "#282828"
    --, logHook = myLogHook h
    , logHook = historyHook
 
    --, focusFollowsMouse = False
    --, startupHook = spawn "stalonetray"
    } 

myManageHook = (composeOne
                [ name =? "Terminator Preferences" -?> ((insertPosition Above Newer) <+> doCenterFloat)
                , isDialog -?> ((insertPosition Above Newer) <+> doCenterFloat)
                , className =? "Eog" -?> (insertPosition Below Older)
                , className =? "MATLAB R2017b - academic use" -?> (insertPosition Below Older)
                , className =? "feh" -?> (insertPosition Below Older)
                , className =? "okular" -?> (insertPosition Below Older)
                , className =? "Mirage" -?> (insertPosition Below Older)
                , className =? "Thunar" -?> doCenterFloat 
                , (return True) -?> (insertPosition Below Newer)])
                <+> namedScratchpadManageHook myScratchpads
                where name = stringProperty "WM_NAME"

--myManageHook = (composeOne
--                [ --name =? "Terminator Preferences" --> ((insertPosition Above Newer) <+> doCenterFloat)
--                 isDialog --> ((insertPosition Above Newer) <+> doCenterFloat)
--                , insertPosition Below Newer
--                , className =? "Thunar" --> doCenterFloat]) <+> namedScratchpadManageHook myScratchpads
--                where name = stringProperty "WM_NAME"
 
myTerminal = "terminator"
altMask = mod1Mask

myLayoutHook =
    onWorkspace "misc" miscLayout 
    $ onWorkspace "web" docsLayout
    $ onWorkspace "docs" docsLayout
    $ onWorkspace "media" mediaLayout
    $ onWorkspaces ["conf", "matlab"] (trackFloating mainLayout)
    otherLayout


myScratchpads = 
    [ NS "terminal" ("terminator --role=scratchpad") (stringProperty "WM_WINDOW_ROLE" =? "scratchpad") doCenterFloat
    , NS "slack" "slack" (stringProperty "WM_NAME" =? "Slack - Honors Physics II (Fall 2017)") doCenterFloat
    , NS "ranger" ("terminator --role=ranger -e ranger") (stringProperty "WM_WINDOW_ROLE" =? "ranger") (customFloating $ W.RationalRect 0.05 0.05 0.4 0.4)
    , NS "notes" "emacs" (stringProperty "WM_NAME" =? "emacs@namo") nonFloating
    ]

--subLayout has problem with trackFLoating?
mainModifier = 
    mkToggle (single FULL)
    . windowNavigation
    . addTabs shrinkText myTabTheme 
    . subLayout [] (Simplest ||| Full ||| dragPane Horizontal 0.5 0.5) 
    . spacing 7 

--webModifier = 
--    mkToggle (single FULL)
--    . windowNavigation
--    . spacingWithEdge 7
--    . trackFloating 

mainLayout = mainModifier (ResizableTall 1 (3/100) (56/100) [] ||| Full)
otherLayout = mainModifier (ResizableTall 1 (3/100) (50/100) [] ||| Full)
--webLayout = webModifier (Full ||| Tall 1 (3/100) (50/100))
docsLayout = 
    mkToggle (single FULL)
    $ windowNavigation
    $ spacingWithEdge 7
    $ trackFloating
    $ TwoPane (3/100) (1/2) ||| (Tall 1 (3/100) (1/2)) ||| Full

miscLayout = 
    mkToggle (single FULL)
    $ windowNavigation
    $ spacingWithEdge 7
    $ trackFloating
    $ (Grid ||| Full ||| Circle)

mediaLayout =
    mkToggle (single FULL)
    $ windowNavigation
    $ spacingWithEdge 7
    $ trackFloating
    $ (GridRatio (3/3) ||| Full)

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myWorkspaces :: Forest String
myWorkspaces = 
    [ Node "conf" []
    , Node "terms" []
    , Node "docs" []
    , Node "matlab" []
    , Node "media" []
    , Node "misc" []
    , Node "lisp" []
    , Node "web" []
    --, Node "web" []
    ]

--projects :: [Project]
--projects = 
--    [ Project { projectName = "misc"
--              , projectDirectory = "~/"
--              , projectStartHook = Just $ do runInTerm "" "htop"
--              }
--
--    , Project { projectName = "terms"
--              , projectDirectory = "~/"
--              , projectStartHook = Just $ do spawn "terminator"
--              }
--
--    , Project { projectName = "conf"
--              , projectDirectory = "~/"
--              , projectStartHook = Just $ do spawn "firefox"
--                                             spawn "terminator"
--              }
--
--   -- , Project { projectName = "prgm"
--   --           , projectDirectory = "~/MEGA"
--   --           , projectStartHook = Just $ do spawn "terminator"
--   --                                          spawn "terminator"
--   --                                          spawn "terminator"
--
--   --           }
--
--    , Project { projectName = "docs"
--              , projectDirectory = "~/MEGA"
--              , projectStartHook = Just $ do spawn "okular"
--
--              }
--
--   -- , Project { projectName = "hw"
--   --           , projectDirectory = "~/MEGA"
--   --           , projectStartHook = Just $ do spawn "firefox"
--   --                                          runInTerm "" "ranger"
--
--   --           }
--    
--    , Project { projectName = "web"
--              , projectDirectory = "~/"
--              , projectStartHook = Just $ do spawn "firefox"
--
--              }
--
--    ]
                                          
myTabTheme = def { fontName = "xft:xos4 Terminus:size=13"
                , decoHeight = 23
                 , activeTextColor = "#ffffff" --"#fbf1c7"
                 , inactiveTextColor = "#ebdbb2"
                 , inactiveColor = "#504945"
                 , inactiveBorderColor = "#504945"
                 , activeColor = blue --"#665c54"
                 , activeBorderColor = blue --"#665c54"
                 }

topBarTheme = def
    { inactiveBorderColor   = "#3c3836"
    , inactiveColor         = "#3c3836"
    , inactiveTextColor     = "#3c3836"
    , activeBorderColor     = blue --"#458588"
    , activeColor           = blue --"#458588"
    , activeTextColor       = blue
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = 15
    }

--Custom functions
--Alt-Tab behavior using GroupNavigation
sameWorkSpace = do
  nw <- ask
  liftX $ do
    ws <- gets windowset
    return $ maybe False (== W.currentTag ws) (W.findTag nw ws)

currentWsWindows :: Eq a => W.StackSet i l a s sd -> [a]
currentWsWindows = W.integrate' . W.stack . W.workspace . W.current

newtype Win = Win String
instance XPrompt Win where
  showXPrompt (Win _) = "select window: "

windowPrompt :: XPConfig -> ([(String, Window)] -> String -> X ()) -> X ()
windowPrompt conf job = do
  ss <- gets windowset
  let currentWindows = currentWsWindows ss -- :: [Window]
  winNames <- mapM (fmap (convertSpaces '_' . show) . getName) $ currentWindows --all window names in current workspace with spaces removed
  mkXPrompt (Win "") conf (mkComplFunFromList' $ winNames) (job $ zip winNames currentWindows )

selectWindow :: XPConfig -> X ()
selectWindow conf = windowPrompt conf job where --job takes a string (window name) and use focusWindow to focus
   job wList wName =
    case lookup wName wList of
      Nothing -> return ()
      Just win -> windows $ W.focusWindow win

convertSpaces :: Char -> String -> String
convertSpaces new = map (\c -> if c == ' ' then new else c)

appendNewLine :: String -> String
appendNewLine s = s ++ ['\n']

myPrompt2 = def
  { font = "xft:Droid Sans Mono for Powerline:size=13"
  , position = CenteredAt (1/2) (3/10)
  , height = 40
  , searchPredicate = L.isSubsequenceOf
  , maxComplRows = Just (fromIntegral 10 :: Word32)
}

--keybindings        

--keys to overwrite
--newKeys x = foldr M.delete (keys def x) (keysToRemove x)
--keysToRemove :: XConfig Layout -> [(KeyMask, KeySym)]
--keysToRemove x = M.fromList 
--    [ (modMask, xk_Tab)
--    ]

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
            [ ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L)
            , ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R)
            , ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U)
            , ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D)
            , ((modm, xK_d), spawn "rofi -show run -font \"Droid Sans Mono for Powerline 20\"")
            , ((modm, xK_e), spawn "emacsclient -c")
            , ((modm, xK_f), gotoMenu)
            , ((modm, xK_v), selectWindow myPrompt2)
            , ((modm .|. altMask, xK_l), spawn "i3lock -c 000000") 
            , ((modm .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
            , ((modm .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
            , ((modm .|. controlMask, xK_i), withFocused (sendMessage . UnMergeAll))
            --, ((altMask, xK_j), sendMessage $ Go D)
            --, ((altMask, xK_k), sendMessage $ Go U)
            --, ((altMask, xK_h), sendMessage $ Go L)
            --, ((altMask, xK_l), sendMessage $ Go R)
--            , ((modm, xK_s), switchProjectPrompt myPrompt)
--            , ((modm, xK_slash), shiftToProjectPrompt myPrompt)
            , ((modm, xK_z), sendMessage MirrorExpand)
            , ((modm, xK_a), sendMessage MirrorShrink)
            , ((modm, xK_g), sequence_ $ [sendMessage $ IncMasterN 1, sendMessage $ pullGroup D, sendMessage $ IncMasterN (-1)])
            -- caused white glitch, ((altMask, xK_f), treeselectWorkspace tsDefaultConfig myWorkspaces W.greedyView)
            --, ((modm, xK_n), namedScratchpadAction scratchpads "thunar")
           -- , ((modm .|. shiftMask, xK_BackSpace), removeWorkspace)
            , ((modm, xK_n), moveToNewGroupUp)
            , ((modm, xK_p), splitGroup)
            , ((modm, xK_grave), sequence_ $ [sendMessage ToggleStruts, sendMessage $ Toggle FULL])
            , ((altMask, xK_Tab), nextMatch History sameWorkSpace)
            , ((modm .|. shiftMask, xK_Tab), sequence_ $ [withFocused (sendMessage . UnMerge), sendMessage $ pullGroup L]) 
            , ((controlMask .|. shiftMask, xK_Tab), sequence_ $ [withFocused (sendMessage . UnMerge), sendMessage $ pullGroup D]) 

            --easy swapping of windows
            , ((modm .|. shiftMask, xK_h), windowSwap L False)
            , ((modm .|. shiftMask, xK_l), windowSwap R False)
            --, ((modm .|. shiftMask, xK_k), windowSwap U True)
            --, ((modm .|. shiftMask, xK_j), windowSwap D True)
            , ((modm .|. altMask, xK_j), windows W.swapDown)
            , ((modm .|. altMask, xK_k), windows W.swapUp)
            , ((altMask, xK_j), windowGo D False)
            , ((altMask, xK_k), windowGo U False)
            , ((altMask, xK_h), windowGo L False)
            , ((altMask, xK_l), windowGo R False)
            --, ((altMask, xK_Tab), windows W.focusDown)
            , ((altMask, xK_m), windows W.focusMaster)

            --easy switching of workspaces
            , ((modm, xK_Left), prevWS)
            , ((modm, xK_Right), nextWS)
            --, ((altMask, xK_Tab), cycleRecentWS [xK_Alt_L] xK_Tab xK_grave)
            , ((modm, xK_Tab), toggleWS' ["NSP"])

            --hiding windows
            , ((modm, xK_backslash), withFocused hideWindow)
            , ((modm .|. shiftMask, xK_backslash), popNewestHiddenWindow)

            --scratchpads
            , ((modm .|. controlMask, xK_n), namedScratchpadAction myScratchpads "terminal")
            , ((modm .|. controlMask, xK_b), namedScratchpadAction myScratchpads "slack")
            , ((modm .|. controlMask, xK_r), namedScratchpadAction myScratchpads "ranger")
            --, ((modm .|. controlMask, xK_v), namedScratchpadAction myScratchpads "notes")

            --moving floating windows
            --, ((modm,               xK_Down     ), withFocused (keysResizeWindow (-5,-5) (1,1)))
            --, ((modm,               xK_Up     ), withFocused (keysResizeWindow (5,5) (1,1)))
            --dynamic workspaces
            , ((modm .|. shiftMask, xK_BackSpace), removeWorkspace)
            , ((modm , xK_s      ), selectWorkspace myPrompt)
            , ((modm, xK_slash                    ), withWorkspace myPrompt (windows . W.shift))
            , ((modm .|. shiftMask, xK_r      ), renameWorkspace def)
            , ((modm, xK_w), addWorkspacePrompt myPrompt)
            , ((modm, xK_e), appendWorkspacePrompt myPrompt)

            --prompt
            , ((modm .|. altMask, xK_Return), shellPrompt myPrompt)

            -- sublayouts
            , ((modm .|. altMask, xK_space), toSubl NextLayout)
            , ((modm .|. altMask, xK_j), windows W.swapDown)
            , ((modm .|. altMask, xK_k), windows W.swapUp)
            , ((modm .|. altMask, xK_comma), toSubl (IncMasterN 1))
            , ((modm .|. altMask, xK_period), toSubl (IncMasterN (-1)))

            --twopane + rotslaves
            , ((altMask .|. shiftMask, xK_k), rotSlavesUp)
            , ((altMask .|. shiftMask, xK_j), rotSlavesDown)
            ]

myPrompt = def
  { font = "xft:Droid Sans Mono for Powerline:size=13"
  , position = CenteredAt (1/2) (1/2)
  , height = 40
  }

base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green = "#859900"


