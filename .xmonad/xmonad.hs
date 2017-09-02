import XMonad
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
import XMonad.StackSet 
import XMonad.Actions.DynamicProjects
import qualified Data.Map as M

main = do 
    xmonad =<< statusBar "xmobar" myPP toggleStrutsKey (dynamicProjects projects $ myConfig)


myConfig = def {
      manageHook = myManageHook <+> manageDocks <+> manageHook def
    , layoutHook = myLayout
    , handleEventHook = handleEventHook def <+> docksEventHook
    , modMask = mod4Mask
    , borderWidth = 0
    , terminal = "terminator"
    , keys = myKeys <+> keys def
    , XMonad.workspaces = myWorkspaces
    } 

myPP = xmobarPP {ppOrder = \(ws:l:t:_) -> [ws, t]}
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)
myLayout = windowNavigation $ addTabs shrinkText myTabTheme $ subLayout [] (Simplest) $ spacingWithEdge 9 $ ResizableTall 1 (3/100) (2/3) [] ||| (layoutHook def)

myWorkspaces = 
    ["Web", "Terminals", "Work", "Misc"]

projects :: [Project]
projects = 
    [ Project { projectName = "Misc"
              , projectDirectory = "~/Downloads"
              , projectStartHook = Just $ do spawn "terminator"
                                             spawn "evince" }

    , Project { projectName = "Terminals"
              , projectDirectory = "~/.config"
              , projectStartHook = Just $ do spawn "terminator"
                                             spawn "terminator"
                                             safeRunInTerm "" "vim ~/.xmobarrc" }

    ]
                                          


myManageHook = composeAll 
                [ name =? "Terminator Preferences" --> doCenterFloat
                , className =? "Thunar" --> doCenterFloat]
                where name = stringProperty "WM_NAME"
         
myTabTheme = def
    { fontName = "xft:xos4 Terminus:size=15"
--    , activeColor           = blue
--    , inactiveColor         = base02
--    , activeBorderColor     = blue
--    , inactiveBorderColor   = base02
--    , activeTextColor       = base03
--    , inactiveTextColor     = base00
}
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
            [ ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L)
            , ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R)
            , ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U)
            , ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D)
            
            , ((modm .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
            , ((modm .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))
            --, ((modm .|. controlMask, xK_j), sendMessage $ Go D)
            --, ((modm .|. controlMask, xK_k), sendMessage $ Go U)
            --, ((modm .|. controlMask, xK_h), sendMessage $ Go L)
            --, ((modm .|. controlMask, xK_l), sendMessage $ Go R)
            , ((modm, xK_s), switchProjectPrompt myPrompt)
            , ((modm, xK_slash), shiftToProjectPrompt myPrompt)
            , ((modm, xK_z), sendMessage MirrorExpand)
            , ((modm, xK_a), sendMessage MirrorShrink)
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

topBarTheme = def
    { inactiveBorderColor   = base03
    , inactiveColor         = base03
    , inactiveTextColor     = base03
    , activeBorderColor     = blue
    , activeColor           = blue
    , activeTextColor       = blue
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = 10
    }

