# function untargz
#     pv $argv | tar -xz
# end

function untargz
    if test (count $argv) -eq 0
        echo "usage: untargz <archive.tar.gz> [destination]"
        return 1
    end

    set file $argv[1]
    set dir $argv[2]

    if test -z "$dir"
        pv "$file" | tar -xz
    else
        pv "$file" | tar -xz -C "$dir"
    end
end
