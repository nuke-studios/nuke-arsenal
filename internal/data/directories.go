package data

import (
	"os"
	"path/filepath"
)

// GetConfigDir returns ~/.config/arsenal
func GetConfigDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".config", "arsenal"), nil
}

// GetDefaultDataDir returns ~/.nuke-arsenal
func GetDefaultDataDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".nuke-arsenal"), nil
}

// GetDefaultDataPath returns ~/.nuke-arsenal/commands.json
func GetDefaultDataPath() (string, error) {
	dir, err := GetDefaultDataDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "commands.json"), nil
}

// GetConfigPath returns path to config.json
func GetConfigPath() (string, error) {
	dir, err := GetConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "config.json"), nil
}

// EnsureConfigDir creates config directory if it doesn't exist
func EnsureConfigDir() error {
	dir, err := GetConfigDir()
	if err != nil {
		return err
	}
	return os.MkdirAll(dir, 0755)
}

// EnsureDataDir creates the directory for commands.json if needed
func EnsureDataDir(dataPath string) error {
	dir := filepath.Dir(dataPath)
	return os.MkdirAll(dir, 0755)
}
