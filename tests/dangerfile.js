const {danger, warn, includes} = require('danger')

// No PR is too small to include a description of why you made a change.
if (danger.github.pr.body.length < 10) {
	warn('Please include a description of your PR changes.')
}

// Ensure yarn lock file is up to date.
const changedYarn = danger.git.modified_files.includes('package.json')
const changedYarnLock = danger.git.modified_files.includes('yarn.lock')
if (changedYarn && !changedYarnLock) {
	const message = 'Changes were made to package.json, but not to yarn.lock'
	const idea = 'Perhaps you need to run `yarn install`?'
	warn(`${message} - <i>${idea}</i>`)
}

// Ensure ruby gem lock file is up to date.
const changedGemfile = danger.git.modified_files.includes('tests/Gemfile')
const changedGemfileLock = danger.git.modified_files.includes('tests/Gemfile.lock')
if (changedGemfile && !changedGemfileLock) {
	const message = 'Changes were made to tests/Gemfile, but not to tests/Gemfile.lock'
	const idea = 'Perhaps you need to run `bundle install`?'
	warn(`${message} - <i>${idea}</i>`)
}

const changedWrapper = danger.git.modified_files.includes('dab')
// Changes to the dab wrapper script are to be avoided when possible.
if (changedWrapper) {
	warn('Changes to the dab wrapper script are to be avoided when possible as it is not automatically updated.')
}
