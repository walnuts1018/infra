package lib

import (
	"bytes"
	"io"
	"slices"

	"github.com/yosuke-furukawa/json5/encoding/json5"
)

func GetNamespaces(r io.Reader) ([]string, error) {
	b, err := io.ReadAll(r)
	if err != nil {
		return []string{}, err
	}

	if len(b) == 0 {
		return []string{}, nil
	}

	var ns []string
	if err := json5.Unmarshal(b, &ns); err != nil {
		return []string{}, err
	}

	return ns, nil
}

func GenNamespaceJSON(appJSONs []AppJSON, ns ...string) (io.Reader, error) {
	for _, appJSON := range appJSONs {
		ns = append(ns, appJSON.NameSpace)
	}

	slices.Sort(ns)
	ns = slices.Compact(ns)

	buf := &bytes.Buffer{}
	if err := json5.NewEncoder(buf).Encode(ns); err != nil {
		return nil, err
	}

	return buf, nil
}
