if status is-interactive
    for f in ~/.config/fish/config/*.fish
        source $f
    end

    source ~/.config/fish/themes/kanagawa.fish
end
