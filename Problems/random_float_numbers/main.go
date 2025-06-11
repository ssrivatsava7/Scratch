package main

import (
	"fmt"
	"random_float_numbers/internal/utils"
)

func main() {
	val := utils.GenerateRandomFloat(100.0, 200.0)
	fmt.Printf("Random float between 100 and 200: %.2f\n", val)
}
