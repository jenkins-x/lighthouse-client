module github.com/jenkins-x/lighthouse-client-client

replace (
	github.com/tektoncd/pipeline => github.com/jenkins-x/pipeline v0.3.2-0.20210118090417-1e821d85abf6
	// gomodules.xyz breaks in Athens proxying
	gomodules.xyz/jsonpatch/v2 => github.com/gomodules/jsonpatch/v2 v2.1.0
	k8s.io/api => k8s.io/api v0.20.2
	k8s.io/apimachinery => k8s.io/apimachinery v0.20.2
	k8s.io/client-go => k8s.io/client-go v0.20.2
	knative.dev/pkg => github.com/jstrachan/pkg v0.0.0-20210118084935-c7bdd6c14bd0

	sigs.k8s.io/controller-runtime => sigs.k8s.io/controller-runtime v0.8.0
)

go 1.15
