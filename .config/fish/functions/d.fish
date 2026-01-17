function d --description "detach running program from terminal"
    if test (count $argv) -eq 0
        echo "Uso: detach <comando> [args...]"
        return 1
    end

    # Executa o comando em background, desvinculando do terminal
    nohup $argv > /dev/null 2>&1 &

    # Guarda o PID do último processo em background
    set pid $last_pid

    # Verifica se o processo iniciou
    if ps -p $pid > /dev/null
        echo "✅ Processo iniciado (PID $pid)"
        disown
        sleep 0.3
        exit
    else
        echo "❌ Falha ao iniciar o processo"
    end
end
