use serde_json::Value;
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::sync::Mutex as AsyncMutex;

#[tokio::main]
async fn main() {
    // Histórico de janelas (mais recente primeiro)
    let history = Arc::new(AsyncMutex::new(Vec::<String>::new()));
    const HISTORY_LIMIT: usize = 5;

    // Inicia swaymsg subscribe
    let mut child = Command::new("swaymsg")
        .args(&["-t", "subscribe", "-m", "[\"window\"]"])
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to spawn swaymsg");

    let stdout = child.stdout.take().expect("No stdout");
    let mut reader = BufReader::new(stdout).lines();

    while let Ok(Some(line)) = reader.next_line().await {
        if let Ok(event) = serde_json::from_str::<Value>(&line) {
            if let Some(id) = event["container"]["id"].as_i64() {
                let mut hist = history.lock().await;
                let id_str = id.to_string();

                if hist.first().map(|x| x == &id_str).unwrap_or(false) {
                    continue; // já está no topo
                }

                hist.retain(|x| x != &id_str);
                hist.insert(0, id_str);
                hist.truncate(HISTORY_LIMIT);
            }
        }
    }
}

