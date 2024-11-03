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

	yamlBytes, err := yaml.Marshal(jsonResult)
	if err != nil {
		return "", err
	}

	return string(yamlBytes), nil
}
