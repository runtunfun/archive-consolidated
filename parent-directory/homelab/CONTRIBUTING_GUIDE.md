# 🤝 Contributing to Homelab

We love your input! We want to make contributing to the Homelab project as easy and transparent as possible, whether it's:

- 🐛 Reporting a bug
- 💡 Discussing the current state of the code
- 🔧 Submitting a fix
- 🚀 Proposing new features
- 📚 Improving documentation
- 🎨 Contributing templates

## 🌟 Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/homelab.git
   cd homelab
   ```
3. **Set up the development environment**:
   ```bash
   ./scripts/setup/setup-environment.sh
   source venv/bin/activate
   ```
4. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/original-owner/homelab.git
   ```

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
2. **Make your changes** (see specific contribution types below)
3. **Test your changes** thoroughly
4. **Commit your changes**:
   ```bash
   git commit -m "feat: add amazing feature"
   ```
5. **Push to your fork**:
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Create a Pull Request** on GitHub

## 📝 Types of Contributions

### 🐛 Bug Reports

**Great Bug Reports** tend to have:

- **Clear summary** of the issue
- **Specific steps** to reproduce the problem
- **Expected vs actual behavior**
- **Environment details** (OS, Python version, etc.)
- **Anonymized configuration** that reproduces the issue

#### Bug Report Template
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Configure '...'
2. Run '....'
3. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- OS: [e.g. Ubuntu 22.04]
- Python version: [e.g. 3.10.2]
- Ansible version: [e.g. 2.13.1]

**Configuration (anonymized):**
```yaml
# Your configuration with sensitive data removed
```

**Additional context**
Any other context about the problem.
```

### 💡 Feature Requests

**Great Feature Requests** include:

- **Use case description** - What problem does this solve?
- **Proposed solution** - How should it work?
- **Alternative solutions** - What other approaches did you consider?
- **Implementation details** - Technical considerations (optional)

#### Feature Request Template
```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Use case examples**
Concrete examples of how this feature would be used.

**Implementation notes**
Any technical considerations or suggestions.
```

### 🔧 Code Contributions

#### Python Code (Documentation Generator)

**Standards:**
- **PEP 8** compliance (use `black` for formatting)
- **Type hints** for all functions
- **Docstrings** for all public functions
- **Unit tests** for new functionality

**Example:**
```python
def validate_network_config(config: Dict[str, Any]) -> List[str]:
    """
    Validate network configuration for common issues.
    
    Args:
        config: Network configuration dictionary
        
    Returns:
        List of validation error messages
        
    Raises:
        ValueError: If config structure is invalid
    """
    errors = []
    # Implementation here
    return errors
```

**Testing:**
```bash
# Run tests
python -m pytest tests/

# Run linting
python -m flake8 scripts/
python -m black scripts/ --check

# Run type checking
python -m mypy scripts/
```

#### Bash Scripts

**Standards:**
- **Set strict mode**: `set -euo pipefail`
- **Use shellcheck**: `shellcheck script.sh`
- **Comprehensive error handling**
- **Clear documentation** and comments

**Example:**
```bash
#!/bin/bash
# Description: What this script does
# Usage: ./script.sh [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

main() {
    local config_path="${1:-}"
    
    if [[ -z "$config_path" ]]; then
        echo "Usage: $0 <config-path>" >&2
        exit 1
    fi
    
    # Implementation here
}

main "$@"
```

#### Ansible Code

**Standards:**
- **YAML lint** compliance
- **Ansible lint** compliance
- **Idempotent** playbooks
- **Molecule tests** for roles
- **Clear role documentation**

**Role Structure:**
```
roles/new-role/
├── README.md              # Role documentation
├── defaults/main.yml      # Default variables
├── tasks/main.yml         # Main tasks
├── handlers/main.yml      # Handlers
├── templates/             # Jinja2 templates
├── files/                 # Static files
├── vars/main.yml          # Role variables
├── meta/main.yml          # Role metadata
└── molecule/              # Molecule tests
    └── default/
        ├── molecule.yml
        ├── playbook.yml
        └── tests/
```

**Testing:**
```bash
# Ansible syntax check
ansible-playbook --syntax-check playbooks/site.yml

# Ansible lint
ansible-lint playbooks/ roles/

