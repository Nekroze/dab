const {danger, fail, warn} = require('danger')

// No PR is too small to include a description of why you made a change.
if (danger.github.pr.body.length < 10) {
	fail('Please include a description of your PR changes.')
}

// Ensure yarn lock file is up to date.
const changedYarn = danger.git.modified_files.includes('package.json');
const changedYarnLock = danger.git.modified_files.includes('yarn.lock');
if (changedYarn && !changedYarnLock) {
	fail('Changes were made to package.json, but not to yarn.lock\nPerhaps you need to run `yarn install`?')
}

// Changes to the dab wrapper script are to be avoided when possible.
const changedWrapper = danger.git.modified_files.includes('dab');
if (changedWrapper) {
	warn('Changes to the dab wrapper script are to be avoided when possible.')
}
