import XMonad
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run


main = do 
    xmonad =<< statusBar "xmobar" myPP toggleStrutsKey (def {
      manageHook = manageDocks <+> manageHook def
    , layoutHook = spacingWithEdge 8 $ layoutHook def
    , handleEventHook = handleEventHook def <+> docksEventHook
    , modMask = mod4Mask
    , borderWidth = 0
    , terminal = "terminator"
    })

myPP = xmobarPP {ppOrder = \(ws:l:t:_) -> [ws, t]}
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

