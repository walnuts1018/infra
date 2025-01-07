package lib

import (
	"encoding/json"
	"strings"

	"github.com/google/go-jsonnet"
	yaml "gopkg.in/yaml.v3"
)

func BuildYAML(filepath string) (string, error) {
	vm := jsonnet.MakeVM()
	output, err := vm.EvaluateFile(filepath)
	if err != nil {
		return "", err
	}

	var jsonResult interface{}
	if err := json.Unmarshal([]byte(output), &jsonResult); err != nil {
		return "", err
	}

	jsonResults, ok := jsonResult.([]interface{})
	if !ok {
		jsonResults = []interface{}{jsonResult}
	}

	var yamlResult strings.Builder
	encoder := yaml.NewEncoder(&yamlResult)
	encoder.SetIndent(2)
	defer encoder.Close()

	for _, result := range jsonResults {
		if err := encoder.Encode(result); err != nil {
			return "", err
		}
	}
	return yamlResult.String(), nil
}
