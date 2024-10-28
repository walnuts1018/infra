package main

import (
	"bufio"
	"io"
	"iter"
	"strings"
)

type RawManifest string
type RawManifests []RawManifest

func (rs RawManifests) String() string {
	var out string
	for _, r := range rs {
		out += strings.TrimSuffix(clean(string(r)), "\n") + "\n---\n"
	}
	return out
}

func getManifests(reader io.Reader) iter.Seq[RawManifest] {
	scanner := bufio.NewScanner(reader)

	return func(yield func(RawManifest) bool) {
		var tmp string
		for scanner.Scan() {
			line := scanner.Text()
			if line == "\n" || line == "" {
				continue
			}

			if line == "---" {
				if len(tmp) > 0 {
					if !yield(RawManifest(tmp)) {
						return
					}
				}
				tmp = ""
			} else {
				tmp += line + "\n"
			}
		}

		if len(tmp) > 0 {
			yield(RawManifest(tmp))
		}
	}
}

func clean(v string) string {
	return strings.NewReplacer(
		"\r\n", "\n",
		"\r", "\n",
		"\n", "\n",
	).Replace(v)
}
