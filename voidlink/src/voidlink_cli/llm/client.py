"""LLM client for Ollama integration."""

import json
from dataclasses import dataclass

import httpx

_DEBUG_BOX_WIDTH = 73  # Total width of debug box borders


@dataclass
class LLMResponse:
    """Response from LLM."""

    success: bool
    content: str | None
    error: str | None
    model: str
    tokens: int


class OllamaClient:
    """Wrapper for Ollama/Qwen3 inference (HTTP-based)."""

    def __init__(
        self, host: str = "http://localhost:11434", model: str = "qwen3", debug: bool = False
    ):
        """Initialize Ollama client."""
        self.host = host
        self.model = model
        self.debug = debug
        self.client = httpx.Client(timeout=60.0)
        self.available = self._check_health()

    def _check_health(self) -> bool:
        """Check if Ollama is accessible."""
        try:
            response = self.client.get(f"{self.host}/api/tags")
            if response.status_code == 200:
                data = response.json()
                models = [m["name"] for m in data.get("models", [])]
                return any(self.model in m for m in models)
            return False
        except Exception:
            return False

    def generate(self, prompt: str, temperature: float = 0.3, num_predict: int = 200) -> str:
        """Generate text using Ollama."""
        if self.debug:
            header = "─ LLM PROMPT "
            print(f"\n\033[36m┌{header}" + "─" * (_DEBUG_BOX_WIDTH - len(header) - 1))
            for line in prompt.splitlines():
                print(f"\033[36m│ {line}")
            print("└" + "─" * _DEBUG_BOX_WIDTH + "\033[0m")

        try:
            response = self.client.post(
                f"{self.host}/api/generate",
                json={
                    "model": self.model,
                    "prompt": prompt,
                    "stream": False,
                    "options": {"temperature": temperature, "num_predict": num_predict},
                },
            )
            if response.status_code == 200:
                result = response.json().get("response", "")
                if self.debug:
                    header = "─ LLM RESPONSE "
                    print(f"\n\033[32m┌{header}" + "─" * (_DEBUG_BOX_WIDTH - len(header) - 1))
                    for line in result.splitlines():
                        print(f"\033[32m│ {line}")
                    print("└" + "─" * _DEBUG_BOX_WIDTH + "\033[0m\n")
                return result
            return ""
        except Exception as e:
            if self.debug:
                print(f"\033[31m[LLM ERROR] {e}\033[0m")
            return f"Error: {str(e)}"

    def extract_frontmatter(self, content: str, max_length: int = 500) -> dict:
        """
        Extract frontmatter (title, tags, status) from content using LLM.

        Returns dict with extracted metadata.
        """
        if not self.available:
            return {"error": "Ollama not available"}

        # Truncate for efficiency
        preview = content[:max_length]

        prompt = f"""Analyze this vault note content and extract metadata in JSON format.
Return only valid JSON with these fields (all optional):
- title: str (main topic/heading)
- tags: list[str] (relevant categories, lowercase, max 5)
- status: str (one of: active, archived, draft, evergreen, reference, completed)
- category_hint: str (one of: project, area, resource)

Content:
{preview}

Return only the JSON object, no markdown or explanation."""

        try:
            result_text = self.generate(prompt, temperature=0.3, num_predict=200)

            # Try to extract JSON from response
            if "{" in result_text:
                json_start = result_text.index("{")
                json_end = result_text.rfind("}") + 1
                json_str = result_text[json_start:json_end]
                metadata = json.loads(json_str)
                return {"success": True, "metadata": metadata}
            else:
                return {"success": False, "error": "No JSON in response"}

        except json.JSONDecodeError as e:
            return {"success": False, "error": f"JSON parse error: {str(e)}"}
        except Exception as e:
            return {"success": False, "error": str(e)}

    def classify_para_with_llm(self, path: str, content: str, heuristic_category: str) -> dict:
        """
        Use LLM to boost PARA classification confidence.

        Args:
            path: File path
            content: File content preview
            heuristic_category: Category from heuristic classifier

        Returns dict with llm_category, confidence, reasoning
        """
        if not self.available:
            return {
                "llm_category": heuristic_category,
                "confidence": 0.0,
                "reasoning": "LLM not available",
                "used_llm": False,
            }

        preview = content[:300]

        prompt = f"""Classify this vault note into ONE of: projects, areas, resources, archive

Path: {path}
Content preview:
{preview}

Respond with JSON: {{"category": "...", "confidence": 0.0-1.0, "reason": "..."}}"""

        try:
            result_text = self.generate(prompt, temperature=0.2, num_predict=100)

            if "{" in result_text:
                json_start = result_text.index("{")
                json_end = result_text.rfind("}") + 1
                json_str = result_text[json_start:json_end]
                result = json.loads(json_str)

                return {
                    "llm_category": result.get("category", heuristic_category),
                    "confidence": float(result.get("confidence", 0.5)),
                    "reasoning": result.get("reason", ""),
                    "used_llm": True,
                }
        except Exception as e:
            return {
                "llm_category": heuristic_category,
                "confidence": 0.0,
                "reasoning": f"LLM error: {str(e)}",
                "used_llm": False,
            }

        return {
            "llm_category": heuristic_category,
            "confidence": 0.0,
            "reasoning": "No JSON response",
            "used_llm": False,
        }

    def normalize_tags(self, tags: list[str]) -> list[str]:
        """Normalize tags using LLM."""
        if not self.available or not tags:
            return tags

        tags_str = ", ".join(tags)

        prompt = f"""Normalize these vault tags to a standard vocabulary (lowercase, singular form).
Return only a JSON array of normalized tags.

Tags: {tags_str}

Return format: ["tag1", "tag2", "tag3"]"""

        try:
            result_text = self.generate(prompt, temperature=0.1, num_predict=100)

            if "[" in result_text:
                json_start = result_text.index("[")
                json_end = result_text.rfind("]") + 1
                json_str = result_text[json_start:json_end]
                normalized = json.loads(json_str)
                return normalized if isinstance(normalized, list) else tags
        except Exception:
            return tags

        return tags

    def __del__(self):
        """Close HTTP client."""
        import contextlib

        with contextlib.suppress(Exception):
            self.client.close()
