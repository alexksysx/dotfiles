--- a/rc.lua	2020-06-21 22:41:05.163006263 +0300
+++ b/rc.lua	2020-06-21 22:40:54.000000000 +0300
@@ -121,10 +121,13 @@
 --                                     menu = mymainmenu })
 
 -- Wired Network widget
-net_wired = net_widgets.indicator({
-    interfaces  = {"enp3s0"},
-    timeout     = 5
-})
+--net_wired = net_widgets.indicator({
+--    interfaces  = {"enp3s0"},
+--    timeout     = 5
+--})
+
+net_wireless = net_widgets.wireless({interface   = "wlp2s0",
+                                     onclick     = terminal .. " -e wicd-curses" })
 
 -- Menubar configuration
 menubar.utils.terminal = terminal -- Set the terminal for applications that require it
@@ -270,7 +273,14 @@
             mykeyboardlayout,
             wibox.widget.systray(),
             mytextclock,
-            net_wired,
+            net_wireless,
+            wibox.widget{
+                markup = '    ',
+                align = 'center',
+                valign = 'center',
+                widget = wibox.widget.textbox
+            },
+            require("battery-widget") {},
             s.mylayoutbox,
         },
     }
@@ -339,7 +349,10 @@
     -- My bindings
     awful.key({ modkey,           }, "g",      function () awful.spawn("google-chrome --password-store=gnome") end,
               {description = "open google chrome", group = "launcher"}),
-
+    awful.key({ }, "XF86MonBrightnessDown", function ()
+              awful.util.spawn("xbacklight -dec 10") end),
+    awful.key({ }, "XF86MonBrightnessUp", function ()
+            awful.util.spawn("xbacklight -inc 10") end),
     awful.key({}, "Print", function () awful.spawn("scrot '%Y-%m-%d-%T_$wx$h_scrot.png' -e 'mv $f ~/Img/screen'") end,
               {description = "make screenshot", group = "awesome"}),
 
