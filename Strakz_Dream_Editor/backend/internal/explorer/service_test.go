package explorer

import (
	"os"
	"path/filepath"
	"testing"
)

func TestListDir(t *testing.T) {
	svc := Service{} // Use Service

	tmpDir := t.TempDir()
	os.WriteFile(filepath.Join(tmpDir, "file1.txt"), []byte("test"), 0644)
	os.Mkdir(filepath.Join(tmpDir, "subdir"), 0755)

	files, err := svc.ListDir(tmpDir)
	if err != nil {
		t.Fatalf("ListDir failed: %v", err)
	}

	if len(files) != 2 {
		t.Fatalf("Expected 2 entries, got %d", len(files))
	}

	names := map[string]bool{}
	for _, f := range files {
		names[f.Name] = true
	}
	if !names["file1.txt"] || !names["subdir"] {
		t.Errorf("Expected file1.txt and subdir to exist in list")
	}
}

func TestReadRawFile(t *testing.T) {
	svc := Service{} // Use Service

	content := []byte("hello world")
	tmpFile := filepath.Join(t.TempDir(), "readme.txt")
	if err := os.WriteFile(tmpFile, content, 0644); err != nil {
		t.Fatal(err)
	}

	data, err := svc.ReadRawFile(tmpFile)
	if err != nil {
		t.Fatalf("ReadRawFile failed: %v", err)
	}

	if string(data) != string(content) {
		t.Errorf("Expected '%s', got '%s'", content, data)
	}
}
