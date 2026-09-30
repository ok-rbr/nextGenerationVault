"""Configuration management for vault-agent."""

from pathlib import Path

from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class VaultConfig(BaseModel):
    """Vault configuration settings."""

    root: Path = Field(
        default_factory=lambda: Path.cwd(),
        description="Absolute path to vault root",
    )
    staging_dir: str = Field(
        default="99_system/ai_staging",
        description="Relative path to staging directory for logs and artifacts",
    )
    schemas_dir: str = Field(
        default="99_system/05_schemas",
        description="Relative path to schemas directory",
    )
    index_dir: str = Field(
        default="99_system/ai_index",
        description="Relative path to local index directory",
    )


class Config(BaseSettings):
    """Main configuration for vault-agent CLI."""

    model_config = SettingsConfigDict(
        env_prefix="VOIDLINK_",
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        env_nested_delimiter="__",
    )

    vault: VaultConfig = Field(default_factory=VaultConfig)
    log_level: str = Field(default="INFO", description="Logging level")
    profile: str = Field(default="default", description="Configuration profile")

    @classmethod
    def from_file(cls, config_path: Path | None = None) -> "Config":
        """Load configuration from YAML file."""
        if config_path is None:
            config_path = Path.cwd() / "vault-agent.yml"

        if config_path.exists():
            import tomllib  # Python 3.11+

            with open(config_path, "rb") as f:
                data = tomllib.load(f)
            return cls(**data)
        return cls()

    def get_staging_path(self) -> Path:
        """Get absolute staging directory path."""
        staging = self.vault.root / self.vault.staging_dir
        staging.mkdir(parents=True, exist_ok=True)
        return staging

    def get_schemas_path(self) -> Path:
        """Get absolute schemas directory path."""
        schemas = self.vault.root / self.vault.schemas_dir
        schemas.mkdir(parents=True, exist_ok=True)
        return schemas

    def get_index_db_path(self, db_name: str = "vault.db") -> Path:
        """Get absolute path to the local SQLite index database."""
        index_dir = self.vault.root / self.vault.index_dir
        index_dir.mkdir(parents=True, exist_ok=True)
        return index_dir / db_name
