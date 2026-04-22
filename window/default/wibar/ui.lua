local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local InfoBar = {}

function InfoBar.spawn(beautiful)	
	-- Create a textclock widget
	mytextclock = wibox.widget.textclock()


	local function set_wallpaper(s)
	    -- Wallpaper
	    if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
		    wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	    end
	end

	-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
	-- screen.connect_signal("property::geometry", set_wallpaper)


	awful.screen.connect_for_each_screen(function(s)
		-- Wallpaper
		-- set_wallpaper(s)
	
		-- 1. Create the floating wibox
		s.center_overlay = wibox({
		    screen  = s,
		    width   = 675,  -- Adjust based on your text size
		    height  = 125,
		    ontop   = false, -- Keeps it above windows
		    visible = true, -- Makes it show up immediately
		    bg      = "#00000000", -- Transparent background
		    type    = "dock",      -- Ensures it doesn't get focus like a window
		})

		-- 2. Position it perfectly in the center of the screen
		awful.placement.centered(s.center_overlay)

		-- 3. Set the widget content
		s.center_overlay:setup {
		    {
			{
				layout = wibox.layout.fixed.vertical,
			    	spacing = 5, -- Adds a small gap between the text and the clock
			    {
				text   = "TAKE CONTROLL",
				font   = "Impact bold 34", -- Slightly smaller than the clock
				align  = "center",
				valign = "center",
				widget = wibox.widget.textbox,
			    },
			    {
				widget = wibox.widget.textclock("%H:%M:%S", 1),
				font   = "Impact bold 25",
				align  = "center",
				valign = "center",
			    },
			},
			widget = wibox.container.place,
		    },
		    widget = wibox.container.background,
		}
		-- Each screen has its own tag table.
		awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.fair)

		-- Create a promptbox for each screen
		s.mypromptbox = awful.widget.prompt()
		-- Create an imagebox widget which will contain an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		s.mylayoutbox = awful.widget.layoutbox(s)
		s.mylayoutbox:buttons(gears.table.join(
				   awful.button({ }, 1, function () awful.layout.inc( 1) end),
				   awful.button({ }, 3, function () awful.layout.inc(-1) end),
				   awful.button({ }, 4, function () awful.layout.inc( 1) end),
				   awful.button({ }, 5, function () awful.layout.inc(-1) end)))
		-- Create a taglist widget
		s.mytaglist = awful.widget.taglist {
			screen  = s,
			filter  = awful.widget.taglist.filter.all,
			}
			-- Create the wibox
			s.mywibox = awful.wibar({ position = "bottom",height= 30 ,screen = s, ontop = false })
			
			s.battery_widget = awful.widget.watch(
			    [[bash -c 'acpi | awk -F, "{if(\$1 ~ /Charging/) {print \"*\" \$2} else {print \$2}}"']], 
			    1,
			    function(widget, stdout)
				widget:set_text(" Bat: " .. stdout:gsub("%s+", "|"))
			    end
			)

			-- Add widgets to the wibox
			s.mywibox:setup {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				mylauncher,
				s.mytaglist,
				s.mypromptbox,
			},
			{ -- Middle widget
				widget = wibox.container.margin,
				left = 550,
				right = 350,
			},
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				s.battery_widget,
				mytextclock,
			},
		}
	end)
end

return InfoBar
