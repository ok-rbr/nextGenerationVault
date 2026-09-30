"""Tests for configuration management."""

from voidlink_cli.config import Config, VaultConfig


def test_vault_config_defaults():
    """Test VaultConfig defaults."""
    config = VaultConfig()
    assert config.staging_dir == "99_system/ai_staging"
    assert config.schemas_dir == "99_system/05_schemas"
    assert config.index_dir == "99_system/ai_index"


def test_config_defaults():
    """Test Config defaults."""
    config = Config()
    assert config.log_level == "INFO"
    assert config.profile == "default"


def test_config_get_staging_path(tmp_path):
    """Test staging path creation."""
    config = Config(vault=VaultConfig(root=tmp_path))
    staging = config.get_staging_path()
    assert staging.exists()
    assert staging == tmp_path / "99_system" / "ai_staging"


def test_config_get_schemas_path(tmp_path):
    """Test schemas path creation."""
    config = Config(vault=VaultConfig(root=tmp_path))
    schemas = config.get_schemas_path()
    assert schemas.exists()
    assert schemas == tmp_path / "99_system" / "05_schemas"


def test_config_nested_path_creation(tmp_path):
    """Test nested directory creation."""
    config = Config(vault=VaultConfig(root=tmp_path))
    staging = config.get_staging_path()
    schemas = config.get_schemas_path()
    assert staging.parent.exists()
    assert schemas.parent.exists()


def test_config_get_index_db_path(tmp_path):
    """Test index database path creation."""
    config = Config(vault=VaultConfig(root=tmp_path))
    db_path = config.get_index_db_path()
    assert db_path.parent.exists()
    assert db_path == tmp_path / "99_system" / "ai_index" / "vault.db"


def test_config_reads_prefixed_env(tmp_path, monkeypatch):
    """Test the documented VOIDLINK_ variables are read."""
    monkeypatch.setenv("VOIDLINK_VAULT__ROOT", str(tmp_path))
    monkeypatch.setenv("VOIDLINK_VAULT__STAGING_DIR", "staging")
    monkeypatch.setenv("VOIDLINK_LOG_LEVEL", "DEBUG")
    monkeypatch.setenv("VOIDLINK_PROFILE", "test")
    config = Config()
    assert config.vault.root == tmp_path
    assert config.vault.staging_dir == "staging"
    assert config.log_level == "DEBUG"
    assert config.profile == "test"


def test_config_ignores_unprefixed_env(tmp_path, monkeypatch):
    """Test unprefixed variables no longer configure vault-agent."""
    monkeypatch.chdir(tmp_path)
    monkeypatch.delenv("VOIDLINK_VAULT__ROOT", raising=False)
    monkeypatch.delenv("VOIDLINK_LOG_LEVEL", raising=False)
    monkeypatch.setenv("VAULT__ROOT", str(tmp_path / "elsewhere"))
    monkeypatch.setenv("LOG_LEVEL", "DEBUG")
    config = Config()
    assert config.vault.root == tmp_path
    assert config.log_level == "INFO"
