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
if github.pr_body.length < 15
    fail("Please provide a detailed summary in the pull request description.")
end

# -----------------------------------------------------------------------------
# Fail on TODOs in code
# -----------------------------------------------------------------------------
todoist.message = "Oops! We should not commit TODOs. Please fix them before merging."
todoist.fail_for_todos

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
