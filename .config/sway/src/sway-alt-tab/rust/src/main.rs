use serde_json::Value;
use std::fs::{File, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::process::{Command, Stdio, exit};
use std::sync::Arc;
use std::path::Path;
use tokio::sync::Mutex;

const HISTORY_FILE: &str = "/tmp/.sway_focus_history";
const HISTORY_LIMIT: usize = 5;
const LOCK_FILE: &str = "/tmp/.sway_focus_history.lock";

#[tokio::main]
async fn main() {
    let args: Vec<String> = std::env::args().collect();

    let history = Arc::new(Mutex::new(load_history()));

    if args.len() > 1 && args[1] == "daemon" {
        // Checa se o daemon já está rodando
        if Path::new(LOCK_FILE).exists() {
            eprintln!("Daemon já está rodando!");
            exit(1);
        }

        // Cria arquivo de lock com PID
        let mut lock = File::create(LOCK_FILE).expect("Falha ao criar arquivo de lock");
        let _ = lock.write_all(std::process::id().to_string().as_bytes());

        // Ctrl-C handler para remover lock
        {
            let lock_path = LOCK_FILE.to_string();
            ctrlc::set_handler(move || {
                let _ = std::fs::remove_file(&lock_path);
                exit(0);
            }).expect("Erro ao configurar Ctrl-C handler");
        }

        println!("Iniciando daemon de histórico de foco...");
        subscribe_focus(history.clone()).await;

        // Remove lock ao terminar normalmente
        let _ = std::fs::remove_file(LOCK_FILE);
    } else {
        focus_last_window(history.clone()).await;
    }
}

// ===================== Funções =====================

async fn subscribe_focus(history: Arc<Mutex<Vec<String>>>) {
    let mut child = Command::new("swaymsg")
        .args(&["-t", "subscribe", "-m", "[\"window\"]"])
        .stdout(Stdio::piped())
        .spawn()
        .expect("Falha ao executar swaymsg");

    let stdout = child.stdout.take().expect("Sem stdout");
    let reader = BufReader::new(stdout);
    let mut lines = reader.lines();

    while let Some(Ok(line)) = lines.next() {
        if let Ok(event) = serde_json::from_str::<Value>(&line) {
            if let Some(id) = event["container"]["id"].as_i64() {
                let mut hist = history.lock().await;
                let id_str = id.to_string();

                if hist.first().map(|x| x == &id_str).unwrap_or(false) {
                    continue; // já está no topo
                }

                // Remove duplicatas
                hist.retain(|x| x != &id_str);
                hist.insert(0, id_str);
                if hist.len() > HISTORY_LIMIT {
                    hist.truncate(HISTORY_LIMIT);
                }

                save_history(&hist);
            }
        }
    }
}

async fn focus_last_window(history: Arc<Mutex<Vec<String>>>) {
    let output = Command::new("swaymsg")
        .args(&["-t", "get_tree"])
        .output()
        .expect("Falha ao executar swaymsg get_tree");

    let tree: Value =
        serde_json::from_slice(&output.stdout).expect("Falha ao parsear JSON do get_tree");

    let current = find_focused_id(&tree);

    let hist = history.lock().await;
    for win_id in hist.iter() {
        if win_id != &current {
            Command::new("swaymsg")
                .arg(format!("[con_id={}] focus", win_id))
                .status()
                .expect("Falha ao focar janela");
            return;
        }
    }

    println!("Nenhuma janela anterior encontrada.");
}

// ===================== Auxiliares =====================

fn find_focused_id(node: &Value) -> String {
    if node.get("focused").and_then(|v| v.as_bool()) == Some(true) {
        if let Some(id) = node["id"].as_i64() {
            return id.to_string();
        }
    }

    for ntype in ["nodes", "floating_nodes"] {
        if let Some(nodes) = node[ntype].as_array() {
            for n in nodes {
                let id = find_focused_id(n);
                if !id.is_empty() {
                    return id;
                }
            }
        }
    }

    "".to_string()
}

fn load_history() -> Vec<String> {
    if let Ok(file) = File::open(HISTORY_FILE) {
        let reader = BufReader::new(file);
        reader
            .lines()
            .filter_map(|line| line.ok())
            .collect()
    } else {
        Vec::new()
    }
}

fn save_history(history: &Vec<String>) {
    if let Ok(mut file) = OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open(HISTORY_FILE)
    {
        for id in history.iter() {
            let _ = writeln!(file, "{}", id);
        }
    }
}

