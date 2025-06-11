package explorer

import (
	"fmt"
	"path/filepath"

	"backend/pkg/utils"
)

// FileEntry represents a file or folder in the explorer.
type FileEntry struct {
	Name  string `json:"name"`
	Path  string `json:"path"`
	IsDir bool   `json:"is_dir"`
}

// Service encapsulates explorer logic.
type Service struct{}

// ListDir returns structured file entries.
func (s *Service) ListDir(path string) ([]FileEntry, error) {
	files, err := utils.ListDir(path)
	if err != nil {
		return nil, fmt.Errorf("reading directory failed: %w", err)
	}

	var entries []FileEntry
	for _, file := range files {
		entries = append(entries, FileEntry{
			Name:  filepath.Base(file),
			Path:  file,
			IsDir: utils.IsDir(file),
		})
	}
	return entries, nil
}

// ReadRawFile returns the raw file contents.
func (s *Service) ReadRawFile(path string) ([]byte, error) {
	data, err := utils.ReadRawFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading file failed: %w", err)
	}
	return data, nil
}
