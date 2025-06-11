// internal/utils/random.go
package utils

import (
	"math/rand"
	"time"
)

// GenerateRandomFloat returns a random float64 between min and max (inclusive).
func GenerateRandomFloat(min, max float64) float64 {
	rand.Seed(time.Now().UnixNano())
	return min + rand.Float64()*(max-min)
}
