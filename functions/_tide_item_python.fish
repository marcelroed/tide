function _tide_item_python
    if test -n "$VIRTUAL_ENV"
        if command -q python3
            python3 --version | string match -qr "(?<v>[\d.]+)"
        else
            python --version | string match -qr "(?<v>[\d.]+)"
        end
        string match -qr "^.*/(?<dir>.*)/(?<base>.*)" $VIRTUAL_ENV
        # pipenv $VIRTUAL_ENV looks like /home/ilan/.local/share/virtualenvs/pipenv_project-EwRYuc3l
        # Detect whether we are using pipenv by looking for 'virtualenvs'. If so, remove the hash at the end.
        if test "$dir" = virtualenvs
            string match -qr "(?<base>.*)-.*" $base
            _tide_print_item python $tide_python_icon' ' "$v ($base)"
        else if contains -- "$base" virtualenv venv .venv env # avoid generic names
            _tide_print_item python $tide_python_icon' ' "$v ($dir)"
        else
            _tide_print_item python $tide_python_icon' ' "$v ($base)"
        end
    else if path is .python-version Pipfile __init__.py pyproject.toml requirements.txt setup.py
        if command -q python3
            python3 --version | string match -qr "(?<v>[\d.]+)"
        else
            python --version | string match -qr "(?<v>[\d.]+)"
        end
        _tide_print_item python $tide_python_icon' ' $v
    else if string match -q "*miniforge*" $(which python)
        python --version | string match -qr "(?<v>[\d.]+)"
        set vsplit (string split '.' $v)
        set vshort (string join '.' $vsplit[1] $vsplit[2])
        # string match -qr "^.*\/(?<envname>.*)" $CONDA_PREFIX

        # Check if base is active
        if string match -q "*/base/bin/*" $(which python)
            # In base
            set envname "base"
        else
            which python | string match -qr "envs\/(?<envname>.*)\/bin"
        end

        if test $envname = $vshort
            _tide_print_item python $tide_python_icon' ' "$envname"
        else
            _tide_print_item python $tide_python_icon' ' "$envname ($vshort)"
        end
    end
end
