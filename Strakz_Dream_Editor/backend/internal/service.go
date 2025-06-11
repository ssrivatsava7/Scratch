package explorer

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

type FileEntry struct {
	Name  string `json:"name"`
	Path  string `json:"path"`
	IsDir bool   `json:"is_dir"`
}

func ListDir(path string) ([]FileEntry, error) {
	entries, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, fmt.Errorf("reading directory failed: %w", err)
	}

	var result []FileEntry
	for _, entry := range entries {
		result = append(result, FileEntry{
			Name:  entry.Name(),
			Path:  filepath.Join(path, entry.Name()),
			IsDir: entry.IsDir(),
		})
	}
	return result, nil
}

func ReadRawFile(path string) ([]byte, error) {
	return os.ReadFile(path)
}
