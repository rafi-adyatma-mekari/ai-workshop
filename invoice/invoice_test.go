package invoice

import (
	"os"
	"testing"
)

func setup() {
	os.Setenv("DISCOUNT_RATE", "0.10")
	os.Setenv("TAX_RATE", "0.11")
}

// TestDiscount_AppliesRateCorrectly verifies the happy path.
// price=100, DISCOUNT_RATE=0.10 → expected=90.00
func TestDiscount_AppliesRateCorrectly(t *testing.T) {
	setup()

	got, err := Discount(100)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	want := 90.0
	if got != want {
		t.Errorf("Discount(100) = %.4f, want %.4f", got, want)
	}
}

// TestDiscount_MissingEnv ensures an error is returned when DISCOUNT_RATE is unset.
func TestDiscount_MissingEnv(t *testing.T) {
	os.Unsetenv("DISCOUNT_RATE")
	defer os.Setenv("DISCOUNT_RATE", "0.10")

	_, err := Discount(100)
	if err == nil {
		t.Error("expected error when DISCOUNT_RATE is unset, got nil")
	}
}

// TestTax_AppliesDiscountThenTax verifies that tax is charged on the discounted price.
// price=100, DISCOUNT_RATE=0.10, TAX_RATE=0.11
// expected = 100 * (1 - 0.10) * (1 + 0.11) = 90 * 1.11 = 99.90
func TestTax_AppliesDiscountThenTax(t *testing.T) {
	setup()

	got, err := Tax(100)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	want := 99.90
	if got != want {
		t.Errorf("Tax(100) = %.4f, want %.4f", got, want)
	}
}
