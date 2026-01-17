package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func loadLayers() ([]string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}

	conf := filepath.Join(home, ".config/keyd/default.conf")

	file, err := os.Open(conf)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var layers []string
	sc := bufio.NewScanner(file)

	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())

		if strings.HasPrefix(line, "[") && strings.HasSuffix(line, "]") {
			name := line[1 : len(line)-1]
			if name != "main" {
				layers = append(layers, name)
			}
		}
	}

	return layers, sc.Err()
}

func remove(slice []string, target string) []string {
	out := make([]string, 0, len(slice))
	for _, v := range slice {
		if v != target {
			out = append(out, v)
		}
	}
	return out
}

func main() {
	layers, err := loadLayers()
	if err != nil {
		fmt.Fprintf(os.Stderr, "erro lendo layers: %v\n", err)
		os.Exit(1)
	}

	state := make(map[string]bool)
	order := []string{}

	cmd := exec.Command("sudo", "-n", "keyd", "listen")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Fprintf(os.Stderr, "erro stdout pipe: %v\n", err)
		os.Exit(1)
	}

	if err := cmd.Start(); err != nil {
		fmt.Fprintf(os.Stderr, "erro executando keyd listen: %v\n", err)
		os.Exit(1)
	}

	sc := bufio.NewScanner(stdout)

	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())

		if len(line) < 2 {
			continue
		}

		sign := line[0]
		layer := line[1:]

		found := false
		for _, l := range layers {
			if l == layer {
				found = true
				break
			}
		}
		if !found {
			continue
		}

		if sign == '+' {
			// Ativa layer
			state[layer] = true
			order = append(order, layer)
		}

		if sign == '-' {
			// Desativa layer
			state[layer] = false
			order = remove(order, layer)
		}

		// monta JSON
		var active []string
		for _, l := range order {
			if state[l] {
				active = append(active, l)
			}
		}

		var out map[string]interface{}
		if len(active) == 0 {
			out = map[string]interface{}{"text": nil}
		} else {
			out = map[string]interface{}{
				"text": "[KB Layer]: " + strings.Join(active, " + ") + " ",
			}
		}

		j, _ := json.Marshal(out)
		fmt.Println(string(j))
		os.Stdout.Sync()
	}
}

