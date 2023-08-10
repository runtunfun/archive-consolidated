# git comments

A standardized commit message convention provides a consistent way to describe the nature of changes made in a commit. It helps make the change history more understandable and readable, and plays a vital role in automated tools like Semantic Release and Conventional Changelog.

A widely adopted commit message convention is the Conventional Commits specification. A commit in the Conventional Commits format looks like:

```html
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

Each part has a specific meaning:

- `type`: Describes the kind of changes made in the commit. Common types include `feat` (for new features), `fix` (for bug fixes), `chore` (for maintenance tasks), `docs` (for documentation), `style` (for format changes that don't modify the code), `refactor` (for code refactorings that neither add a feature nor fix a bug), `perf` (for performance improvements), and `test` (for adding or changing tests).
- `scope`: Optional. Describes the area of the changes, like a component or module name.
- `subject`: A brief description of the changes.
- `body`: Optional. A more detailed description of the changes.
- `footer`: Optional. Often used to reference related issue numbers or breaking changes.

Some examples of commit messages following this convention are:

`
feat(user-auth): add ability to reset password
`

`
fix(database): resolve connection issue
`

`
docs(readme): update installation instructions
`

Tools like Commitizen can be used to help you create correctly formatted commit messages.

| English           | German             |
|-------------------|--------------------|
| chore             | Aufgabe            |
| feat              | Funktion           |
| fix               | Korrektur          |
| docs              | Dokumentation      |
| style             | Stil               |
| refactor          | Refaktorisierung   |
| test              | Test               |
| perf              | Performance        |
| ci                | Continuous Integration |
| build             | Build              |
| revert            | Rückgängig machen  |
| ...               | ...                |
