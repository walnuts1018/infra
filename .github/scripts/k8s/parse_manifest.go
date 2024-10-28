package main

import (
	"fmt"

	"gopkg.in/yaml.v3"
)

type Identifier struct {
	Kind       string
	ApiVersion string
	Namespace  string
	Name       string
}

func parseManifest(r RawManifest) (Identifier, error) {
	var m map[string]interface{}
	if err := yaml.Unmarshal([]byte(r), &m); err != nil {
		return Identifier{}, err
	}

	kind, ok := m["kind"].(string)
	if !ok {
		return Identifier{}, fmt.Errorf("kind not found in manifest: %v", r)
	}

	apiVersion, ok := m["apiVersion"].(string)
	if !ok {
		return Identifier{}, fmt.Errorf("apiVersion not found in manifest: %v", r)
	}

	meta, ok := m["metadata"].(map[string]interface{})
	if !ok {
		return Identifier{}, fmt.Errorf("metadata not found in manifest: %v", r)
	}

	namespace, ok := meta["namespace"]
	if ok {
		namespace, ok = namespace.(string)
		if !ok {
			return Identifier{}, fmt.Errorf("namespace not a string: %v", namespace)
		}
	} else {
		namespace = ""
	}

	name, ok := meta["name"].(string)
	if !ok {
		return Identifier{}, fmt.Errorf("name not found in manifest: %v", r)
	}

	return Identifier{
		Kind:       kind,
		ApiVersion: apiVersion,
		Namespace:  namespace.(string),
		Name:       name,
	}, nil
}
