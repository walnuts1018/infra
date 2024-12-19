package lib

import (
	"os"
	"path/filepath"

	"github.com/yosuke-furukawa/json5/encoding/json5"
)

type AppJSON struct {
	Name      string `json:"name"`
	NameSpace string `json:"namespace"`
}

const appJSONFile = "app.json5"

func GetAppJSON(basedir string) ([]AppJSON, error) {
	var appJSONs []AppJSON

	appdirs, err := os.ReadDir(basedir)
	if err != nil {
		return []AppJSON{}, err
	}

	for _, appdir := range appdirs {
		if !appdir.IsDir() {
			continue
		}

		appJSONFile, err := os.Open(filepath.Join(basedir, appdir.Name(), appJSONFile))
		if err != nil {
			continue
		}
		defer appJSONFile.Close()

		var appJSON AppJSON
		if err := json5.NewDecoder(appJSONFile).Decode(&appJSON); err != nil {
			return []AppJSON{}, err
		}

		appJSONs = append(appJSONs, appJSON)
	}
	return appJSONs, nil
}
