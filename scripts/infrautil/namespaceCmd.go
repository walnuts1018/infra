package main

import (
	"context"
	"flag"
	"io"
	"log/slog"
	"os"

	"github.com/google/subcommands"
	"github.com/walnuts1018/infra/scripts/infrautil/lib"
)

type namespaceCmd struct {
	appDir      string
	outFilePath string
}

func (*namespaceCmd) Name() string     { return "namespace" }
func (*namespaceCmd) Synopsis() string { return "create namespace manifests" }
func (*namespaceCmd) Usage() string {
	return `ns <file>:`
}

func (n *namespaceCmd) SetFlags(f *flag.FlagSet) {
	f.StringVar(&n.appDir, "d", "k8s/apps", "app directory")
	f.StringVar(&n.outFilePath, "o", "namespaces/namespaces.yaml", "output file path")
}

func (n *namespaceCmd) Execute(_ context.Context, f *flag.FlagSet, _ ...any) subcommands.ExitStatus {
	appJSONs, err := lib.GetAppJSON(n.appDir)
	if err != nil {
		slog.Error("failed to get app json", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	namespaceJSONFile, err := os.OpenFile(n.outFilePath, os.O_CREATE|os.O_RDWR, 0666)
	if err != nil {
		slog.Error("failed to open file", slog.Any("error", err))
		return subcommands.ExitFailure
	}
	defer namespaceJSONFile.Close()

	ns, err := lib.GetNamespaces(namespaceJSONFile)
	if err != nil {
		slog.Error("failed to get namespaces", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	r, err := lib.GenNamespaceJSON(appJSONs, ns...)
	if err != nil {
		slog.Error("failed to generate namespace json", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	if err := namespaceJSONFile.Truncate(0); err != nil {
		slog.Error("failed to seek namespace json", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	if _, err := namespaceJSONFile.Seek(0, 0); err != nil {
		slog.Error("failed to seek namespace json", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	if _, err := io.Copy(namespaceJSONFile, r); err != nil {
		slog.Error("failed to write namespace json", slog.Any("error", err))
		return subcommands.ExitFailure
	}

	return subcommands.ExitSuccess
}
