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

// Warn if changelog is not updated for non trivial patches.
const changedChangelog = danger.git.modified_files.includes('CHANGELOG.md');
if (!changedChangelog) {
	warn('Please add a changelog entry for your changes')
}

// Warn if there are changes to app, but not tests
const modifiedFiles = danger.git.modified_files
const changesApp = modifiedFiles.filter(filepath => filepath.includes('app'));
const changesSubcommands = changesApp.filter(filepath => filepath.includes('subcommands'));

const appChanges = modifiedFiles.filter(filepath => filepath.includes('app'));
const hasAppChanges = appChanges.length > 0;
const testChanges = modifiedFiles.filter(filepath => filepath.includes('tests'));
const hasTestChanges = appChanges.length > 0;
if (hasAppChanges && !hasTestChanges) {
	warn("There are changes to app , but not tests. That's OK as long as you're refactoring.");
}

// New subcommands should get new feature files for testing
const correspondingTestsForSubcommandChanges = changesSubcommands.map(f => {
	const changed = path.basename(f)
	const test = path.basename(changed).replace('.sh', '.feature')
	return `tests/features/${test}`
});
const missingTestFiles = correspondingTestsForSubcommandChanges.filter(f => fs.existsSync(f));
if (missingTestFiles.length > 0) {
	const output = `Missing Test Feature Files:
	${testFilesThatDontExist.map(f => `  - [] \`${f}\``).join("\n")}
	You cannot add a subcommand and not add some kind of test for it.`
	fail(output)
}
