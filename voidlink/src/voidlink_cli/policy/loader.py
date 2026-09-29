"""Load and evaluate AI policy and schema-backed metadata requirements."""

import json
from dataclasses import dataclass
from pathlib import Path

# Top-level folders of the vault, per 99_system/KONVENTIONEN.md. A policy path
# outside them cannot match any note.
VAULT_ROOTS = (
    "00_knowledge/",
    "01_projects/",
    "02_areas/",
    "03_resources/",
    "04_archive/",
    "99_system/",
)


def _normalize_prefix(path_value: str) -> str:
    value = path_value.strip().replace("\\", "/")
    return value if value.endswith("/") else f"{value}/"


def _parse_simple_yaml_policy(content: str) -> dict:
    """Parse the restricted ai_policy.yaml structure without external deps."""
    data: dict[str, object] = {}
    current_key: str | None = None

    for raw_line in content.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.endswith(":") and not line.startswith("-"):
            current_key = line[:-1].strip()
            data[current_key] = []
            continue
        if ":" in line and not line.startswith("-"):
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip().strip("'\"")
            if value.startswith("[") and value.endswith("]"):
                inner = value[1:-1].strip()
                if not inner:
                    data[key] = []
                else:
                    data[key] = [item.strip().strip("'\"") for item in inner.split(",")]
                current_key = None
                continue
            if value.lower() == "true":
                data[key] = True
            elif value.lower() == "false":
                data[key] = False
            else:
                data[key] = value
            current_key = None
            continue
        if line.startswith("-") and current_key:
            list_value = line[1:].strip().strip("'\"")
            existing = data.get(current_key, [])
            if isinstance(existing, list):
                existing.append(list_value)
                data[current_key] = existing

    return data


@dataclass(frozen=True)
class AIPolicy:
    """Normalized policy model for path and action controls."""

    protected_paths: tuple[str, ...]
    llm_excluded_paths: tuple[str, ...]
    forbidden_actions: tuple[str, ...]
    allowed_actions: tuple[str, ...]
    sensitive_paths: tuple[str, ...] = tuple()
    pii_keywords: tuple[str, ...] = ("ssn", "social security", "iban", "passport", "health")
    never_delete: bool = True
    never_overwrite_without_review: bool = True
    never_send_to_remote_llm: bool = True

    def is_protected_path(self, relative_path: str) -> bool:
        """Return True when path is policy-protected."""
        normalized = relative_path.strip().replace("\\", "/")
        return any(normalized.startswith(prefix) for prefix in self.protected_paths)

    def is_llm_excluded_path(self, relative_path: str) -> bool:
        """Return True when LLM use is forbidden for this path."""
        normalized = relative_path.strip().replace("\\", "/")
        return any(normalized.startswith(prefix) for prefix in self.llm_excluded_paths)

    def is_action_allowed(self, action: str) -> bool:
        """Return True when action is explicitly allowed by policy."""
        if action in self.forbidden_actions:
            return False
        if self.allowed_actions:
            return action in self.allowed_actions
        return True

    def is_sensitive_path(self, relative_path: str) -> bool:
        """Return True when the path belongs to a sensitive policy area."""
        normalized = relative_path.strip().replace("\\", "/")
        return any(normalized.startswith(prefix) for prefix in self.sensitive_paths)

    def contains_pii_text(self, text: str) -> bool:
        """Simple keyword-based PII/sensitive content detection."""
        lower = text.lower()
        return any(keyword in lower for keyword in self.pii_keywords)


def load_ai_policy(policy_path: Path) -> AIPolicy:
    """Load `ai_policy.yaml` and return a normalized policy object."""
    policy_path = Path(policy_path)
    if not policy_path.exists():
        raise FileNotFoundError(f"policy file not found: {policy_path}")

    raw = _parse_simple_yaml_policy(policy_path.read_text(encoding="utf-8"))
    protected_paths = tuple(_normalize_prefix(p) for p in raw.get("protected_paths", []))
    llm_excluded_paths = tuple(_normalize_prefix(p) for p in raw.get("llm_excluded_paths", []))
    sensitive_paths = tuple(_normalize_prefix(p) for p in raw.get("sensitive_paths", []))

    return AIPolicy(
        protected_paths=protected_paths,
        llm_excluded_paths=llm_excluded_paths,
        forbidden_actions=tuple(raw.get("forbidden_actions", [])),
        allowed_actions=tuple(raw.get("allowed_actions", [])),
        sensitive_paths=sensitive_paths,
        pii_keywords=tuple(
            raw.get("pii_keywords", ("ssn", "social security", "iban", "passport", "health"))
        ),
        never_delete=bool(raw.get("never_delete", True)),
        never_overwrite_without_review=bool(raw.get("never_overwrite_without_review", True)),
        never_send_to_remote_llm=bool(raw.get("never_send_to_remote_llm", True)),
    )


def find_dead_policy_paths(policy: AIPolicy, vault_root: Path | None = None) -> list[str]:
    """Return one message per policy path that cannot match any note.

    A prefix that matches nothing raises no error on its own: the rule is simply
    off (#32, where ``20_areas/`` was configured for a vault that uses
    ``02_areas/``). This reports prefixes outside the vault roots and, when
    ``vault_root`` is given, prefixes whose directory does not exist.
    """
    messages: list[str] = []
    lists = (
        ("protected_paths", policy.protected_paths),
        ("llm_excluded_paths", policy.llm_excluded_paths),
        ("sensitive_paths", policy.sensitive_paths),
    )
    for name, prefixes in lists:
        for prefix in prefixes:
            if not prefix.startswith(VAULT_ROOTS):
                messages.append(
                    f"{name}: {prefix} is outside the vault roots {', '.join(VAULT_ROOTS)}"
                )
            elif vault_root is not None and not (Path(vault_root) / prefix).is_dir():
                messages.append(f"{name}: {prefix} does not exist in {vault_root}")
    return messages


def load_required_frontmatter_fields(schema_path: Path) -> list[str]:
    """Read required frontmatter fields from a JSON schema file."""
    schema_path = Path(schema_path)
    if not schema_path.exists():
        return []

    data = json.loads(schema_path.read_text(encoding="utf-8"))
    required = data.get("required", [])
    if isinstance(required, list):
        return [str(field) for field in required]
    return []
