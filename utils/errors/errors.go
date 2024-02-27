package errors

import (
	"fmt"
	"os"
)

func HandleError(err error, message string) {
	if err != nil {
		fmt.Printf("%s: %v\n", message, err)
		os.Exit(1)
	}
}
