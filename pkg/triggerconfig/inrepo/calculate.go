package inrepo

import (
	"github.com/jenkins-x/go-scm/scm"
	"github.com/jenkins-x/lighthouse-client/pkg/config"
	"github.com/jenkins-x/lighthouse-client/pkg/filebrowser"
	"github.com/jenkins-x/lighthouse-client/pkg/plugins"
	"github.com/jenkins-x/lighthouse-client/pkg/triggerconfig/merge"
	"github.com/pkg/errors"
)

// Generate generates the in repository config if enabled for this repository otherwise return the shared config
func Generate(fileBrowsers *filebrowser.FileBrowsers, fc filebrowser.FetchCache, cache *ResolverCache, sharedConfig *config.Config, sharedPlugins *plugins.Configuration, owner, repo, eventRef string) (*config.Config, *plugins.Configuration, error) {
	fullName := scm.Join(owner, repo)
	if !sharedConfig.InRepoConfigEnabled(fullName) {
		return sharedConfig, sharedPlugins, nil
	}

	// in repository configuration configured for this repository so lets create the in repository specific config structs
	cfg := *sharedConfig

	// plugins are optional - e.g. keeper doesn't pass plugins in
	pluginCfg := plugins.Configuration{}
	if sharedPlugins != nil {
		pluginCfg = *sharedPlugins

		// lets avoid concurrent modification issues sharing the config updater
		pluginCfg.ConfigUpdater = plugins.ConfigUpdater{
			Maps: map[string]plugins.ConfigMapSpec{},
			GZIP: false,
		}
	}

	// lets load the main branch first then merge in any changes from this PR/branch
	refs, err := fileBrowsers.LighthouseGitFileBrowser().GetMainAndCurrentBranchRefs(owner, repo, eventRef)
	if err != nil {
		return sharedConfig, sharedPlugins, errors.Wrapf(err, "failed to find main branch %s", fullName)
	}

	for _, ref := range refs {
		repoConfig, err := LoadTriggerConfig(fileBrowsers, fc, cache, owner, repo, ref)
		if err != nil {
			return sharedConfig, sharedPlugins, errors.Wrapf(err, "failed to load trigger config for repository %s/%s for ref %s", owner, repo, ref)
		}
		if repoConfig != nil {
			err = merge.ConfigMerge(&cfg, &pluginCfg, repoConfig, owner, repo)
			if err != nil {
				return sharedConfig, sharedPlugins, errors.Wrapf(err, "failed to merge repository config with repository %s/%s for ref %s", owner, repo, ref)
			}
		}
	}
	return &cfg, &pluginCfg, nil
}
