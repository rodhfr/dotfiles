function dfsend
    set SERVER "http://192.168.1.150:12500"

    if test (count $argv) -eq 0
        echo "Uso: dfsend ARQUIVO_OU_PASTA [OUTRO...]"
        return 1
    end

    for PATH_TO_SEND in $argv

        if test -f $PATH_TO_SEND
            set FILENAME (basename $PATH_TO_SEND)
            echo "Enviando $FILENAME -> $SERVER/$FILENAME"
            curl -T "$PATH_TO_SEND" "$SERVER/$FILENAME"

        else if test -d $PATH_TO_SEND
            # Obter o diretório pai da pasta base
            set PARENT_DIR (dirname $PATH_TO_SEND)
            set BASE_DIR (basename $PATH_TO_SEND)

            # Percorre todos os arquivos recursivamente
            for FILE in (find $PATH_TO_SEND -type f)
                # REL_PATH relativo ao diretório pai
                set REL_PATH (string replace -r "^$PARENT_DIR/" "" $FILE)
                set URL "$SERVER/$REL_PATH"
                echo "Enviando $FILE -> $URL"
                curl -T "$FILE" "$URL"
            end

        else
            echo "Erro: '$PATH_TO_SEND' não existe"
        end

    end

    echo "Upload concluído!"
end
