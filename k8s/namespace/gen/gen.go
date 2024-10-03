package main

import (
	"go/ast"
	"go/parser"
	"go/token"
	"log"
	"os"
	"path/filepath"
)

func main() {
	workdir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	source := filepath.Join(workdir, "namespace.go")
	f, err := parser.ParseFile(token.NewFileSet(), source, nil, parser.Mode(0))
	if err != nil {
		log.Fatal(err)
	}

	namespaces := make([]string, 0)
	ast.Inspect(f, func(n ast.Node) bool {
		switch x := n.(type) {
		case *ast.ValueSpec:
			ident, ok := x.Type.(*ast.Ident)
			if !ok {
				return true
			}
			if ident.Name == "Namespace" {
				for _, v := range x.Values {
					basic, ok := v.(*ast.BasicLit)
					if !ok {
						continue
					}
					namespaces = append(namespaces, basic.Value)
				}
			}
		}
		return true
	})

}
