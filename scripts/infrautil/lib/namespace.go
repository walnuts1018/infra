package lib

import (
	"bytes"
	"fmt"
	"io"
	"slices"

	"github.com/yosuke-furukawa/json5/encoding/json5"
)

type Namespace struct {
	Name   string            `json:"name"`
	Labels map[string]string `json:"labels,omitempty"`
}

func GetNamespaces(r io.Reader) ([]Namespace, error) {
	b, err := io.ReadAll(r)
	if err != nil {
		return []Namespace{}, err
	}

	if len(b) == 0 {
		return []Namespace{}, nil
	}

	var rawNamespaces []any
	if err := json5.Unmarshal(b, &rawNamespaces); err != nil {
		return []Namespace{}, err
	}

	ns := make([]Namespace, 0, len(rawNamespaces))
	for _, rawNamespace := range rawNamespaces {
		switch v := rawNamespace.(type) {
		case string:
			ns = append(ns, Namespace{Name: v})
		case map[string]any:
			name, ok := v["name"].(string)
			if !ok || name == "" {
				return []Namespace{}, fmt.Errorf("invalid namespace object: name is required")
			}

			namespace := Namespace{Name: name}
			rawLabels, hasLabels := v["labels"]
			if hasLabels {
				labelsMap, ok := rawLabels.(map[string]any)
				if !ok {
					return []Namespace{}, fmt.Errorf("invalid labels for namespace %q", name)
				}

				labels := make(map[string]string, len(labelsMap))
				for key, value := range labelsMap {
					labelValue, ok := value.(string)
					if !ok {
						return []Namespace{}, fmt.Errorf("invalid label value for namespace %q label %q", name, key)
					}
					labels[key] = labelValue
				}

				if len(labels) > 0 {
					namespace.Labels = labels
				}
			}

			ns = append(ns, namespace)
		default:
			return []Namespace{}, fmt.Errorf("invalid namespace entry type %T", rawNamespace)
		}
	}

	return ns, nil
}

func GenNamespaceJSON(appJSONs []AppJSON, ns ...Namespace) (io.Reader, error) {
	namespacesByName := map[string]Namespace{}

	for _, namespace := range ns {
		if namespace.Name == "" {
			continue
		}

		existingNamespace, ok := namespacesByName[namespace.Name]
		if ok {
			if len(existingNamespace.Labels) == 0 && len(namespace.Labels) > 0 {
				namespacesByName[namespace.Name] = namespace
			}
			continue
		}

		namespacesByName[namespace.Name] = namespace
	}

	for _, appJSON := range appJSONs {
		if _, ok := namespacesByName[appJSON.NameSpace]; ok {
			continue
		}
		namespacesByName[appJSON.NameSpace] = Namespace{Name: appJSON.NameSpace}
	}

	names := make([]string, 0, len(namespacesByName))
	for name := range namespacesByName {
		names = append(names, name)
	}
	slices.Sort(names)

	results := make([]any, 0, len(names))
	for _, name := range names {
		namespace := namespacesByName[name]
		if len(namespace.Labels) == 0 {
			results = append(results, name)
			continue
		}

		results = append(results, namespace)
	}

	buf := &bytes.Buffer{}
	if err := json5.NewEncoder(buf).Encode(results); err != nil {
		return nil, err
	}

	return buf, nil
}
