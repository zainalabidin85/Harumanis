import os

# config.Settings requires these; tests never open a DB connection or sign a token.
os.environ.setdefault("DATABASE_URL", "postgresql://test:test@localhost/test")
os.environ.setdefault("SECRET_KEY", "test-secret")
