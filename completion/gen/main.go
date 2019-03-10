package main

import (
	"bufio"
	"flag"
	"io/ioutil"
	"os"
	"sort"
	"strings"

	"github.com/Nekroze/dab/completion/templates"
)

var searchDir string
var outFile string

func main() {
	flag.StringVar(&searchDir, "search", "../app/docker/", "directory to search for apps in")
	flag.StringVar(&outFile, "out", "apps.go", "filename to write out to")
	flag.Parse()

	files, err := ioutil.ReadDir(searchDir)
	if err != nil {
		panic(err)
	}

	apps := []string{}
	for _, f := range files {
		if !isApp(f) {
			continue
		}

		apps = append(apps, getAppName(f))
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

func getAppName(f os.FileInfo) string {
	return strings.Split(f.Name(), ".")[1]
}

func isApp(f os.FileInfo) bool {
	parts := strings.Split(f.Name(), ".")

	if len(parts) != 3 {
		return false
	}

	if parts[0] != "docker-compose" {
		return false
	}

	return parts[2] == "yaml" || parts[2] == "yml"
}
