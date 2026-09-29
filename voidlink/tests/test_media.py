"""Tests for media tracking module."""

from datetime import datetime

from voidlink_cli.media.models import MediaEntry, MediaTemplate, MediaType
from voidlink_cli.media.rating import MediaRatingEngine


def test_media_entry_creation():
    """Test MediaEntry initialization."""
    now = datetime.now()
    entry = MediaEntry(
        type=MediaType.BOOK,
        title="Test Book",
        created=now,
        author_creator="Test Author",
        rating=8.5,
        status="completed",
    )

    assert entry.title == "Test Book"
    assert entry.rating == 8.5
    assert entry.status == "completed"


def test_media_entry_is_rated():
    """Test rating check."""
    now = datetime.now()
    rated = MediaEntry(
        type=MediaType.BOOK,
        title="Rated Book",
        created=now,
        rating=7.0,
    )
    unrated = MediaEntry(
        type=MediaType.BOOK,
        title="Unrated Book",
        created=now,
    )

    assert rated.is_rated() is True
    assert unrated.is_rated() is False


def test_media_entry_is_completed():
    """Test completion check."""
    now = datetime.now()
    completed = MediaEntry(
        type=MediaType.BOOK,
        title="Completed",
        created=now,
        status="completed",
    )
    ongoing = MediaEntry(
        type=MediaType.BOOK,
        title="Ongoing",
        created=now,
        status="in-progress",
    )

    assert completed.is_completed() is True
    assert ongoing.is_completed() is False


def test_media_entry_rating_stars():
    """Test star representation."""
    now = datetime.now()
    entry_unrated = MediaEntry(
        type=MediaType.BOOK,
        title="Unrated",
        created=now,
    )
    entry_rated = MediaEntry(
        type=MediaType.BOOK,
        title="Rated 8",
        created=now,
        rating=8.0,
    )

    assert entry_unrated.get_rating_stars() == "☆☆☆☆☆"
    # 8.0 rounds to 8 stars
    assert entry_rated.get_rating_stars().count("★") == 8


def test_media_template_rendering():
    """Test template rendering."""
    now = datetime.now()
    rendered = MediaTemplate.render(
        media_type=MediaType.BOOK,
        title="Test Book",
        created=now,
        author_creator="Test Author",
    )

    assert "Test Book" in rendered
    assert "Test Author" in rendered
    assert "media_type: book" in rendered


def test_rating_analysis_empty():
    """Test rating analysis with no rated entries."""
    analysis = MediaRatingEngine.analyze_ratings([])

    assert analysis.total_rated == 0
    assert analysis.average_rating == 0.0


def test_rating_analysis():
    """Test rating analysis with entries."""
    now = datetime.now()
    entries = [
        MediaEntry(
            type=MediaType.BOOK,
            title="Book 1",
            created=now,
            rating=8.0,
        ),
        MediaEntry(
            type=MediaType.BOOK,
            title="Book 2",
            created=now,
            rating=6.0,
        ),
        MediaEntry(
            type=MediaType.BOOK,
            title="Book 3",
            created=now,
            rating=10.0,
        ),
    ]

    analysis = MediaRatingEngine.analyze_ratings(entries)

    assert analysis.total_rated == 3
    assert analysis.average_rating == 8.0
    assert analysis.highest_rated == "Book 3"
    assert analysis.lowest_rated == "Book 2"
