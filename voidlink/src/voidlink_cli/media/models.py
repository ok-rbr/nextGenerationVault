"""Media tracking data models."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum
from pathlib import Path


class MediaType(StrEnum):
    """Supported media types."""

    BOOK = "book"
    SERIES = "series"
    MANGA = "manga"
    MOVIE = "movie"
    GAME = "game"
    PODCAST = "podcast"
    ARTICLE = "article"


@dataclass
class MediaEntry:
    """Single media item in the vault."""

    type: MediaType
    title: str
    created: datetime
    rating: float | None = None  # 1.0-10.0
    status: str = "unstarted"  # unstarted, in-progress, completed, dropped
    tags: list[str] = field(default_factory=list)
    notes_path: Path | None = None
    author_creator: str | None = None
    cover_url: str | None = None
    completed_date: datetime | None = None
    metadata: dict = field(default_factory=dict)

    def is_rated(self) -> bool:
        """Check if media has been rated."""
        return self.rating is not None

    def is_completed(self) -> bool:
        """Check if media has been completed."""
        return self.status == "completed"

    def get_rating_stars(self) -> str:
        """Get star representation of rating."""
        if not self.rating:
            return "☆☆☆☆☆"
        stars = min(10, int(self.rating + 0.5))
        filled = "★" * stars
        empty = "☆" * (10 - stars)
        return filled + empty


class MediaTemplate:
    """Template for creating media entry notes."""

    BOOK_TEMPLATE = """---
type: media
media_type: book
title: "{title}"
author: "{author}"
created: {created}
status: unstarted
rating:
tags: []
---

# {title}

**Author:** {author}

## Summary

[Add book summary/blurb here]

## Notes

[Add your notes as you read]

## Rating

[Rate 1-10 when finished]

## Related

- Link to similar books
"""

    MOVIE_TEMPLATE = """---
type: media
media_type: movie
title: "{title}"
director: "{director}"
created: {created}
status: unstarted
rating:
tags: []
---

# {title}

**Director:** {director}

## Summary

[Add movie plot/synopsis]

## Notes

[Add your watching notes]

## Rating

[Rate 1-10 after watching]

## Related

- Link to similar movies
- IMDB link
"""

    SERIES_TEMPLATE = """---
type: media
media_type: series
title: "{title}"
created: {created}
status: unstarted
rating:
tags: []
seasons_watched: 0
---

# {title}

## Summary

[Add series synopsis]

## Progress

- Seasons watched: 0
- Episodes completed: 0

## Notes

[Track your watching progress here]

## Rating

[Rate 1-10 when completed]

## Related

- Link to similar series
"""

    @staticmethod
    def get_template(media_type: MediaType) -> str:
        """Get template for media type."""
        templates = {
            MediaType.BOOK: MediaTemplate.BOOK_TEMPLATE,
            MediaType.MOVIE: MediaTemplate.MOVIE_TEMPLATE,
            MediaType.SERIES: MediaTemplate.SERIES_TEMPLATE,
        }
        return templates.get(media_type, MediaTemplate.BOOK_TEMPLATE)

    @staticmethod
    def render(
        media_type: MediaType,
        title: str,
        created: datetime,
        author_creator: str | None = None,
    ) -> str:
        """Render template with values."""
        template = MediaTemplate.get_template(media_type)
        return template.format(
            title=title,
            author=author_creator or "Unknown",
            director=author_creator or "Unknown",
            created=created.isoformat(),
        )
