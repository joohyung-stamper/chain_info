package main

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

type HostInfo struct {
	FileName string
	Hosts    []string
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		hostList := getHostList()
		renderTemplate(w, "statics/index.html", hostList)
	})

	http.HandleFunc("/host-info", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "statics/host-info.html")
	})

	fmt.Println("Server is running on port 8080...")
	http.ListenAndServe(":8080", nil)
}

func getHostList() []HostInfo {
	files, err := ioutil.ReadDir(os.Getenv("HOME") + "/.ssh/config.d")
	if err != nil {
		fmt.Println("Error reading directory:", err)
		return nil
	}

	var hostList []HostInfo
	for _, file := range files {
		if !file.IsDir() {
			filePath := os.Getenv("HOME") + "/.ssh/config.d/" + file.Name()
			hosts, err := getHosts(filePath)
			if err != nil {
				fmt.Println("Error reading file:", err)
				continue
			}
			hostList = append(hostList, HostInfo{
				FileName: file.Name(),
				Hosts:    hosts,
			})
		}
	}
	return hostList
}

func getHosts(filePath string) ([]string, error) {
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	lines := strings.Split(string(content), "\n")
	var hosts []string
	for _, line := range lines {
		if strings.HasPrefix(line, "Host ") {
			hosts = append(hosts, strings.TrimSpace(line[5:]))
		}
	}
	return hosts, nil
}

func renderTemplate(w http.ResponseWriter, tmpl string, data interface{}) {
	t, err := template.ParseFiles(tmpl)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	err = t.Execute(w, data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
