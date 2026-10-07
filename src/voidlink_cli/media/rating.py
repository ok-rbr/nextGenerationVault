"""Media rating and analysis."""

from dataclasses import dataclass


@dataclass
class RatingAnalysis:
    """Analysis of media ratings."""

    total_rated: int
    average_rating: float
    highest_rated: str | None = None
    lowest_rated: str | None = None
    distribution: dict = None  # rating -> count

    def __post_init__(self):
        """Initialize distribution."""
        if self.distribution is None:
            self.distribution = {}


class MediaRatingEngine:
    """Engine for media rating analysis."""

    @staticmethod
    def analyze_ratings(media_entries: list) -> RatingAnalysis:
        """Analyze ratings across media collection."""
        rated_entries = [m for m in media_entries if m.is_rated()]

        if not rated_entries:
            return RatingAnalysis(
                total_rated=0,
                average_rating=0.0,
            )

        ratings = [m.rating for m in rated_entries]
        avg = sum(ratings) / len(ratings)

        # Distribution
        distribution = {}
        for rating in ratings:
            bucket = int(rating)  # Round down to nearest int
            distribution[bucket] = distribution.get(bucket, 0) + 1

        highest = max(rated_entries, key=lambda m: m.rating)
        lowest = min(rated_entries, key=lambda m: m.rating)

        return RatingAnalysis(
            total_rated=len(rated_entries),
            average_rating=avg,
            highest_rated=highest.title,
            lowest_rated=lowest.title,
            distribution=distribution,
        )

    @staticmethod
    def get_rating_stats(media_entries: list) -> dict:
        """Get comprehensive rating statistics."""
        analysis = MediaRatingEngine.analyze_ratings(media_entries)

        return {
            "total_rated": analysis.total_rated,
            "average_rating": round(analysis.average_rating, 2),
            "highest_rated": analysis.highest_rated,
            "lowest_rated": analysis.lowest_rated,
            "distribution": analysis.distribution,
        }
