package lib

import (
	"encoding/json"

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

	var yamlResult string
	for _, result := range jsonResults {
		yamlBytes, err := yaml.Marshal(result)
		if err != nil {
			return "", err
		}
		yamlResult += string(yamlBytes)
		yamlResult += "\n---\n"
	}
	return yamlResult, nil
}
