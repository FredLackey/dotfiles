#!/usr/bin/osascript

-- import_themes.applescript
-- Imports all .terminal files and sets Solarized Dark as default

tell application "Terminal"
    
    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    local scriptPath
    local terminalFiles
    local themeName
    
    set themeName to "Solarized Dark"
    
    -- Store the IDs of all the open terminal windows
    set initialOpenedWindows to id of every window
    
    -- Import all .terminal files in the current directory
    set terminalFiles to do shell script "ls *.terminal 2>/dev/null || echo ''"
    
    if terminalFiles is not "" then
        set AppleScript's text item delimiters to return
        set terminalFileList to text items of terminalFiles
        set AppleScript's text item delimiters to ""
        
        repeat with terminalFile in terminalFileList
            try
                do shell script "open '" & terminalFile & "'"
                delay 0.5
            end try
        end repeat
    end if
    
    -- Wait a moment for themes to be imported
    delay 2
    
    -- Set the custom theme as the default terminal theme
    try
        set default settings to settings set themeName
    on error
        -- If the theme doesn't exist, try to find an available theme
        set availableSettings to name of every settings set
        if availableSettings contains themeName then
            set default settings to settings set themeName
        else
            -- Use the first available theme as fallback
            if (count of availableSettings) > 0 then
                set default settings to settings set (item 1 of availableSettings)
            end if
        end if
    end try
    
    -- Get the IDs of all the currently opened terminal windows
    set allOpenedWindows to id of every window
    
    -- Apply theme to existing windows
    repeat with windowID in allOpenedWindows
        if initialOpenedWindows contains windowID then
            try
                set current settings of tabs of (every window whose id is windowID) to settings set themeName
            on error
                -- If theme doesn't exist, use default
                set current settings of tabs of (every window whose id is windowID) to default settings
            end try
        end if
    end repeat
    
    -- Close any additional windows that were opened for importing
    repeat with windowID in allOpenedWindows
        if initialOpenedWindows does not contain windowID then
            close (every window whose id is windowID)
        end if
    end repeat
    
end tell

return "Terminal themes imported successfully. Default theme set to: " & themeName
