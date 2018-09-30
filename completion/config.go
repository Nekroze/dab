package main

import (
	"os"
	"path/filepath"
	"strings"

	homedir "github.com/mitchellh/go-homedir"
	"github.com/posener/complete"
)

var dabRepoPath string
var dabConfPath string
var home string

func init() {
	var err error
	home, err = homedir.Dir()
	if err != nil {
		panic(err)
	}

	dabConfPath = filepath.Join(home, ".config/dab")
	dabRepoPath = filepath.Join(home, "dab")
	if val := os.Getenv("DAB_CONF_PATH"); val != "" {
		dabConfPath = val
	}
	if val := os.Getenv("DAB_REPO_PATH"); val != "" {
		dabRepoPath = val
	}
}

func predictConfigKeys(args complete.Args) []string {
	return getCompletedFragmentChildren(getCompletedFragment(args.Last))
}

func getDabConfigPath(key string) string {
	return filepath.Join(dabConfPath, key)
}

func getCompletedFragmentChildren(input string) (out []string) {
	dir := getDabConfigPath(input)
	err := filepath.Walk(dir, func(path string, f os.FileInfo, err error) error {
		if err != nil || path == dir || f.IsDir() {
			return err
		}
		out = append(out, strings.TrimPrefix(path, dir+"/"))
		return nil
	})
	if err != nil {
		panic(err)
	}
	return out
}

func getCompletedFragment(input string) string {
	parts := strings.Split(input, "/")
	completed := parts[:len(parts)-1]
	return strings.Join(completed, "/")
}
