#!/usr/bin/env python3
"""
Homelab Documentation Generator
Generiert finale Dokumentation aus Templates und Konfigurationsdateien
"""

import os
import sys
import yaml
import argparse
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, Template
import shutil
from typing import Dict, Any, List
import datetime


class HomeLabDocGenerator:
    def __init__(self, project_root: Path, config_path: Path = None):
        self.project_root = project_root
        self.config_path = config_path or project_root / "config-example"
        self.templates_dir = project_root / "templates"
        self.output_dir = project_root / "docs"
        
        # Jinja2 Environment
        self.env = Environment(
            loader=FileSystemLoader(str(self.templates_dir)),
            trim_blocks=True,
            lstrip_blocks=True
        )
        
        # Add custom filters
        self.env.filters['replace'] = self._filter_replace
        
        self.config = {}
        self.verbose = False
        
    def _filter_replace(self, value: str, old: str, new: str) -> str:
        """Custom Jinja2 filter for string replacement"""
        return str(value).replace(old, new)
        
    def set_verbose(self, verbose: bool):
        """Enable verbose output"""
        self.verbose = verbose
        
    def _log(self, message: str, level: str = "INFO"):
        """Log message if verbose mode enabled"""
        if self.verbose:
            timestamp = datetime.datetime.now().strftime("%H:%M:%S")
            print(f"[{timestamp}] {level}: {message}")
    
    def load_config(self) -> Dict[str, Any]:
        """Lädt alle Konfigurationsdateien"""
        config_files = [
            "network.yml",
            "services.yml", 
            "infrastructure.yml",
            "documentation.yml"
        ]
        
        combined_config = {}
        
        self._log(f"Loading configuration from: {self.config_path}")
        
        for config_file in config_files:
            file_path = self.config_path / config_file
            if file_path.exists():
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        section_config = yaml.safe_load(f)
                        if section_config:
                            combined_config.update(section_config)
                            self._log(f"✅ Loaded: {config_file}")
                        else:
                            self._log(f"⚠️  Empty config file: {config_file}", "WARN")
                except yaml.YAMLError as e:
                    self._log(f"❌ YAML error in {config_file}: {e}", "ERROR")
                    raise
                except Exception as e:
                    self._log(f"❌ Error loading {config_file}: {e}", "ERROR")
                    raise
            else:
                self._log(f"⚠️  Missing: {config_file}", "WARN")
        
        # Environment-spezifische Konfiguration laden
        env_name = os.getenv('HOMELAB_ENV', 'production')
        env_file = self.config_path / "environments" / f"{env_name}.yml"
        
        if env_file.exists():
            try:
                with open(env_file, 'r', encoding='utf-8') as f:
                    env_config = yaml.safe_load(f)
                    if env_config:
                        # Environment-Config hat Priorität
                        self._deep_merge(combined_config, env_config)
                        self._log(f"✅ Loaded environment: {env_name}")
            except Exception as e:
                self._log(f"❌ Error loading environment {env_name}: {e}", "ERROR")
                raise
        else:
            self._log(f"ℹ️  No environment config for: {env_name}")
        
        # Add metadata
        combined_config['_metadata'] = {
            'generated_at': datetime.datetime.now().isoformat(),
            'environment': env_name,
            'config_path': str(self.config_path),
            'generator_version': '1.0.0'
        }
        
        self.config = combined_config
        return combined_config
    
    def _deep_merge(self, base_dict: Dict, override_dict: Dict) -> None:
        """Merged Dictionaries rekursiv"""
        for key, value in override_dict.items():
            if key in base_dict and isinstance(base_dict[key], dict) and isinstance(value, dict):
                self._deep_merge(base_dict[key], value)
            else:
                base_dict[key] = value
    
    def validate_config(self) -> List[str]:
        """Validiert die Konfiguration"""
        errors = []
        
        self._log("Validating configuration...")
        
        # Pflicht-Felder prüfen
        required_fields = [
            "domain.internal",
            "networks",
            "services"
        ]
        
        for field in required_fields:
            value = self._get_nested_value(self.config, field)
            if value is None:
                errors.append(f"Missing required field: {field}")
                self._log(f"❌ Missing required field: {field}", "ERROR")
        
        # Netzwerk-Validierung
        if 'networks' in self.config:
            for network_name, network_config in self.config['networks'].items():
                if not isinstance(network_config, dict):
                    errors.append(f"Network '{network_name}' must be a dictionary")
                    continue
                    
                required_network_fields = ['vlan_id', 'subnet', 'gateway']
                for field in required_network_fields:
                    if field not in network_config:
                        errors.append(f"Network '{network_name}' missing field: {field}")
        
        # Service-Validierung
        if 'services' in self.config:
            for service_name, service_config in self.config['services'].items():
                if not isinstance(service_config, dict):
                    continue
                    
                if service_config.get('enabled', False):
                    required_service_fields = ['host', 'ip']
                    for field in required_service_fields:
                        if field not in service_config:
                            errors.append(f"Enabled service '{service_name}' missing field: {field}")
        
        if errors:
            self._log(f"❌ Validation failed with {len(errors)} errors", "ERROR")
        else:
            self._log("✅ Configuration validation passed")
            
        return errors
    
    def _get_nested_value(self, data: Dict, path: str) -> Any:
        """Holt verschachtelte Werte über Punkt-Notation"""
        keys = path.split('.')
        current = data
        
        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return None
        return current
    
    def generate_docs(self) -> None:
        """Generiert die komplette Dokumentation"""
        self._log("🏗️  Generating documentation...")
        
        # Output-Verzeichnis vorbereiten
        if self.output_dir.exists():
            self._log("🧹 Cleaning previous build...")
            shutil.rmtree(self.output_dir)
        self.output_dir.mkdir(parents=True)
        
        # Templates rekursiv verarbeiten
        docs_templates = self.templates_dir / "docs"
        if docs_templates.exists():
            self._process_directory(docs_templates, self.output_dir)
        else:
            self._log("⚠️  No docs templates found", "WARN")
        
        # MkDocs Konfiguration generieren
        self._generate_mkdocs_config()
        
        # Statische Dateien kopieren
        self._copy_static_files()
        
        self._log("✅ Documentation generation completed!")
        self._log(f"📁 Output directory: {self.output_dir}")
    
    def _process_directory(self, template_dir: Path, output_dir: Path) -> None:
        """Verarbeitet ein Verzeichnis rekursiv"""
        output_dir.mkdir(parents=True, exist_ok=True)
        
        for item in template_dir.iterdir():
            if item.is_file():
                if item.suffix == '.j2':
                    # Template-Datei verarbeiten
                    output_file = output_dir / item.stem
                    self._render_template_file(item, output_file)
                else:
                    # Statische Datei kopieren
                    shutil.copy2(item, output_dir / item.name)
                    self._log(f"📄 Copied: {item.name}")
            elif item.is_dir():
                # Verzeichnis rekursiv verarbeiten
                self._process_directory(item, output_dir / item.name)
    
    def _render_template_file(self, template_file: Path, output_file: Path) -> None:
        """Rendert eine einzelne Template-Datei"""
        try:
            # Relativen Pfad zum Templates-Verzeichnis bestimmen
            relative_path = template_file.relative_to(self.templates_dir)
            
            self._log(f"🔄 Processing: {relative_path}")
            
            # Template laden und rendern
            template = self.env.get_template(str(relative_path))
            
            # Erweiterte Template-Variablen
            template_vars = {
                'config': self.config,
                **self.config,  # Alle Config-Keys als direkte Variablen
                'ansible_date_time': {
                    'iso8601': datetime.datetime.now().isoformat()
                }
            }
            
            rendered_content = template.render(**template_vars)
            
            # Ausgabe schreiben
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(rendered_content)
            
            self._log(f"📝 Generated: {output_file.name}")
            
        except Exception as e:
            self._log(f"❌ Error rendering {template_file}: {e}", "ERROR")
            raise
    
    def _generate_mkdocs_config(self) -> None:
        """Generiert MkDocs-Konfiguration"""
        try:
            mkdocs_template_path = self.templates_dir / "mkdocs.yml.j2"
            
            if not mkdocs_template_path.exists():
                self._log("⚠️  No mkdocs.yml.j2 template found, creating default", "WARN")
                self._create_default_mkdocs_config()
                return
            
            template = self.env.get_template('mkdocs.yml.j2')
            
            # Template-Variablen für MkDocs
            template_vars = {
                'config': self.config,
                **self.config,
                'ansible_date_time': {
                    'iso8601': datetime.datetime.now().isoformat()
                }
            }
            
            content = template.render(**template_vars)
            
            config_file = self.project_root / "mkdocs.yml"
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self._log("📝 Generated: mkdocs.yml")
            
        except Exception as e:
            self._log(f"❌ Error generating mkdocs.yml: {e}", "ERROR")
            self._create_default_mkdocs_config()
    
    def _create_default_mkdocs_config(self) -> None:
        """Erstellt Standard MkDocs-Konfiguration"""
        self._log("📝 Creating default mkdocs.yml")
        
        site_name = self.config.get('site', {}).get('name', 'Homelab Documentation')
        site_description = self.config.get('site', {}).get('description', 'Homelab infrastructure documentation')
        
        default_config = f"""# Generated MkDocs configuration
site_name: "{site_name}"
site_description: "{site_description}"

theme:
  name: material
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.tabs
    - navigation.sections
    - navigation.top
    - search.highlight
    - search.share
    - content.code.copy

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - attr_list
  - md_in_html
  - tables
  - toc:
      permalink: true

plugins:
  - search

docs_dir: docs
site_dir: site
"""
        
        config_file = self.project_root / "mkdocs.yml"
        with open(config_file, 'w', encoding='utf-8') as f:
            f.write(default_config)
    
    def _copy_static_files(self) -> None:
        """Kopiert statische Dateien"""
        static_dirs = ['assets', 'stylesheets', 'images', 'img']
        
        for static_dir in static_dirs:
            src = self.templates_dir / static_dir
            if src.exists():
                dst = self.output_dir / static_dir
                shutil.copytree(src, dst, dirs_exist_ok=True)
                self._log(f"📁 Copied: {static_dir}/")


