package main

import (
	"bytes"
	"iter"
	"slices"
	"text/template"
)

type Namespace string

func getNamespaces(rawManifests iter.Seq[RawManifest]) ([]Namespace, error) {
	ns := make([]Namespace, 0)
	for rawManifest := range rawManifests {
		id, err := parseManifest(rawManifest)
		if err != nil {
			return nil, err
		}

		if id.Namespace != "" {
			ns = append(ns, Namespace(id.Namespace))
		}
	}
	slices.Sort(ns)
	return slices.Compact(ns), nil
}

const (
	namespaceTemplate = `apiVersion: v1
kind: Namespace
metadata:
  name: {{.}}
`
)

func createNamespaceManifest(namespace Namespace) (RawManifest, error) {
	tmpl, err := template.New("namespace").Parse(namespaceTemplate)
	if err != nil {
		return "", err
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, namespace); err != nil {
		return "", err
	}

	return RawManifest(buf.String()), nil
}
