from main import health


def test_health_function_returns_ok() -> None:
    assert health() == {"status": "ok"}
