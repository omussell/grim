#! /bin/sh

rm ~/hortus/db.sqlite3
alembic upgrade head
alembic revision --autogenerate -m "Initial"
alembic upgrade head
