package main

import (
	"bufio"
	"flag"
	"io/fs"
	"os"
	"sort"
	"strings"

	"github.com/Nekroze/dab/completion/templates"
)

var (
	searchDir string
	outFile   string
)

func main() {
	flag.StringVar(&searchDir, "search", "../app/docker/", "directory to search for apps in")
	flag.StringVar(&outFile, "out", "apps.go", "filename to write out to")
	flag.Parse()

	files, err := os.ReadDir(searchDir)
	if err != nil {
		panic(err)
	}

	apps := []string{}
	for _, f := range files {
		fileinfo, _ := f.Info()
		if !isApp(fileinfo) {
			continue
		}

		apps = append(apps, getAppName(fileinfo))
	}

	sort.Strings(apps)
	output := templates.Apps(apps)

	f, err := os.Create(outFile)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	w := bufio.NewWriter(f)
	if _, e := w.WriteString(output); e != nil {
		panic(e)
	}
	w.Flush()
}

func getAppName(f fs.FileInfo) string {
	return strings.Split(f.Name(), ".")[1]
}

func isApp(f fs.FileInfo) bool {
	parts := strings.Split(f.Name(), ".")

	if len(parts) != 3 {
		return false
	}

	if parts[0] != "docker-compose" {
		return false
	}

	return parts[2] == "yaml" || parts[2] == "yml"
}
