package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

func writeStatus(activeLayers []string) {
	fmt.Printf("{\"text\": \"%s \"}\n", strings.Join(activeLayers, " + "))
}

func main() {
	// Executa o processo keyd
	cmd := exec.Command("sudo", "-n", "keyd", "listen")
	stdoutPipe, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Println("Failed to get stdout:", err)
		return
	}

	if err := cmd.Start(); err != nil {
		fmt.Println("Keyd not in PATH.")
		return
	}

	// Lê arquivo de configuração
	homeDir, _ := os.UserHomeDir()
	configPath := filepath.Join(homeDir, ".config", "keyd", "default.conf")
	data, err := os.ReadFile(configPath)
	if err != nil {
		fmt.Println("Failed to read config:", err)
		return
	}

	configStr := string(data)

	// Extrai layers e toggle layers
	layerRegex := regexp.MustCompile(`\[.*?\]`)
	toggleRegex := regexp.MustCompile(`toggle\s*(\w+)`)

	layers := []string{}
	for _, match := range layerRegex.FindAllString(configStr, -1) {
		layer := strings.Trim(match, "[]")
		if layer != "main" {
			layers = append(layers, layer)
		}
	}

	toggleLayers := []string{}
	for _, match := range toggleRegex.FindAllStringSubmatch(configStr, -1) {
		if len(match) > 1 {
			toggleLayers = append(toggleLayers, match[1])
		}
	}

	activeLayers := []string{}

	scanner := bufio.NewScanner(stdoutPipe)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		layerOn := strings.Contains(line, "+")
		layerOff := strings.Contains(line, "-")

		for _, layer := range layers {
			if strings.Contains(line, layer) {
				isToggle := contains(toggleLayers, layer)

				if isToggle && layerOn {
					// Remove todos os toggles e adiciona este layer
					activeLayers = removeAll(activeLayers, toggleLayers)
					activeLayers = append(activeLayers, layer)
				} else if layerOff {
					activeLayers = remove(activeLayers, layer)
				} else if !isToggle && layerOn && !contains(activeLayers, layer) {
					activeLayers = append(activeLayers, layer)
				}
			}
		}

		writeStatus(activeLayers)
	}

	cmd.Wait()
}

// Funções auxiliares simples
func contains(slice []string, str string) bool {
	for _, s := range slice {
		if s == str {
			return true
		}
	}
	return false
}

func remove(slice []string, str string) []string {
	result := []string{}
	for _, s := range slice {
		if s != str {
			result = append(result, s)
		}
	}
	return result
}

func removeAll(slice []string, toRemove []string) []string {
	result := []string{}
	for _, s := range slice {
		if !contains(toRemove, s) {
			result = append(result, s)
		}
	}
	return result
}

