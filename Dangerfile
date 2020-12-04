# -----------------------------------------------------------------------------
# Changed library files, but didn't add/update tests
# -----------------------------------------------------------------------------
all_changed_files = (git.added_files + git.modified_files + git.deleted_files)

has_source_changes = !all_changed_files.grep(/Sources/).empty?
has_test_changes = !all_changed_files.grep(/Tests/).empty?
if has_source_changes && !has_test_changes
    warn("Library files were updated without test coverage. Please update or add tests, if possible!")
end

# -----------------------------------------------------------------------------
# Pull request is too large to review
# -----------------------------------------------------------------------------
if git.lines_of_code > 600
    warn("This is a large pull request! Can you break it up into multiple smaller ones instead?")
end

# -----------------------------------------------------------------------------
# All pull requests need a description
# -----------------------------------------------------------------------------
if github.pr_body.length < 25
    fail("Please provide a detailed summary in the pull request description.")
end

# -----------------------------------------------------------------------------
# All pull requests should be submitted to dev/develop branch
# -----------------------------------------------------------------------------
if github.branch_for_base != "dev" && github.branch_for_base != "develop"
    warn("Pull requests should be submitted to the dev branch only.")
end

# -----------------------------------------------------------------------------
# CHANGELOG entries are required for changes to library files
# -----------------------------------------------------------------------------
no_changelog_entry = !git.modified_files.include?("CHANGELOG.md")
if has_source_changes && no_changelog_entry
    warn("There is no CHANGELOG entry. Do you need to add one?")
end

# -----------------------------------------------------------------------------
# Milestones are required for all PRs to track what's included in each release
# -----------------------------------------------------------------------------
has_milestone = github.pr_json["milestone"] != nil
warn('All pull requests should have a milestone.', sticky: false) unless has_milestone

# -----------------------------------------------------------------------------
# Docs are regenerated when releasing
# -----------------------------------------------------------------------------
has_doc_changes = !git.modified_files.grep(/docs\//).empty?
if has_doc_changes
    fail("Documentation cannot be edited directly.")
    message(%(Docs are automatically regenerated when creating new releases using [Jazzy](https://github.com/realm/jazzy).
        If you want to update docs, please update the doc comments or markdown files directly.))
end

# -----------------------------------------------------------------------------
# Verify correct `pod install` and `bundle install`
# -----------------------------------------------------------------------------
def files_changed_as_set(files)
    changed_files = files.select { |file| git.modified_files.include? file }
    not_changed_files = files.select { |file| !changed_files.include? file }
    all_files_changed = not_changed_files.empty?
    no_files_changed = changed_files.empty?
    return all_files_changed || no_files_changed
end

# Verify proper pod install
pod_files = ["Podfile", "Podfile.lock", "Pods/Manifest.lock"]
if !files_changed_as_set(pod_files)
    fail("CocoaPods error: #{pod_files} should all be changed at the same time. Run `pod install` and commit the changes to fix.")
end

# Verify proper bundle install
gem_files = ["Gemfile", "Gemfile.lock"]
if !files_changed_as_set(gem_files)
    fail("Bundler error: #{gem_files} should all be changed at the same time. Run `bundle install` and commit the changes to fix.")
end

# -----------------------------------------------------------------------------
# Lint all changed markdown files
# -----------------------------------------------------------------------------
markdown_files = (git.added_files + git.modified_files).grep(%r{.*\.md/})
unless markdown_files.empty?
    # Run proselint to check prose and check spelling
    prose.language = "en-us"
    prose.ignore_acronyms = true
    prose.ignore_numbers = true
    prose.ignored_words = ["jessesquires", "swiftpm", "iOS",
        "macOS", "watchOS", "tvOS", "Xcode", "JSQCoreDataKit"
    ]
    prose.lint_files markdown_files
    prose.check_spelling markdown_files
end

# -----------------------------------------------------------------------------
# Run SwiftLint
# -----------------------------------------------------------------------------
swiftlint.verbose = true
swiftlint.config_file = './.swiftlint.yml'
swiftlint.lint_files(inline_mode: true, fail_on_error: true)

# -----------------------------------------------------------------------------
# Jazzy docs - check for new, undocumented symbols
# -----------------------------------------------------------------------------
jazzy.check fail: :all
