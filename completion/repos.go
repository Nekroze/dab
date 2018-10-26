package main

import (
	"io/ioutil"
	"os"
	"path"

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

func predictEntrypoint(a complete.Args) (out []string) {
	dir := getDabConfigPath(path.Join("repo", a.LastCompleted, "entrypoint"))
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		return nil
	}
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		panic(err)
	}

	for _, f := range files {
		if !f.IsDir() {
			out = append(out, f.Name())
		}
	}
	return out
}
