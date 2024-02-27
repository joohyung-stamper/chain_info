package main

import (
	"chain_info/utils/errors"
	"chain_info/utls/ssh"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type HostInfo struct {
	FileName string
	Hosts    []string
}

const (
	ScriptsDir = "./scripts/"
	ConfigPath = "./config/config.env"
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
	// SSH 설정
	err := godotenv.Load(EnvPath)
	errors.HandleError(err, "Failed to load .env")
	configEnv, err := godotenv.Read(ConfigPath)
	errors.HandleError(err, "Failed to load config.env")

	user := configEnv["REMOTE_USER"]
	addr := configEnv["REMOTE_ADDR"]
	privKey := os.Getenv("PRIVATE_KEY")

	// SSH 세션 시작
	session, err := ssh.ConnectSSH(addr, user, privKey)
	errors.HandleError(err, "Failed to start SSH session")
	defer session.Close()

	// 스크립트 로드
	scriptFileName := os.Args[1]
	scriptPath := ScriptsDir + scriptFileName
	script, err := ioutil.ReadFile(scriptPath)
	errors.HandleError(err, "Failed to read script file")

	// 원격 서버에서 스크립트 실행
	err = session.Run("source $HOME/.profile; " + string(script))
	errors.HandleError(err, "Failed to execute script")

}

func getHostInfo(hostName string) HostInfo {
	// Host 정보를 기반으로 SSH 연결을 수행하고 Host 정보를 반환
	addr := fmt.Sprintf("%s:%d", hostName, 22) // 예: "141.94.248.105:22"
	user := "sei"                              // 예: "sei"
	privKeyPath := os.Getenv("HOME") + "/.env" // .env 파일 경로

	session, err := ssh.ConnectSSH(addr, user, privKeyPath)
	if err != nil {
		fmt.Println("Failed to establish SSH connection:", err)
		return HostInfo{}
	}
	defer session.Close()

	return HostInfo{
		// HostName: hostName,
		// User:     user,
	}
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
