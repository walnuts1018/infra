package lib

import (
	"io"
	"reflect"
	"testing"
)

func TestGenNamespaceJSON(t *testing.T) {
	type args struct {
		appJSONs []AppJSON
		ns       []string
	}
	tests := []struct {
		name    string
		args    args
		want    string
		wantErr bool
	}{
		{
			name: "通常",
			args: args{
				appJSONs: []AppJSON{
					{
						Name:      "app1",
						NameSpace: "ns1",
					},
					{
						Name:      "app2",
						NameSpace: "ns2",
					},
				},
			},
			want:    `{"namespace":["ns1","ns2"]}` + "\n",
			wantErr: false,
		},
		{
			name: "重複",
			args: args{
				appJSONs: []AppJSON{
					{
						Name:      "app1",
						NameSpace: "ns1",
					},
					{
						Name:      "app2",
						NameSpace: "ns1",
					},
				},
			},
			want:    `{"namespace":["ns1"]}` + "\n",
			wantErr: false,
		},
		{
			name: "ソート",
			args: args{
				appJSONs: []AppJSON{
					{
						Name:      "app1",
						NameSpace: "ns2",
					},
					{
						Name:      "app2",
						NameSpace: "ns1",
					},
				},
			},
			want:    `{"namespace":["ns1","ns2"]}` + "\n",
			wantErr: false,
		},
		{
			name: "デフォルトNamespace存在",
			args: args{
				appJSONs: []AppJSON{
					{
						Name:      "app1",
						NameSpace: "ns1",
					},
					{
						Name:      "app2",
						NameSpace: "ns2",
					},
				},
				ns: []string{"ns3"},
			},
			want:    `{"namespace":["ns1","ns2","ns3"]}` + "\n",
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := GenNamespaceJSON(tt.args.appJSONs, tt.args.ns...)
			if (err != nil) != tt.wantErr {
				t.Errorf("GenNamespaceJSON() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			gotStr, err := io.ReadAll(got)
			if err != nil {
				t.Errorf("GenNamespaceJSON() error = %v", err)
				return
			}

			if !reflect.DeepEqual(string(gotStr), tt.want) {
				t.Errorf("GenNamespaceJSON() = %v, want %v", string(gotStr), tt.want)
			}
		})
	}
}
