"""Interactive user prompts for folder ingestion."""


class InteractiveReview:
    """Collect user feedback during folder ingestion."""

    def __init__(self, auto_approve: bool = False):
        """Initialize reviewer."""
        self.auto_approve = auto_approve

    def prompt_metadata(self, note_path: str, extracted: dict) -> dict:
        """Review extracted metadata and allow modifications."""
        if self.auto_approve:
            return extracted

        print(f"\n📝 Note: {note_path}")
        print("=" * 60)

        # Title
        title = extracted.get("title", "")
        if title:
            print(f"Title: {title}")
            new_title = input("  → Keep? [y/n/custom]: ").strip()
            if new_title.lower() in ("n", "no"):
                extracted["title"] = input("  New title: ").strip()
            elif new_title.lower() not in ("y", "yes", ""):
                extracted["title"] = new_title

        # Status
        status = extracted.get("status", "active")
        print(f"Status: {status}")
        new_status = input("  → Change? [y/n]: ").strip()
        if new_status.lower() in ("y", "yes"):
            extracted["status"] = input("  New status (active/draft/evergreen/archived): ").strip()

        # Tags
        tags = extracted.get("tags", [])
        print(f"Tags: {', '.join(tags)}")
        add_tags = input("  → Add tags? [comma-separated or blank]: ").strip()
        if add_tags:
            extracted["tags"].extend([t.strip() for t in add_tags.split(",")])

        return extracted

    def prompt_backlinks(self, suggestions: list) -> list:
        """Ask user to approve suggested backlinks."""
        if self.auto_approve or not suggestions:
            return suggestions

        approved = []
        print("\n🔗 Suggested Links:")
        print("-" * 60)

        for i, suggestion in enumerate(suggestions[:5], 1):  # Show top 5
            print(f"{i}. {suggestion.target_title}")
            print(f"   Reason: {suggestion.reason}")
            print(f"   Confidence: {suggestion.confidence:.1%}")
            response = input("   → Add link? [y/n/skip]: ").strip().lower()

            if response in ("y", "yes"):
                approved.append(suggestion)
            elif response in ("skip",):
                continue
            # else: skip this one

        return approved

    def prompt_media_extraction(self, media_files: list) -> list:
        """Ask user which media to extract."""
        if self.auto_approve or not media_files:
            return media_files

        print("\n📄 Found Media Files:")
        print("-" * 60)

        for media in media_files:
            size_mb = media.get("size_bytes", 0) / (1024 * 1024)
            print(f"- {media['path']} ({size_mb:.1f} MB)")

        extract = input("Extract all? [y/n]: ").strip().lower()
        if extract in ("y", "yes"):
            return media_files
        else:
            # Ask per-file
            approved = []
            for media in media_files:
                response = input(f"Extract {media['path']}? [y/n]: ").strip().lower()
                if response in ("y", "yes"):
                    approved.append(media)
            return approved

    def prompt_rename(self, current_path: str, suggested_path: str) -> bool:
        """Ask user if rename is okay."""
        if self.auto_approve:
            return True

        print("\n📌 Rename?")
        print(f"  From: {current_path}")
        print(f"  To: {suggested_path}")
        response = input("Proceed? [y/n]: ").strip().lower()
        return response in ("y", "yes")

    def prompt_description_edit(self, current_desc: str, suggested_desc: str) -> bool:
        """Ask user if LLM-suggested description should be used."""
        if self.auto_approve:
            return True

        print("\n✏️ Description Edit?")
        print(f"  Current: {current_desc[:100]}...")
        print(f"  Suggested: {suggested_desc[:100]}...")
        response = input("Use suggested? [y/n]: ").strip().lower()
        return response in ("y", "yes")

    def prompt_confirm_all(self, summary: dict) -> bool:
        """Final confirmation before applying all changes."""
        if self.auto_approve:
            return True

        print("\n" + "=" * 60)
        print("SUMMARY")
        print("=" * 60)
        print(f"Notes to modify: {summary.get('notes_modified', 0)}")
        print(f"Links to create: {summary.get('links_created', 0)}")
        print(f"Media to extract: {summary.get('media_extracted', 0)}")
        print(f"Metadata additions: {summary.get('metadata_added', 0)}")
        print("=" * 60)

        response = input("\n✓ Apply all changes? [y/n]: ").strip().lower()
        return response in ("y", "yes")
