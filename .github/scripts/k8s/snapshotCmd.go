package main

import (
	"context"
	"flag"
	"os"
	"path/filepath"

	"github.com/google/subcommands"

	"sigs.k8s.io/kustomize/api/krusty"
	"sigs.k8s.io/kustomize/kyaml/filesys"
)

type snapshotCmd struct {
}

func (*snapshotCmd) Name() string     { return "snapshot" }
func (*snapshotCmd) Synopsis() string { return "create namespace manifests" }
func (*snapshotCmd) Usage() string {
	return `snapshot <./k8s/apps/> <./k8s/.snapshot.yaml>: create snapshot manifests`
}

func (*snapshotCmd) SetFlags(f *flag.FlagSet) {
}

const (
	kustomizationTemplate = `apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
`
)

func (*snapshotCmd) Execute(_ context.Context, f *flag.FlagSet, _ ...any) subcommands.ExitStatus {
	return ExecuteHelper(func() error {
		args := f.Args()
		if len(args) != 2 {
			return ErrUsage
		}
		workDir, err := os.Getwd()
		if err != nil {
			return err
		}

		appDir := args[0]
		if !filepath.IsAbs(appDir) {
			appDir = filepath.Join(workDir, appDir)
		}

		snapshotFilePath := args[1]
		if !filepath.IsAbs(snapshotFilePath) {
			snapshotFilePath = filepath.Join(workDir, snapshotFilePath)
		}

		fSys := filesys.MakeFsOnDisk()
		k := krusty.MakeKustomizer(krusty.MakeDefaultOptions())

		apps, err := os.ReadDir(appDir)
		if err != nil {
			return err
		}

		baseKustomizeDir := filepath.Join(workDir, ".snapshot.tmp")
		if err := os.MkdirAll(baseKustomizeDir, 0755); err != nil {
			return err
		}
		defer os.RemoveAll(baseKustomizeDir)

		baseKustomizeFile, err := os.Create(filepath.Join(baseKustomizeDir, "kustomization.yaml"))
		if err != nil {
			return err
		}
		defer baseKustomizeFile.Close()

		if _, err := baseKustomizeFile.WriteString(kustomizationTemplate); err != nil {
			return err
		}

		for _, app := range apps {
			if !app.IsDir() {
				continue
			}
			appPath, err := filepath.Rel(baseKustomizeDir, filepath.Join(appDir, app.Name()))
			if err != nil {
				return err
			}

			baseKustomizeFile.WriteString("  - " + appPath + "\n")
		}

		m, err := k.Run(fSys, baseKustomizeDir)
		if err != nil {
			return err
		}
		yml, err := m.AsYaml()
		if err != nil {
			return err
		}

		if err := os.WriteFile(snapshotFilePath, []byte(yml), 0644); err != nil {
			return err
		}
		return nil
	})
}
