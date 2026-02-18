package lib

import (
	"io"
	"reflect"
	"strings"
	"testing"
)

func TestGenNamespaceJSON(t *testing.T) {
	type args struct {
		appJSONs []AppJSON
		ns       []Namespace
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
			want:    `["ns1","ns2"]` + "\n",
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
			want:    `["ns1"]` + "\n",
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
			want:    `["ns1","ns2"]` + "\n",
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
				ns: []Namespace{{Name: "ns3"}},
			},
			want:    `["ns1","ns2","ns3"]` + "\n",
			wantErr: false,
		},
		{
			name: "ラベル付きNamespace保持",
			args: args{
				appJSONs: []AppJSON{
					{
						Name:      "app1",
						NameSpace: "ns2",
					},
				},
				ns: []Namespace{
					{
						Name: "ns1",
						Labels: map[string]string{
							"pod-security.kubernetes.io/enforce": "privileged",
						},
					},
				},
			},
			want:    `[{"name":"ns1","labels":{"pod-security.kubernetes.io/enforce":"privileged"}},"ns2"]` + "\n",
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

func TestGetNamespaces(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    []Namespace
		wantErr bool
	}{
		{
			name:  "文字列配列",
			input: `["ns1","ns2"]`,
			want:  []Namespace{{Name: "ns1"}, {Name: "ns2"}},
		},
		{
			name: "オブジェクト配列",
			input: `[
				{"name":"ns1","labels":{"pod-security.kubernetes.io/enforce":"privileged"}},
				"ns2"
			]`,
			want: []Namespace{
				{
					Name: "ns1",
					Labels: map[string]string{
						"pod-security.kubernetes.io/enforce": "privileged",
					},
				},
				{Name: "ns2"},
			},
		},
		{
			name:    "name欠落",
			input:   `[{"labels":{"a":"b"}}]`,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := GetNamespaces(strings.NewReader(tt.input))
			if (err != nil) != tt.wantErr {
				t.Errorf("GetNamespaces() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if tt.wantErr {
				return
			}

			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("GetNamespaces() = %#v, want %#v", got, tt.want)
			}
		})
	}
}
