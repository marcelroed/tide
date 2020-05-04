function lean_configure
    if test $COLUMNS -lt 55 || test $LINES -lt 21
        echo 'Terminal size too small; must be at least 55 x 21'
        return 1
    end

    set -g fishPrompt "$__fish_config_dir/functions/fish_prompt.fish"
    set -g fakePrompt "$__fish_config_dir/lean_theme/fake_prompt.fish"

    set -g columns $COLUMNS
    if test $columns -gt 100
        set -g columns 100
    end
    set -g lines $LINES

    _begin
end

function _begin
    _setDefaults
    _promptTime
end

function _setDefaults
    if test $lines -ge 26
        set -g new_line true
    else
        set -g new_line false
    end
    set -g prompt_height 2
    set -g fake_lean_time_format ''
    set -g fake_lean_prompt_connection ' '
    set -g fake_lean_prompt_connection_color 6C6C6C
end

function _promptTime
    _title 'Show current time?'

    _option 1 'No'
    _displayPrompt fake_lean_time_format ''

    _option 2 '24-hour format'
    _displayPrompt fake_lean_time_format '%T'

    _option 3 '12-hour format'
    _displayPrompt fake_lean_time_format '%r'

    _displayRestartAndQuit

    switch (_menu 'Choice' 1/2/3/r/q)
        case 1
            set -g fake_lean_time_format ''
            _promptHeight
        case 2
            set -g fake_lean_time_format '%T'
            _promptHeight
        case 3
            set -g fake_lean_time_format '%r'
            _promptHeight
        case r
            _begin
        case q
            _quit
    end
end

function _promptHeight
    _title 'Prompt Height'

    _option 1 'One line'
    _displayPrompt prompt_height 1

    _option 2 'Two lines'
    _displayPrompt prompt_height 2

    _displayRestartAndQuit

    switch (_menu 'Choice' 1/2/r/q)
        case 1
            set -g prompt_height 1
            _promptSpacing
        case 2
            set -g prompt_height 2
            _promptConnection
        case r
            _begin
        case q
            _quit
    end
end

function _promptConnection
    _title 'Prompt Connection'

    _option 1 'Disconnected'
    _displayPrompt fake_lean_prompt_connection ' '

    _option 2 'Dotted'
    _displayPrompt fake_lean_prompt_connection '·'

    _option 3 'Solid'
    _displayPrompt fake_lean_prompt_connection '─'

    _displayRestartAndQuit

    switch (_menu 'Choice' 1/2/3/r/q)
        case 1
            set -g fake_lean_prompt_connection ' '
            _promptSpacing
        case 2
            set -g fake_lean_prompt_connection '·'
            _promptConnectionColor
        case 3
            set -g fake_lean_prompt_connection '─'
            _promptConnectionColor
        case r
            _begin
        case q
            _quit
    end
end

function _promptConnectionColor
    _title 'Connection Color'

    _option 1 'Lightest'
    _displayPrompt fake_lean_prompt_connection_color 808080

    _option 2 'Light'
    _displayPrompt fake_lean_prompt_connection_color 6C6C6C

    _option 3 'Dark'
    _displayPrompt fake_lean_prompt_connection_color 585858

    _option 4 'Darkest'
    _displayPrompt fake_lean_prompt_connection_color 444444

    _displayRestartAndQuit

    switch (_menu 'Choice' 1/2/3/4/r/q)
        case 1
            set -g fake_lean_prompt_connection_color 808080
            _promptSpacing
        case 2
            set -g fake_lean_prompt_connection_color 6C6C6C
            _promptSpacing
        case 3
            set -g fake_lean_prompt_connection_color 585858
            _promptSpacing
        case 4
            set -g fake_lean_prompt_connection_color 444444
            _promptSpacing
        case r
            _begin
        case q
            _quit
    end
end

function _promptSpacing
    _title 'Prompt Spacing'

    _option 1 'Compact'
    _displayPrompt new_line true
    echo -ne '\r\033[1A'
    _displayPrompt new_line false

    _option 2 'Sparse'
    _displayPrompt new_line true
    echo -ne '\r\033[1A'
    _displayPrompt new_line true

    _displayRestartAndQuit

    switch (_menu 'Choice' 1/2/r/q)
        case 1
            set -g new_line false
            _finish
        case 2
            set -g new_line true
            _finish
        case r
            _begin
        case q
            _quit
    end
end

function _assemblePrompt -a whichPrompt
    set -g moduleDir "$__fish_config_dir/lean_theme/prompt_modules/$whichPrompt""_prompt"

    if test "$whichPrompt" = 'fish'
        set -g promptDir $fishPrompt
    else
        set -g promptDir $fakePrompt
    end

    echo -n >$promptDir

    _addMod 1_initial
    if test "$new_line" = 'true'
        _addMod 2_newline
    end
    _addMod '3_'$prompt_height'Line'
    _addMod 4_final
    if test $prompt_height -eq 1
        _addMod 5_rightPrompt
    else
        _addMod 5_rPromptNoColor
    end
end

function _addMod -a file
    cat "$moduleDir/$file.fish" >>$promptDir
    printf '\n\n' >>$promptDir
end

function _title -a title
    clear
    set -l midCols (math $columns/2)
    set -l midTitle (math (string length $title)/2)

    for i in (seq (math $midCols-$midTitle))
        echo -n ' '
    end
    set_color -o
    echo $title
    set_color normal
end

function _option -a symbol text
    set_color -o
    echo "($symbol) $text"
    set_color normal
end

function _displayPrompt -a var_name var_value
    set -g $var_name $var_value

    _assemblePrompt fake
    source $promptDir
    fake_prompt

    printf '\n\n'
end

function _displayRestartAndQuit
    echo -e '(r)  Restart from the beginning\n'
    echo -e '(q)  Quit and do nothing\n'
end

function _quit
    functions -e fish_right_prompt
    source $fishPrompt
    clear
end

function _finish
    _title 'Overwrite fish_prompt?'

    _option y 'Yes'
    printf '\n\n'

    _option n 'No'
    printf '\n\n'

    switch (_menu 'Choice' y/n)
        case y
            _assemblePrompt fish
            set -U lean_prompt_connection_icon $fake_lean_prompt_connection
            set -U lean_prompt_connection_color $fake_lean_prompt_connection_color
            if test $fake_lean_time_format = ''
                if contains 'time' $lean_right_prompt_items
                    set -e lean_right_prompt_items[(contains -i 'time' $lean_right_prompt_items)]
                end
                set -e lean_time_format
            else
                set -a lean_right_prompt_items 'time'
                set -U lean_time_format $fake_lean_time_format
            end
        case n
    end

    _quit
end

function _menu -a question options
    set -l optionList (string split '/' $options)
    set -l bold (set_color -o)
    set -l norm (set_color normal)

    while true
        read -P $bold"$question [$options] "$norm input

        if contains $input $optionList
            echo $input
            break
        end
    end
end