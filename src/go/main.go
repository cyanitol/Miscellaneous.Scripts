package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/FocuswithJustin/kong"
)

type CLI struct {
	Backup BackupCmd `cmd:"" help:"Run a restic backup."`
}

type BackupCmd struct {
	Repo            string   `help:"Restic repository (e.g., b2:bucket:folder)." required:""`
	B2AccountID     string   `help:"B2 account ID." env:"B2_ACCOUNT_ID"`
	B2AccountKey    string   `help:"B2 account key." env:"B2_ACCOUNT_KEY"`
	PasswordFile    string   `help:"Path to restic password file." required:""`
	LogFile         string   `help:"Path to log file." required:""`
	Root            string   `help:"Root path to back up." default:"/"`
	Exclude         []string `help:"Exclude path(s)."`
	OneFileSystem   bool     `help:"Do not cross filesystem boundaries." default:"true"`
	Verbose         int      `help:"Verbosity level (repeat for more)." short:"v"`
	Connections     int      `help:"B2 connections." default:"32"`
	DryRun          bool     `help:"Print the restic command without executing."`
	ResticBinary    string   `help:"Path to restic binary." default:"restic"`
}

func (c *BackupCmd) Run() error {
	if err := appendLog(c.LogFile, "== Start Backup - "+time.Now().Format(time.RFC1123)+" =="); err != nil {
		return err
	}
	defer func() {
		_ = appendLog(c.LogFile, "== End Backup - "+time.Now().Format(time.RFC1123)+" ==")
	}()

	args := []string{"backup"}
	if c.OneFileSystem {
		args = append(args, "--one-file-system")
	}
	for i := 0; i < c.Verbose; i++ {
		args = append(args, "--verbose")
	}
	for _, ex := range c.Exclude {
		args = append(args, "--exclude="+ex)
	}
	if c.Connections > 0 {
		args = append(args, "-o", fmt.Sprintf("b2.connections=%d", c.Connections))
	}
	args = append(args, c.Root)

	if c.DryRun {
		_, _ = fmt.Fprintln(os.Stdout, c.ResticBinary, strings.Join(args, " "))
		return nil
	}

	cmd := exec.Command(c.ResticBinary, args...)
	cmd.Env = withEnv(os.Environ(), map[string]string{
		"RESTIC_REPOSITORY":   c.Repo,
		"B2_ACCOUNT_ID":       c.B2AccountID,
		"B2_ACCOUNT_KEY":      c.B2AccountKey,
		"RESTIC_PASSWORD_FILE": c.PasswordFile,
	})

	logFile, err := os.OpenFile(c.LogFile, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o600)
	if err != nil {
		return err
	}
	defer logFile.Close()
	cmd.Stdout = logFile
	cmd.Stderr = logFile

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("restic failed: %w", err)
	}

	return nil
}

func withEnv(base []string, add map[string]string) []string {
	seen := map[string]bool{}
	out := make([]string, 0, len(base)+len(add))
	for _, kv := range base {
		key := strings.SplitN(kv, "=", 2)[0]
		if _, ok := add[key]; ok {
			seen[key] = true
			out = append(out, key+"="+add[key])
			continue
		}
		out = append(out, kv)
	}
	for k, v := range add {
		if !seen[k] && v != "" {
			out = append(out, k+"="+v)
		}
	}
	return out
}

func appendLog(path, line string) error {
	if strings.TrimSpace(path) == "" {
		return errors.New("log file is required")
	}
	f, err := os.OpenFile(path, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o600)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = fmt.Fprintln(f, "\n\n"+line)
	return err
}

func main() {
	var cli CLI
	ctx := kong.Parse(&cli, kong.Name("restic-wrapper"), kong.Description("Wrapper for restic backup."))
	if err := ctx.Run(); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
