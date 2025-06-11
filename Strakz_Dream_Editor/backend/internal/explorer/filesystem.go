package explorer

import (
	"io/ioutil"
	"path/filepath"
)

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

func ReadRawFile(path string) ([]byte, error) {
	return ioutil.ReadFile(path)
}
