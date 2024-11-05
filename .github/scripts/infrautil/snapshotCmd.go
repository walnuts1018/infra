package main

import (
	"context"
	"flag"
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"

	"github.com/google/subcommands"
	"github.com/walnuts1018/infra/.github/scripts/infrautil/lib"
)

type snapshotCmd struct {
	appBaseDir  string
	outFilePath string
}

func (*snapshotCmd) Name() string     { return "snapshot" }
func (*snapshotCmd) Synopsis() string { return "create snapshot" }
func (*snapshotCmd) Usage() string {
	return `snapshot -d <app directory> -o <output file app dir>:`
}

func (b *snapshotCmd) SetFlags(f *flag.FlagSet) {
	f.StringVar(&b.appBaseDir, "d", "k8s/apps", "app directory")
	f.StringVar(&b.outFilePath, "o", "k8s/snapshots/apps", "output file path")
}

func (b *snapshotCmd) Execute(_ context.Context, f *flag.FlagSet, _ ...any) subcommands.ExitStatus {
	if err := os.RemoveAll(b.outFilePath); err != nil {
		slog.Error("failed to remove out file path", slog.String("outFilePath", b.outFilePath), slog.Any("error", err))
		return subcommands.ExitFailure
	}

	if err := filepath.Walk(b.appBaseDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		if filepath.Ext(path) != ".jsonnet" {
			return nil
		}

		yaml, err := lib.BuildYAML(path)
		if err != nil {
			return err
		}

		relativePath, err := filepath.Rel(b.appBaseDir, path)
		if err != nil {
			return err
		}

		if err := os.MkdirAll(filepath.Join(b.outFilePath, filepath.Dir(relativePath)), 0755); err != nil {
			return err
		}

		if err := os.WriteFile(filepath.Join(b.outFilePath, changeExt(relativePath, ".yaml")), []byte(yaml), 0644); err != nil {
			return err
		}
		return nil
	}); err != nil {
		slog.Error("failed to walk app directory", slog.String("appBaseDir", b.appBaseDir), slog.Any("error", err))
		return subcommands.ExitFailure
	}

	return subcommands.ExitSuccess
}

func changeExt(path string, ext string) string {
	return path[:len(path)-len(filepath.Ext(path))] + ext
}
