package utils

import (
	"io/ioutil"
	"os"
	"path/filepath"
)

// ListDir returns all full paths in a directory.
func ListDir(path string) ([]string, error) {
	entries, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, err
	}

	var files []string
	for _, entry := range entries {
		files = append(files, filepath.Join(path, entry.Name()))
	}
	return files, nil
}

// ReadRawFile reads and returns raw file data.
func ReadRawFile(path string) ([]byte, error) {
	return os.ReadFile(path)
}

// IsDir checks if the given path is a directory.
func IsDir(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.IsDir()
}
