package ssh

import (
	"io/ioutil"
	"os"
	"strings"

	errors "remote-script/utils/errors"

	"golang.org/x/crypto/ssh"
)

func ConnectSSH(addr, user, privKeyPath string) (*ssh.Session, error) {
	// SSH 설정
	key, err := ioutil.ReadFile(privKeyPath)
	errors.HandleError(err, "Failed to read private key")

	signer, err := ssh.ParsePrivateKey(key)
	errors.HandleError(err, "Failed to parse private key")

	// SSH 연결 설정
	config := &ssh.ClientConfig{
		User: user,
		Auth: []ssh.AuthMethod{
			ssh.PublicKeys(signer),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	if !strings.Contains(addr, ":") {
		addr += ":22"
	}
	// SSH 연결
	client, err := ssh.Dial("tcp", addr, config)
	errors.HandleError(err, "Failed to dial SSH connection")

	// SSH 세션 시작
	session, err := client.NewSession()
	errors.HandleError(err, "Failed to create SSH session")

	session.Stdout, session.Stderr, session.Stdin = os.Stdout, os.Stderr, os.Stdin

	return session, nil
}