def main():
    parser = argparse.ArgumentParser(
        description="Generate homelab documentation from templates and configuration",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --config ./config-local
  %(prog)s --config ./config-prod --env production
  %(prog)s --validate-only --config ./config-test
  %(prog)s --verbose --config ./config-local

Environment Variables:
  HOMELAB_ENV              Environment name (production, test, development)
  HOMELAB_CONFIG_PATH      Path to configuration directory
        """
    )
    
    parser.add_argument("--config", "-c", type=Path, 
                       help="Path to configuration directory")
    parser.add_argument("--env", "-e", 
                       help="Environment name (production, test, development)")
    parser.add_argument("--validate-only", action="store_true",
                       help="Only validate configuration without generating docs")
    parser.add_argument("--verbose", "-v", action="store_true",
                       help="Enable verbose output")
    
    args = parser.parse_args()
    
    # Environment setzen
    if args.env:
        os.environ['HOMELAB_ENV'] = args.env
    
    # Project Root bestimmen
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent
    
    # Konfigurationspfad bestimmen
    config_path = args.config or os.getenv('HOMELAB_CONFIG_PATH')
    if config_path:
        config_path = Path(config_path)
    else:
        # Standard-Pfade probieren
        for default_path in ['config-local', 'config-example']:
            candidate = project_root / default_path
            if candidate.exists():
                config_path = candidate
                break
        
        if not config_path:
            print("❌ No configuration directory found!")
            print("Specify with --config or create config-local/")
            sys.exit(1)
    
    # Generator initialisieren
    generator = HomeLabDocGenerator(project_root, config_path)
    generator.set_verbose(args.verbose)
    
    # Startmeldung
    env_name = os.getenv('HOMELAB_ENV', 'production')
    print(f"🚀 Homelab Documentation Generator")
    print(f"📁 Project root: {project_root}")
    print(f"📋 Configuration: {config_path}")
    print(f"🔧 Environment: {env_name}")
    print("")
    
    # Konfiguration laden
    try:
        print("📖 Loading configuration...")
        generator.load_config()
        print("✅ Configuration loaded successfully")
    except Exception as e:
        print(f"❌ Failed to load configuration: {e}")
        sys.exit(1)
    
    # Validierung
    print("🔍 Validating configuration...")
    errors = generator.validate_config()
    if errors:
        print("❌ Configuration validation failed:")
        for error in errors:
            print(f"   - {error}")
        sys.exit(1)
    else:
        print("✅ Configuration validation passed")
    
    if args.validate_only:
        print("🎯 Validation completed successfully")
        print(f"📊 Configuration summary:")
        print(f"   - Networks: {len(generator.config.get('networks', {}))}")
        print(f"   - Services: {len(generator.config.get('services', {}))}")
        enabled_services = sum(1 for s in generator.config.get('services', {}).values() 
                              if isinstance(s, dict) and s.get('enabled', False))
        print(f"   - Enabled services: {enabled_services}")
        return
    
    # Dokumentation generieren
    try:
        print("")
        print("🏗️  Generating documentation...")
        generator.generate_docs()
        print("")
        print("🎉 Documentation generation completed successfully!")
        
        # Zusammenfassung
        print("")
        print("📊 Generation summary:")
        print(f"   - Environment: {env_name}")
        print(f"   - Configuration: {config_path.name}")
        print(f"   - Output: {generator.output_dir}")
        print(f"   - Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Nächste Schritte
        print("")
        print("🚀 Next steps:")
        print("   1. Review generated documentation in docs/")
        print("   2. Start development server: ./scripts/build/develop.sh")
        print("   3. Build for production: ./scripts/build/build.sh")
        
    except Exception as e:
        print(f"❌ Documentation generation failed: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
