package main

import (
	"io/ioutil"
	"os"

	errors "remote-script/utils/errors"
	ssh "remote-script/utils/ssh"

	"github.com/joho/godotenv"
)

const (
	ScriptsDir = "./scripts/"
	ConfigPath = "./config/config.env"
	EnvPath    = "./.env"
)

func main() {
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
