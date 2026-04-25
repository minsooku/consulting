import os
import uuid as uuid_lib

from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv()


def get_database_url() -> str | None:
    database_url = os.getenv("DATABASE_URL") or os.getenv("SUPABASE_DB_URL")
    if not database_url:
        return None

    if database_url.startswith("postgres://"):
        database_url = database_url.replace("postgres://", "postgresql+psycopg2://", 1)
    elif database_url.startswith("postgresql://"):
        database_url = database_url.replace("postgresql://", "postgresql+psycopg2://", 1)

    return database_url


def get_connect_args() -> dict[str, str]:
    sslmode = os.getenv("DB_SSLMODE")
    return {"sslmode": sslmode} if sslmode else {}


DATABASE_URL = get_database_url()
Base = declarative_base()

if DATABASE_URL:
    engine = create_engine(
        DATABASE_URL,
        connect_args=get_connect_args(),
        pool_pre_ping=True,
    )
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
else:
    print("[database] WARNING: DATABASE_URL not set; DB-dependent endpoints will fail at runtime.")
    engine = None
    SessionLocal = None


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def check_database_connection() -> bool:
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))
    return True


def ensure_user_uuid_column() -> None:
    inspector = inspect(engine)
    if not inspector.has_table("users"):
        return

    columns = {column["name"] for column in inspector.get_columns("users")}
    with engine.begin() as connection:
        if "uuid" not in columns:
            connection.execute(text("ALTER TABLE users ADD COLUMN uuid VARCHAR(36)"))

        rows = connection.execute(
            text("SELECT id FROM users WHERE uuid IS NULL OR uuid = ''")
        ).fetchall()
        for row in rows:
            connection.execute(
                text("UPDATE users SET uuid = :uuid WHERE id = :id"),
                {"uuid": str(uuid_lib.uuid4()), "id": row.id},
            )

        connection.execute(
            text("CREATE UNIQUE INDEX IF NOT EXISTS ix_users_uuid ON users (uuid)")
        )
