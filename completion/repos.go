package main

import (
	"io/ioutil"
	"os"

	"github.com/posener/complete"
)

func predictRepos(_ complete.Args) (out []string) {
	dir := getDabConfigPath("repo")
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		return nil
	}
	files, err := ioutil.ReadDir(dir)
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
