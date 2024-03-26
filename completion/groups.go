package main

import (
	"os"

	"github.com/posener/complete"
)

func predictGroups(_ complete.Args) (out []string) {
	dir := getDabConfigPath("group")
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		panic(err)
	}
	files, err := os.ReadDir(dir)
	if err != nil {
		panic(err)
	}

	for _, f := range files {
		if f.IsDir() {
			out = append(out, f.Name())
		}
	}

	return out
}
