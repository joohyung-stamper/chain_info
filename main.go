package main

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"chain_info/utils/errors"
	"chain_info/utils/ssh"

	"github.com/joho/godotenv"
)

type HostInfo struct {
	FileName string
	Hosts    []string
}

const (
	ScriptsDir = "./scripts/"
	ConfigDir  = "/Users/joohyung/.ssh/config.d/"
	EnvPath    = "./.env"
)

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
		host := r.URL.Query().Get("host")
		if host == "" {
			http.Error(w, "parameter is missing", http.StatusBadRequest)
			return
		}
		hostInfo, err := getHostInfo(host)
		if err != nil {
			http.Error(w, fmt.Sprintf("failed to get host info: %v", err), http.StatusInternalServerError)
			return
		}
		renderTemplate(w, "statics/host-info.html", hostInfo)
	})

	fmt.Println("Server is running on port 8080...")
	http.ListenAndServe(":8080", nil)
}

func getHostList() []HostInfo {
	files, err := ioutil.ReadDir(ConfigDir)
	if err != nil {
		fmt.Println("Error reading directory:", err)
		return nil
	}

	var hostList []HostInfo
	for _, file := range files {
		if !file.IsDir() {
			filePath := ConfigDir + file.Name()
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

func getHostInfo(host string) (HostInfo, error) {
	err := godotenv.Load(EnvPath)
	errors.HandleError(err, "Failed to load .env")

	// 구성 디렉토리에서 파일 목록 가져오기
	files, err := ioutil.ReadDir(ConfigDir)
	if err != nil {
		errors.HandleError(err, "Failed to read config directory")
	}

	// 호스트에 해당하는 섹션 찾기
	var hostSection string
	for _, file := range files {
		filePath := ConfigDir + "/" + file.Name()
		content, err := ioutil.ReadFile(filePath)
		if err != nil {
			continue
		}

		lines := strings.Split(string(content), "\n")
		for i, line := range lines {
			if strings.TrimSpace(line) == "Host "+host {
				// 호스트에 해당하는 섹션 발견
				hostSection = strings.Join(lines[i:], "\n")
				break
			}
		}
		if hostSection != "" {
			break
		}
	}

	// 호스트 섹션에서 HostName과 User 추출
	var hostName, user, port string
	privKey := os.Getenv("PRIVATE_KEY")

	lines := strings.Split(hostSection, "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, "HostName") {
			hostName = strings.TrimSpace(strings.Split(line, " ")[1])
		} else if strings.HasPrefix(line, "User") {
			user = strings.TrimSpace(strings.Split(line, " ")[1])
		} else if strings.HasPrefix(line, "Port") {
			port = strings.TrimSpace(strings.Split(line, " ")[1])
		}
	}

	addr := hostName
	if port != "" {
		addr = fmt.Sprintf("%s:%s", hostName, port)
	}

	session, err := ssh.ConnectSSH(addr, user, privKey)
	if err != nil {
		fmt.Println("Failed to establish SSH connection:", err)
		// return errors
	}
	defer session.Close()

	scriptFileName := "show_node.sh"
	scriptPath := ScriptsDir + scriptFileName
	script, err := ioutil.ReadFile(scriptPath)

	// 원격 서버에서 스크립트 실행
	cmd := "source $HOME/.profile; " + ScriptsDir + string(script)
	if err := session.Run(cmd); err != nil {
		fmt.Println("Failed to execute script:", err)
		return HostInfo{}, err
	}

	return HostInfo{}, nil
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
