package main

import (
	"context"
	"flag"
	"os"

	"github.com/google/subcommands"
)

type namespaceCmd struct {
	outFilePath string
}

func (*namespaceCmd) Name() string     { return "namespace" }
func (*namespaceCmd) Synopsis() string { return "create namespace manifests" }
func (*namespaceCmd) Usage() string {
	return `ns <file>:`
}

func (n *namespaceCmd) SetFlags(f *flag.FlagSet) {
	f.StringVar(&n.outFilePath, "o", "namespaces.yaml", "output file path")

}

func (n *namespaceCmd) Execute(_ context.Context, f *flag.FlagSet, _ ...any) subcommands.ExitStatus {
	return ExecuteHelper(func() error {
		filepathes := f.Args()
		if len(filepathes) == 0 {
			return ErrUsage
		}

		var ns []Namespace
		for _, filepath := range filepathes {
			file, err := os.Open(filepath)
			if err != nil {
				return err
			}
			defer file.Close()

			tmp, err := getNamespaces(getManifests(file))
			if err != nil {
				return err
			}
			ns = append(ns, tmp...)
		}

		var nsManifests RawManifests
		for _, n := range ns {
			m, err := createNamespaceManifest(n)
			if err != nil {
				return err
			}
			nsManifests = append(nsManifests, m)
		}

		if len(nsManifests) != 0 {
			if err := os.WriteFile(n.outFilePath, []byte(nsManifests.String()), 0644); err != nil {
				return err
			}
		}

		return nil
	})
}
