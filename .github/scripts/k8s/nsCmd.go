package main

import (
	"context"
	"flag"
	"os"

	"github.com/google/subcommands"
)

type nsCmd struct {
}

func (*nsCmd) Name() string     { return "ns" }
func (*nsCmd) Synopsis() string { return "create namespace manifests" }
func (*nsCmd) Usage() string {
	return `ns <file>:`
}

func (*nsCmd) SetFlags(f *flag.FlagSet) {
}

func (*nsCmd) Execute(_ context.Context, f *flag.FlagSet, _ ...any) subcommands.ExitStatus {
	return ExecuteHelper(func() error {
		args := f.Args()
		if len(args) == 0 {
			return ErrUsage
		}

		var ns []Namespace
		for _, filepath := range args {
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
			if err := os.WriteFile("namespaces.yaml", []byte(nsManifests.String()), 0644); err != nil {
				return err
			}
		}

		return nil
	})
}
