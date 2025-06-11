// internal/utils/random_test.go
package utils

import (
	"testing"
)

func TestGenerateRandomFloat(t *testing.T) {
	min := 100.00
	max := 200.00

	for i := 0; i < 100; i++ {
		val := GenerateRandomFloat(min, max)
		if val < min || val > max {
			t.Errorf("Generated value %f not in range [%f, %f]", val, min, max)
		}
	}
}