# Molecule test
cd roles/new-role
molecule test
```

### 📚 Documentation Contributions

#### Template Contributions

**Template Standards:**
- **Use example data** (lab.local, 192.168.x.x)
- **Comprehensive Jinja2 comments**
- **Responsive design** considerations
- **Accessibility** best practices

**Template Structure:**
```jinja2
{# 
Template: Service Documentation
Description: Generates documentation for homelab services
Variables:
  - services: Dictionary of service configurations
  - domain: Domain configuration
#}

# {{ service_name | title }} Service

## Overview
{{ service_config.description | default("Service description") }}

## Access Information
- **URL:** [{{ service_config.host }}](http://{{ service_config.host }}{% if service_config.port %}:{{ service_config.port }}{% endif %})
- **IP Address:** {{ service_config.ip }}
{% if service_config.admin_port %}
- **Admin Interface:** [Admin](http://{{ service_config.host }}:{{ service_config.admin_port }})
{% endif %}

## Configuration
```yaml
# Example configuration
{{ service_name }}:
  enabled: {{ service_config.enabled | default(true) }}
  host: "{{ service_config.host }}"
  ip: "{{ service_config.ip }}"
```
```

#### Documentation Standards

- **Clear headings** and structure
- **Code examples** with syntax highlighting
- **Screenshots** when helpful (anonymized)
- **Cross-references** to related documentation
- **Mobile-friendly** formatting

### 🎨 Design Contributions

#### CSS/Styling

**Standards:**
- **Follow Material Design** principles
- **Mobile-first** responsive design
- **Dark mode** support
- **Accessibility** (WCAG 2.1 AA)

**File Structure:**
```
templates/
└── docs/
    └── stylesheets/
        ├── extra.css           # Main customizations
        ├── components/         # Component-specific styles
        │   ├── navigation.css
        │   ├── tables.css
        │   └── code.css
        └── themes/            # Theme variations
            ├── dark.css
            └── custom.css
```

#### Asset Guidelines

- **Images:** PNG/SVG preferred, optimize for web
- **Icons:** Use Material Design Icons when possible
- **Logo:** SVG format with dark/light variants
- **Screenshots:** Anonymize sensitive information

## 🧪 Testing Guidelines

### Testing Requirements

**All contributions must include:**
- ✅ **Unit tests** for new Python functions
- ✅ **Integration tests** for script workflows
- ✅ **Template validation** for Jinja2 templates
- ✅ **Configuration validation** for example configs

### Test Structure

```
tests/
├── unit/                  # Unit tests
│   ├── test_generator.py
│   ├── test_validator.py
│   └── test_templates.py
├── integration/           # Integration tests
│   ├── test_build_pipeline.py
│   ├── test_ansible_syntax.py
│   └── test_documentation_generation.py
├── fixtures/              # Test data
│   ├── configs/
│   └── templates/
└── conftest.py           # Pytest configuration
```

### Running Tests

```bash
# Run all tests
python -m pytest

# Run specific test category
python -m pytest tests/unit/
python -m pytest tests/integration/

# Run with coverage
python -m pytest --cov=scripts

# Run performance tests
python -m pytest tests/performance/ --benchmark-only
```

### Test Examples

#### Unit Test Example
```python
import pytest
from scripts.generator.generate_docs import HomeLabDocGenerator

def test_network_config_validation():
    """Test network configuration validation."""
    generator = HomeLabDocGenerator(Path("/tmp"))
    
    # Valid configuration
    valid_config = {
        "networks": {
            "management": {
                "vlan_id": 10,
                "subnet": "192.168.10.0/24"
            }
        }
    }
    errors = generator.validate_network_config(valid_config)
    assert len(errors) == 0
    
    # Invalid configuration
    invalid_config = {"networks": {}}
    errors = generator.validate_network_config(invalid_config)
    assert len(errors) > 0
```

#### Integration Test Example
```python
def test_full_documentation_generation(tmp_path):
    """Test complete documentation generation workflow."""
    # Setup test environment
    config_dir = tmp_path / "config"
    config_dir.mkdir()
    
    # Create test configuration
    (config_dir / "network.yml").write_text("""
    domain:
      internal: "test.local"
    networks:
      management:
        vlan_id: 10
        subnet: "192.168.10.0/24"
    """)
    
    # Run generator
    generator = HomeLabDocGenerator(tmp_path, config_dir)
    generator.load_config()
    generator.generate_docs()
    
    # Verify output
    assert (tmp_path / "docs" / "index.md").exists()
    content = (tmp_path / "docs" / "index.md").read_text()
    assert "test.local" in content
```

## 📋 Pull Request Process

### Before Submitting

1. ✅ **Update documentation** if you've changed APIs or added features
2. ✅ **Add tests** for new functionality
3. ✅ **Run the test suite** and ensure all tests pass
4. ✅ **Check code style** with linting tools
5. ✅ **Update CHANGELOG.md** if applicable
6. ✅ **Ensure backwards compatibility** or document breaking changes

### Pull Request Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] 🚀 New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🎨 Style/formatting changes
- [ ] ♻️ Code refactoring
- [ ] ⚡ Performance improvements
- [ ] 🧪 Test improvements

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Documentation builds successfully

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Additional Notes
Any additional information that reviewers should know.
```

### Review Process

1. **Automated checks** must pass (CI/CD)
2. **At least one maintainer** must review
3. **All feedback** must be addressed
4. **Documentation** must be updated
5. **Tests** must pass

## 🏷️ Commit Convention

We use [Conventional Commits](https://conventionalcommits.org/) for consistent commit messages:

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, etc.)
- **refactor:** Code refactoring
- **test:** Adding or modifying tests
- **chore:** Maintenance tasks

### Examples
```bash
feat(generator): add multi-environment configuration support

Add support for environment-specific configuration overrides.
This allows users to maintain separate configs for dev/test/prod.

Closes #123

fix(ansible): resolve docker role compatibility with Ubuntu 22.04

- Update package repository URLs
- Fix deprecated apt key handling
- Add compatibility checks

Fixes #456

docs(templates): add homeassistant service template

Add comprehensive template for Home Assistant documentation
including setup instructions and configuration examples.
```

## 🎯 Contribution Areas

### High Priority

1. **🚀 Service Templates**
   - Prometheus/Grafana monitoring
   - Nextcloud file sharing
   - Plex media server
   - Jellyfin media server
   - Vaultwarden password manager

2. **🔧 Ansible Roles**
   - SSL certificate automation
   - Backup strategies
   - Network monitoring
   - Security hardening

3. **📚 Documentation**
   - Video tutorials
   - Troubleshooting guides
   - Best practices
   - Migration guides

4. **🧪 Testing**
   - Integration test coverage
   - Performance testing
   - Cross-platform testing

### Medium Priority

1. **🎨 UI/UX Improvements**
   - Custom themes
   - Interactive diagrams
   - Mobile optimization
   - Accessibility improvements

2. **⚡ Performance**
   - Build optimization
   - Template caching
   - Parallel processing

3. **🔌 Integrations**
   - GitHub Actions workflows
   - GitLab CI integration
   - Docker deployment
   - Kubernetes support

### Community Contributions

1. **💬 Discussions**
   - Share your homelab setups
   - Discuss best practices
   - Help other users

2. **🌟 Showcase**
   - Blog posts about your usage
   - Social media mentions
   - Conference presentations

3. **🔗 Ecosystem**
   - Related tool integrations
   - Plugin development
   - Extension libraries

## 🏆 Recognition

Contributors who make significant contributions will be:

- **Added to CONTRIBUTORS.md**
- **Mentioned in release notes**
- **Invited to join the maintainer team** (for ongoing contributors)
- **Featured in project README** (for major contributions)

## 🆘 Getting Help

### Questions?

- **GitHub Discussions** - General questions and community chat
- **GitHub Issues** - Bug reports and feature requests
- **Discord** - Real-time chat with maintainers and community
- **Email** - For private/security concerns

### Mentorship

New contributors are welcome! We offer mentorship for:

- First-time open source contributors
- Complex feature development
- Understanding the codebase
- Best practices guidance

## 📚 Resources

### Documentation
- [Project README](README.md)
- [Quick Start Guide](QUICKSTART.md)
- [Architecture Overview](docs/ARCHITECTURE.md)
- [API Documentation](docs/API.md)

### Tools
- [Conventional Commits](https://conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

### Learning Resources
- [Ansible Documentation](https://docs.ansible.com/)
- [MkDocs Documentation](https://mkdocs.org/)
- [Jinja2 Template Documentation](https://jinja.palletsprojects.com/)

---

**Thank you for contributing to making homelab management better for everyone!** 🎉

*Questions about contributing? Open a discussion or reach out to the maintainers.*