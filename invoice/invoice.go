package invoice

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

func init() {
	// Load .env from the project root; ignore error when already set via environment
	_ = godotenv.Load()
}

// discountRate reads DISCOUNT_RATE from the environment (e.g. 0.10 = 10%).
func discountRate() (float64, error) {
	v := os.Getenv("DISCOUNT_RATE")
	if v == "" {
		return 0, fmt.Errorf("DISCOUNT_RATE is not set")
	}
	return strconv.ParseFloat(v, 64)
}

// taxRate reads TAX_RATE from the environment (e.g. 0.11 = 11%).
func taxRate() (float64, error) {
	v := os.Getenv("TAX_RATE")
	if v == "" {
		return 0, fmt.Errorf("TAX_RATE is not set")
	}
	return strconv.ParseFloat(v, 64)
}

// Discount returns the final price after applying the configured discount rate.
// Example: price=100, DISCOUNT_RATE=0.10 → 90.00
func Discount(price float64) (float64, error) {
	rate, err := discountRate()
	if err != nil {
		return 0, err
	}
	return price * (1 - rate), nil
}

// Tax returns the final price after applying discount then tax.
// finalPrice = price * (1 - discountRate) * (1 + taxRate)
func Tax(price float64) (float64, error) {
	discounted, err := Discount(price)
	if err != nil {
		return 0, err
	}
	rate, err := taxRate()
	if err != nil {
		return 0, err
	}
	return price*(1+rate) - (price - discounted), nil
}
